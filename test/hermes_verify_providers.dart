import 'package:court_plus/presentation/providers/providers.dart';
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';

/// Ad-hoc verification: smoke check that all new types and methods
/// compile and resolve correctly.
///
/// This is NOT a test suite — it's a compile-time proof that every
/// new symbol is importable and well-typed.
void main() {
  // ── Settings ──
  settingsProvider;
  notificationsEnabledProvider;
  languageProvider;

  // ── Booking ──
  bookingStateProvider;
  userBookingsProvider;
  bookingLoadingProvider;

  // ── Review ──
  reviewStateProvider;
  reviewLoadingProvider;

  // ── Match (updated) ──
  matchCreationProvider;
  matchPricePerPlayerProvider;
  matchCanProceedProvider;
  userMatchesProvider;

  // ── Models ──
  const review = Review(id: 'r1', userId: 'u1', courtId: 'c1', rating: 5);
  assert(review.id == 'r1');

  // ── Service methods exist ──
  final svc = SupabaseService();
  svc.getUserBookings;
  svc.getUserMatches;
  svc.addReview;

  print('All types and methods verified successfully.');
}