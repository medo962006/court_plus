import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/models.dart';
import '../../services/supabase_service.dart';
import 'supabase_provider.dart';

// ─── State ───

final class ReviewState {
  final bool isLoading;
  final String? error;
  final List<Review> reviews;

  const ReviewState({
    this.isLoading = false,
    this.error,
    this.reviews = const [],
  });

  ReviewState copyWith({
    bool? isLoading,
    String? error,
    List<Review>? reviews,
    bool clearError = false,
  }) => ReviewState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    reviews: reviews ?? this.reviews,
  );
}

// ─── Providers ───

final reviewStateProvider = StateNotifierProvider<ReviewNotifier, ReviewState>(
  (ref) => ReviewNotifier(ref.read(supabaseServiceProvider)),
);

final reviewLoadingProvider = Provider<bool>((ref) {
  return ref.watch(reviewStateProvider).isLoading;
});

// ─── Notifier ───

final class ReviewNotifier extends StateNotifier<ReviewState> {
  final SupabaseService _supabase;

  ReviewNotifier(this._supabase) : super(const ReviewState());

  /// Submit a review for a court.
  Future<String?> submitReview({
    required String courtId,
    required int rating,
    String? comment,
    String? bookingId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.addReview(
      courtId: courtId,
      rating: rating,
      comment: comment,
      bookingId: bookingId,
    );
    return result.fold(
      (review) {
        state = state.copyWith(
          isLoading: false,
          reviews: [...state.reviews, review],
        );
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}