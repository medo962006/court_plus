import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/mock_data_service.dart';

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
    final court = courtId != null ? MockDataService.getCourtById(courtId!) : null;
    final hourlyRate = court?.pricePerHour ?? 100;
    return hourlyRate / playerCount;
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
  (ref) => MatchCreationNotifier(),
);

final matchPricePerPlayerProvider = Provider<double>((ref) {
  return ref.watch(matchCreationProvider).pricePerPlayer;
});

final matchCanProceedProvider = Provider<bool>((ref) {
  return ref.watch(matchCreationProvider).canProceedFromDetails;
});

// ─── Notifier ───

final class MatchCreationNotifier extends StateNotifier<MatchCreationState> {
  MatchCreationNotifier() : super(const MatchCreationState());

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
      // Mock: in production, call SupabaseService
      await Future.delayed(const Duration(milliseconds: 800));
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