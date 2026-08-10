/// MockDataService has been replaced with real Supabase queries.
/// 
/// All data is now fetched from Supabase via providers:
///   - Courts:     courtsProvider  → SupabaseService.getCourts()
///   - Coaches:    coachesProvider → SupabaseService.getCoaches()
///   - Moments:    momentsProvider → SupabaseService.getMoments()
///   - Bookings:   bookingState   → SupabaseService.getUserBookings()
///   - Invitations: invitationsProvider → SupabaseService.getInvitations()
///
/// This file is kept as a stub to avoid breaking imports during migration.
/// Remove once all consumers have been updated.
class MockDataService {
  MockDataService._();
}