// Backend service for court+ app.
// When Supabase is configured, this will connect to the live backend.
// For now it provides mock data for UI development.

import 'models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  bool get isConnected => false;

  // ─── Auth ───

  Future<UserProfile?> signUp({
    required String fullName,
    required String username,
    required String phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    // TODO: Implement Supabase auth signup
    return null;
  }

  Future<UserProfile?> login(String phone, String password) async {
    // TODO: Implement Supabase auth login
    return null;
  }

  Future<bool> verifyOtp(String phone, String code) async {
    // TODO: Implement OTP verification
    return true;
  }

  // ─── Courts ───

  Future<List<Court>> getCourts({String? sportType}) async {
    // TODO: Fetch from Supabase
    return [];
  }

  Future<Court?> getCourtById(String id) async {
    // TODO: Fetch from Supabase
    return null;
  }

  // ─── Bookings ───

  Future<Booking?> createBooking({
    required String courtId,
    required String date,
    required String timeSlot,
    required double duration,
    List<String> addOns = const [],
    required double totalAmount,
  }) async {
    // TODO: Insert into Supabase
    return null;
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    // TODO: Fetch from Supabase
    return [];
  }

  // ─── Matches ───

  Future<Match?> createMatch({
    required String courtId,
    required String date,
    required String timeSlot,
    required String level,
    required String gender,
    required String location,
    int maxPlayers = 4,
    double pricePerPerson = 25,
  }) async {
    // TODO: Insert into Supabase
    return null;
  }

  Future<List<Match>> getOpenMatches({Map<String, dynamic>? filters}) async {
    // TODO: Fetch from Supabase
    return [];
  }

  // ─── Payments ───

  Future<bool> processPayment({
    required double amount,
    required String method,
    String? bookingId,
    String? matchId,
  }) async {
    // TODO: Integrate payment gateway
    return true;
  }
}