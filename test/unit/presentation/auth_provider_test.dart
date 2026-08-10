import 'package:flutter_test/flutter_test.dart';
import 'package:court_plus/core/result.dart';
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';

/// Hand-rolled test service that replaces mockito.
class TestableSupabaseService extends SupabaseService {
  TestableSupabaseService() : super.test();
  Future<Result<void>> Function(String email)? sendOtpOverride;
  Future<Result<UserProfile?>> Function({
    required String email,
    required String code,
    String? fullName,
    String? username,
  })? verifyOtpOverride;
  Future<Result<void>> Function()? signOutOverride;
  Future<Result<UserProfile?>> Function()? signInWithGoogleOverride;
  Future<Result<UserProfile?>> Function()? signInWithAppleOverride;

  @override
  Future<Result<void>> sendOtp(String email) =>
      sendOtpOverride?.call(email) ?? super.sendOtp(email);

  @override
  Future<Result<UserProfile?>> verifyOtp({
    required String email,
    required String code,
    String? fullName,
    String? username,
  }) =>
      verifyOtpOverride?.call(
        email: email,
        code: code,
        fullName: fullName,
        username: username,
      ) ??
      super.verifyOtp(
        email: email,
        code: code,
        fullName: fullName,
        username: username,
      );

  @override
  Future<Result<void>> signOut() =>
      signOutOverride != null ? signOutOverride!() : Future.value(Result.success(null));

  @override
  Future<Result<UserProfile?>> signInWithGoogle() =>
      signInWithGoogleOverride != null
          ? signInWithGoogleOverride!()
          : Future.value(Result.failure(AuthException('Not mocked')));

  @override
  Future<Result<UserProfile?>> signInWithApple() =>
      signInWithAppleOverride != null
          ? signInWithAppleOverride!()
          : Future.value(Result.failure(AuthException('Not mocked')));
}

UserProfile _user({
  String id = 'test-user',
  String fullName = 'Test User',
  String username = 'test_user',
}) =>
    UserProfile(id: id, fullName: fullName, username: username);

void main() {
  group('AuthNotifier', () {
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
      test('returns error when full name is empty', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: '',
          username: 'valid_user',
          email: 'test@example.com',
        );
        expect(err, 'Full name is required');
      });

      test('returns error when username is too short', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'ab',
          email: 'test@example.com',
        );
        expect(err, 'Username must be at least 3 characters');
      });

      test('returns error when email is invalid', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'valid_user',
          email: 'not-an-email',
        );
        expect(err, 'Enter a valid email address');
      });

      test('sends OTP and updates state on success', () async {
        final service = TestableSupabaseService();
        service.sendOtpOverride = (_) async => Result.success(null);
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'john_doe',
          email: 'john@example.com',
        );
        expect(err, isNull);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.otpSentTo, 'john@example.com');
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
          email: 'john@example.com',
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
          email: 'john@example.com',
          code: '12',
        );
        expect(err, 'Enter a valid 6-digit code');
      });

      test('handles verification failure', () async {
        final service = TestableSupabaseService();
        service.verifyOtpOverride = ({
          required email,
          required code,
          fullName,
          username,
        }) async =>
            Result.failure(AuthException('Invalid code'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.verifyOtp(
          email: 'john@example.com',
          code: '123456',
        );
        expect(err, 'Invalid code');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, 'Invalid code');
        expect(notifier.state.isAuthenticated, isFalse);
        expect(notifier.state.user, isNull);
      });

      test('authenticates user on successful verification', () async {
        final service = TestableSupabaseService();
        service.verifyOtpOverride = ({
          required email,
          required code,
          fullName,
          username,
        }) async =>
            Result.success(_user(id: 'auth-user-1'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.verifyOtp(
          email: 'john@example.com',
          code: '123456',
        );
        expect(err, isNull);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isAuthenticated, isTrue);
        expect(notifier.state.user, isNotNull);
        expect(notifier.state.user!.id, 'auth-user-1');
      });
    });

    group('login', () {
      test('sends OTP on valid email', () async {
        final service = TestableSupabaseService();
        service.sendOtpOverride = (_) async => Result.success(null);
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.login('john@example.com');
        expect(err, isNull);
        expect(notifier.state.otpSentTo, 'john@example.com');
      });

      test('returns error for invalid email', () async {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.login('not-an-email');
        expect(err, 'Enter a valid email address');
      });
    });

    group('signOut', () {
      test('resets state on sign out', () async {
        final service = TestableSupabaseService();
        service.verifyOtpOverride = ({
          required email,
          required code,
          fullName,
          username,
        }) async =>
            Result.success(_user(id: 'auth-user-1'));
        final notifier = AuthNotifier(service as dynamic);
        await notifier.verifyOtp(email: 'john@example.com', code: '123456');
        expect(notifier.state.isAuthenticated, isTrue);
        await notifier.signOut();
        expect(notifier.state.isAuthenticated, isFalse);
        expect(notifier.state.user, isNull);
      });
    });

    group('signInWithGoogle', () {
      test('authenticates user on success', () async {
        final service = TestableSupabaseService();
        service.signInWithGoogleOverride = () async =>
            Result.success(_user(id: 'google-user'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.signInWithGoogle();
        expect(err, isNull);
        expect(notifier.state.isAuthenticated, isTrue);
        expect(notifier.state.user!.id, 'google-user');
      });

      test('handles failure', () async {
        final service = TestableSupabaseService();
        service.signInWithGoogleOverride = () async =>
            Result.failure(AuthException('Google error'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.signInWithGoogle();
        expect(err, 'Google error');
        expect(notifier.state.isAuthenticated, isFalse);
      });
    });

    group('signInWithApple', () {
      test('authenticates user on success', () async {
        final service = TestableSupabaseService();
        service.signInWithAppleOverride = () async =>
            Result.success(_user(id: 'apple-user'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.signInWithApple();
        expect(err, isNull);
        expect(notifier.state.isAuthenticated, isTrue);
        expect(notifier.state.user!.id, 'apple-user');
      });

      test('handles failure', () async {
        final service = TestableSupabaseService();
        service.signInWithAppleOverride = () async =>
            Result.failure(AuthException('Apple error'));
        final notifier = AuthNotifier(service as dynamic);
        final err = await notifier.signInWithApple();
        expect(err, 'Apple error');
        expect(notifier.state.isAuthenticated, isFalse);
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
          email: 'john@example.com',
        );
        expect(notifier.state.error, isNotNull);
        notifier.clearError();
        expect(notifier.state.error, isNull);
      });
    });

    group('updateProfile', () {
      test('updates user profile in state', () {
        final service = TestableSupabaseService();
        final notifier = AuthNotifier(service as dynamic);
        notifier.updateProfile(
          _user(id: 'u1', fullName: 'Updated Name', username: 'updated'),
        );
        expect(notifier.state.user, isNotNull);
        expect(notifier.state.user!.fullName, 'Updated Name');
      });
    });
  });
}