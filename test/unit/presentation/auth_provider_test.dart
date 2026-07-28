import 'package:flutter_test/flutter_test.dart';
import 'package:court_plus/core/result.dart';
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';
/// Hand-rolled test service that replaces mockito.
class TestableSupabaseService extends SupabaseService {
  TestableSupabaseService() : super.test();
  Future<Result<void>> Function(String phone)? sendOtpOverride;
  Future<Result<UserProfile?>> Function({
    required String phone,
    required String code,
    String? fullName,
    String? username,
  })? verifyOtpOverride;
  Future<Result<void>> Function()? signOutOverride;

  @override
  Future<Result<void>> sendOtp(String phone) =>
      sendOtpOverride?.call(phone) ?? super.sendOtp(phone);

  @override
  Future<Result<UserProfile?>> verifyOtp({
    required String phone,
    required String code,
    String? fullName,
    String? username,
  }) =>
      verifyOtpOverride?.call(
        phone: phone,
        code: code,
        fullName: fullName,
        username: username,
      ) ??
      super.verifyOtp(
        phone: phone,
        code: code,
        fullName: fullName,
        username: username,
      );

  @override
  Future<Result<void>> signOut() =>
      signOutOverride != null ? signOutOverride!() : Future.value(Result.success(null));
}

UserProfile _user({
  String id = 'test-user',
  String fullName = 'Test User',
  String username = 'test_user',
}) =>
    UserProfile(id: id, fullName: fullName, username: username);

void main() {
  group('AuthNotifier', () {
    setUp(() {});
    tearDown(() {});

    group('initial state', () {
      test('starts with default values', () {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isAuthenticated, isFalse);
        expect(notifier.state.user, isNull);
        expect(notifier.state.error, isNull);
        expect(notifier.state.otpSentTo, isNull);
      });
    });

    group('validateAndSendOtp — validation', () {
      test('returns error when full name is null', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: '',
          username: 'valid_user',
          phone: '+123****7890',
        );
        expect(err, 'Full name is required');
      });

      test('returns error when username is too short', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'ab',
          phone: '+123****7890',
        );
        expect(err, 'Username must be at least 3 characters');
      });

      test('returns error when phone is null', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'valid_user',
          phone: '',
        );
        expect(err, 'Phone number is required');
      });

      test('sends OTP and updates state on success', () async {
        final service = TestableSupabaseService();
        service.sendOtpOverride = (_) async => Result.success(null);
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'john_doe',
          phone: '+966****4567',
        );
        expect(err, isNull);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.otpSentTo, '+966****4567');
        expect(notifier.state.error, isNull);
      });

      test('handles service failure and sets error state', () async {
        final service = TestableSupabaseService();
        service.sendOtpOverride =
            (_) async => Result.failure(AuthException('Network error'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'john_doe',
          phone: '+966****4567',
        );
        expect(err, 'Network error');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, 'Network error');
      });
    });

    group('verifyOtp — validation', () {
      test('returns error for too short code', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.verifyOtp(
          phone: '+966501234567',
          code: '12',
        );
        expect(err, 'Enter a valid 6-digit code');
      });

      test('handles verification failure', () async {
        final service = TestableSupabaseService();
        service.verifyOtpOverride = ({
          required phone,
          required code,
          fullName,
          username,
        }) async =>
            Result.failure(AuthException('Invalid code'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.verifyOtp(
          phone: '+966501234567',
          code: '123456',
        );
        expect(err, 'Invalid code');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, 'Invalid code');
        expect(notifier.state.isAuthenticated, isFalse);
        expect(notifier.state.user, isNull);
      });
    });

    group('login', () {
      test('sends OTP on valid phone', () async {
        final service = TestableSupabaseService();
        service.sendOtpOverride = (_) async => Result.success(null);
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.login('+966501234567');
        expect(err, isNull);
        expect(notifier.state.otpSentTo, '+966501234567');
      });

      test('returns error for invalid phone', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.login('');
        expect(err, 'Phone number is required');
      });
    });

    group('signOut', () {
      test('resets state on sign out', () async {
        final service = TestableSupabaseService();
        service.sendOtpOverride = (_) async => Result.success(null);
        service.verifyOtpOverride = ({
          required phone,
          required code,
          fullName,
          username,
        }) async =>
            Result.success(_user(id: 'auth-user-1'));
        final notifier = AuthNotifier(service as dynamic);
        await notifier.verifyOtp(phone: '+966****4567', code: '123456');
        expect(notifier.state.isAuthenticated, isTrue);
        await notifier.signOut();
        expect(notifier.state.isAuthenticated, isFalse);
        expect(notifier.state.user, isNull);
      });
    });

    group('clearError', () {
      test('clears error state', () async {
        final service = TestableSupabaseService();
        service.sendOtpOverride =
            (_) async => Result.failure(AuthException('Some error'));
        final notifier = AuthNotifier(service as dynamic);
        await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'john_doe',
          phone: '+966****4567',
        );
        expect(notifier.state.error, isNotNull);
        notifier.clearError();
        expect(notifier.state.error, isNull);
      });
    });
  });
}