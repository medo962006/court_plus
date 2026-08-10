import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:core' hide Match;
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';
import 'supabase_provider.dart';

// ─── State ───

final class MatchCreationState {
  final String? courtId;
  final String? courtName;
  final String? courtCenter;
  final String? sportType;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String matchLevel;
  final String gender;
  final bool isPrivate;
  final int playerCount;
  final List<String> invitedPlayerIds;
  final bool isLoading;
  final String? error;
  final MatchCreationStep currentStep;

  const MatchCreationState({
    this.courtId,
    this.courtName,
    this.courtCenter,
    this.sportType,
    this.selectedDate,
    this.selectedTimeSlot,
    this.matchLevel = 'Intermediate',
    this.gender = 'Mixed',
    this.isPrivate = false,
    this.playerCount = 4,
    this.invitedPlayerIds = const [],
    this.isLoading = false,
    this.error,
    this.currentStep = MatchCreationStep.details,
  });

  double get pricePerPlayer {
    // Default price calculation; court data comes from Supabase
    return 100.0 / playerCount;
  }

  bool get canProceedFromDetails =>
      selectedDate != null &&
      selectedTimeSlot != null &&
      matchLevel.isNotEmpty &&
      courtId != null;

  MatchCreationState copyWith({
    String? courtId,
    String? courtName,
    String? courtCenter,
    String? sportType,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? matchLevel,
    String? gender,
    bool? isPrivate,
    int? playerCount,
    List<String>? invitedPlayerIds,
    bool? isLoading,
    String? error,
    MatchCreationStep? currentStep,
    bool clearError = false,
  }) => MatchCreationState(
    courtId: courtId ?? this.courtId,
    courtName: courtName ?? this.courtName,
    courtCenter: courtCenter ?? this.courtCenter,
    sportType: sportType ?? this.sportType,
    selectedDate: selectedDate ?? this.selectedDate,
    selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
    matchLevel: matchLevel ?? this.matchLevel,
    gender: gender ?? this.gender,
    isPrivate: isPrivate ?? this.isPrivate,
    playerCount: playerCount ?? this.playerCount,
    invitedPlayerIds: invitedPlayerIds ?? this.invitedPlayerIds,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    currentStep: currentStep ?? this.currentStep,
  );
}

enum MatchCreationStep { details, invitePlayers, confirm }

// ─── Providers ───

final matchCreationProvider = StateNotifierProvider<MatchCreationNotifier, MatchCreationState>(
  (ref) => MatchCreationNotifier(ref.read(supabaseServiceProvider)),
);

final matchPricePerPlayerProvider = Provider<double>((ref) {
  return ref.watch(matchCreationProvider).pricePerPlayer;
});

final matchCanProceedProvider = Provider<bool>((ref) {
  return ref.watch(matchCreationProvider).canProceedFromDetails;
});

final userMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getUserMatches();
  return result.fold(
    (matches) => matches,
    (e) => throw e,
  );
});

// ─── Notifier ───

final class MatchCreationNotifier extends StateNotifier<MatchCreationState> {
  final SupabaseService _supabase;

  MatchCreationNotifier(this._supabase) : super(const MatchCreationState());

  void setCourt(String id, String name, String center, String sport) {
    state = state.copyWith(courtId: id, courtName: name, courtCenter: center, sportType: sport);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setTimeSlot(String slot) {
    state = state.copyWith(selectedTimeSlot: slot);
  }

  void setMatchLevel(String level) {
    state = state.copyWith(matchLevel: level);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void togglePrivacy() {
    state = state.copyWith(isPrivate: !state.isPrivate);
  }

  void setPlayerCount(int count) {
    state = state.copyWith(playerCount: count);
  }

  void toggleInvitedPlayer(String userId) {
    final list = List<String>.from(state.invitedPlayerIds);
    if (list.contains(userId)) {
      list.remove(userId);
    } else {
      list.add(userId);
    }
    state = state.copyWith(invitedPlayerIds: list);
  }

  void setStep(MatchCreationStep step) {
    state = state.copyWith(currentStep: step);
  }

  Future<String?> createMatch() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'Not authenticated');
        return 'Not authenticated';
      }

      final data = <String, dynamic>{
        'court_id': state.courtId,
        'court_name': state.courtName,
        'date': state.selectedDate?.toIso8601String(),
        'time_slot': state.selectedTimeSlot,
        'level': state.matchLevel,
        'gender': state.gender,
        'is_private': state.isPrivate,
        'max_players': state.playerCount,
        'current_players': 1,
        'price_per_person': state.pricePerPlayer,
        'status': 'upcoming',
        'creator_id': userId,
      };
      final matchResult = await _supabase.client
          .from('matches')
          .insert(data)
          .select()
          .single();
      final matchId = matchResult['id'] as String;

      // Send invitations to selected players
      for (final invitedId in state.invitedPlayerIds) {
        await _supabase.sendInvitation({
          'sender_id': userId,
          'receiver_id': invitedId,
          'match_id': matchId,
          'court_name': state.courtName,
          'date': state.selectedDate?.toIso8601String().split('T').first,
          'time_slot': state.selectedTimeSlot,
          'status': 'pending',
          'message': 'You\'re invited to join a match!',
        });
      }

      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return e.toString();
    }
  }

  void reset() {
    state = const MatchCreationState();
  }
}