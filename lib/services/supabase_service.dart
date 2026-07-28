import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../core/result.dart';
import '../core/logger.dart';
import '../core/config.dart';
import 'models.dart';

/// Singleton service wrapping Supabase client.
final class SupabaseService {
  SupabaseService._();
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;

  late final GoTrueClient _auth;
  late final SupabaseClient _client;
  bool _initialized = false;

  GoTrueClient get auth => _auth;
  SupabaseClient get client => _client;
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentSession != null;

  Future<Result<void>> init() async {
    if (_initialized) return Result.success(null);
    await AppConfig.init();
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _auth = _client.auth;
      _initialized = true;
      AppLogger.info('Supabase initialized');
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('Supabase init failed', error: e, stack: s);
      return Result.failure(
        ServerException('Failed to connect to server: $e'),
      );
    }
  }

  // ─── Auth ───

  Future<Result<void>> sendOtp(String phone) async {
    try {
      await _auth.signInWithOtp(phone: phone);
      AppLogger.info('OTP sent to $phone');
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('sendOtp failed', error: e, stack: s);
      return Result.failure(
        AuthException('Failed to send code: $e'),
      );
    }
  }

  Future<Result<UserProfile?>> verifyOtp({
    required String phone,
    required String code,
    String? fullName,
    String? username,
  }) async {
    try {
      final response = await _auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      );
      final user = response.user;
      if (user == null) {
        return Result.failure(
          AuthException('Verification failed — no user returned'),
        );
      }
      if (fullName != null && username != null) {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'username': username,
          'phone': phone,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      AppLogger.info('User authenticated: ${user.id}');
      return Result.success(
        UserProfile(id: user.id, fullName: fullName ?? '', username: username ?? ''),
      );
    } catch (e, s) {
      AppLogger.error('verifyOtp failed', error: e, stack: s);
      return Result.failure(
        AuthException('Invalid code: $e'),
      );
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.info('User signed out');
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('signOut failed', error: e, stack: s);
      return Result.failure(
        AuthException('Failed to sign out: $e'),
      );
    }
  }

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  // ─── Profile ───

  Future<Result<UserProfile?>> getProfile(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      final data = res;
      if (data == null) return Result.success(null);
      return Result.success(UserProfile.fromMap(data));
    } catch (e, s) {
      AppLogger.error('getProfile failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load profile: $e'));
    }
  }

  Future<Result<UserProfile>> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      final data = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return Result.success(UserProfile.fromMap(data));
    } catch (e, s) {
      AppLogger.error('updateProfile failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to update profile: $e'));
    }
  }

  // ─── Courts ───

  Future<Result<List<Court>>> getCourts({String? sportType}) async {
    try {
      var query = _client.from('courts').select();
      if (sportType != null && sportType != 'all') {
        query = query.eq('sport_type', sportType);
      }
      final List data = await query;
      final list = data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();
      return Result.success(list);
    } catch (e, s) {
      AppLogger.error('getCourts failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load courts: $e'));
    }
  }

  // ─── Bookings ───

  Future<Result<Booking>> createBooking(Map<String, dynamic> data) async {
    try {
      data['created_at'] = DateTime.now().toIso8601String();
      data['user_id'] = currentUser?.id;
      final result = await _client
          .from('bookings')
          .insert(data)
          .select()
          .single();
      return Result.success(Booking.fromMap(result));
    } catch (e, s) {
      AppLogger.error('createBooking failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to create booking: $e'));
    }
  }

  // ─── Payments ───

  Future<Result<void>> processPayment({
    required double amount,
    required String method,
    String? bookingId,
  }) async {
    try {
      AppLogger.info('Processing payment: $amount via $method');
      await _client.from('payments').insert({
        'booking_id': bookingId,
        'amount': amount,
        'method': method,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('processPayment failed', error: e, stack: s);
      return Result.failure(ServerException('Payment failed: $e'));
    }
  }
}