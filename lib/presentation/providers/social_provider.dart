import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase_service.dart';
import 'supabase_provider.dart';

// ─── Favorites ───

final favoritesProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getFavorites(userId);
  return result.fold(
    (courts) => courts,
    (e) => throw e,
  );
});

final isFavoritedProvider = FutureProvider.family<bool, String>((ref, courtId) async {
  final service = ref.read(supabaseServiceProvider);
  final userId = service.currentUser?.id;
  if (userId == null) return false;
  final result = await service.isFavorited(userId, courtId);
  return result.fold(
    (favorited) => favorited,
    (e) => throw e,
  );
});

final class FavoriteNotifier extends StateNotifier<Set<String>> {
  final SupabaseService _supabase;
  final String _userId;

  FavoriteNotifier(this._supabase, this._userId, [Set<String>? initial])
      : super(initial ?? {});

  Future<String?> toggle(String courtId) async {
    if (state.contains(courtId)) {
      state = Set.from(state)..remove(courtId);
      final result = await _supabase.removeFavorite(_userId, courtId);
      return result.fold((_) => null, (e) => e.message);
    } else {
      state = Set.from(state)..add(courtId);
      final result = await _supabase.addFavorite(_userId, courtId);
      return result.fold((_) => null, (e) => e.message);
    }
  }
}

final favoriteNotifierProvider = StateNotifierProvider.family<FavoriteNotifier, Set<String>, String>(
  (ref, userId) => FavoriteNotifier(ref.read(supabaseServiceProvider), userId),
);

// ─── Following ───

final followingProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getFollowing(userId);
  return result.fold(
    (following) => following,
    (e) => throw e,
  );
});

// ─── Moment Likes ───

final momentLikeNotifierProvider = StateNotifierProvider.family<MomentLikeNotifier, bool, String>(
  (ref, momentId) => MomentLikeNotifier(ref.read(supabaseServiceProvider), momentId),
);

final class MomentLikeNotifier extends StateNotifier<bool> {
  final SupabaseService _supabase;
  final String _momentId;

  MomentLikeNotifier(this._supabase, this._momentId, [bool liked = false]) : super(liked);

  Future<String?> toggle() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return 'Not authenticated';

    if (state) {
      state = false;
      final result = await _supabase.unlikeMoment(_momentId, userId);
      return result.fold((_) => null, (e) => e.message);
    } else {
      state = true;
      final result = await _supabase.likeMoment(_momentId, userId);
      return result.fold((_) => null, (e) => e.message);
    }
  }
}