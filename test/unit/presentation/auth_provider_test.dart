import 'package:flutter_test/flutter_test.dart';
import 'package:court_plus/core/result.dart';
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';

/// A manual fake of [SupabaseService] for testing [AuthNotifier].
class FakeSupabaseService extends SupabaseService {
  FakeSupabaseService() : super._();

  /// When non-null, [sendOtp] returns this result.
  Result<void>? sendOtpResult;
  int sendOtpCallCount = 0;
  String? lastSendOtpPhone;

  /// When non-null, [verifyOtp] returns this result.
  Result<UserProfile?>? verifyOtpResult;
  int verifyOtpCallCount = 0;
  String? lastVerifyOtpPhone;
  String? lastVerifyOtpCode;
  String? lastVerifyOtpFullName;
  String? lastVerifyOtpUsername;

  @override
  Future<Result<void>> sendOtp(String phone) async {
    sendOtpCallCount++;
    lastSendOtpPhone = phone;
    return sendOtpResult ?? Result.success(null);
  }

  @override
  Future<Result<UserProfile?>> verifyOtp({
    required String phone,
    required String code,
    String? fullName,
    String? username,
  }) async {
    verifyOtpCallCount++;
    lastVerifyOtpPhone = phone;
    lastVerifyOtpCode = code;
    lastVerifyOtpFullName = fullName;
    lastVerifyOtpUsername = username;
    return verifyOtpResult ??
        Result.success(
          UserProfile(id: 'test-user', fullName: fullName ?? '', username: username ?? ''),
        );
  }
}

void main() {
  late FakeSupabaseService fakeService;
  late AuthNotifier notifier;

  setUp(() {
    fakeService = FakeSupabaseService();
    notifier = AuthNotifier(fakeService);
  });

  group('AuthNotifier', () {
    group('initial state', () {
      test('starts with default values', () {
        final state = notifier.state;
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.user, isNull);
        expect(state.isAuthenticated, isFalse);
        expect(state.otpSentTo, isNull);
      });
    });

    group('validateAndSendOtp', () {
      test('returns error when fullName is invalid', () async {
        final error = await notifier.validateAndSendOtp(
          fullName: '',
          username: 'valid_user',
          phone: '+1234567890',
        );
        expect(error, 'Full name is required');
        expect(notifier.state.isLoading, isFalse);
        expect(fakeService.sendOtpCallCount, 0);
      });

      test('returns error when username is invalid', () async {
        final error = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'ab',
          phone: '+1234567890',
        );
        expect(error, 'Username must be at least 3 characters');
        expect(fakeService.sendOtpCallCount, 0);
      });

      test('returns error when phone is invalid', () async {
        final error = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'valid_user',
          phone: '12',
        );
        expect(error, 'Enter a valid phone number');
        expect(fakeService.sendOtpCallCount, 0);
      });

      test('returns error when email is provided but invalid', () async {
        final error = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'valid_user',
          phone: '+1234567890',
          email: 'not-an-email',
        );
        expect(error, startsWith('Enter a valid'));
        expect(fakeService.sendOtpCallCount, 0);
      });

      test('skips email validation when email is null', () async {
        final error = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'valid_user',
          phone: '+1234567890',
        );
        // Should proceed past validation to service call
        expect(fakeService.sendOtpCallCount, 1);
        expect(error, isNull);
      });

      test('sends OTP and updates state on success', () async {
        fakeService.sendOtpResult = Result.success(null);

        final error = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'john_doe',
          phone: '+966501234567',
        );

        expect(error, isNull);
        expect(fakeService.sendOtpCallCount, 1);
        expect(fakeService.lastSendOtpPhone, '+966501234567');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.otpSentTo, '+966501234567');
        expect(notifier.state.error, isNull);
      });

      test('handles service failure and sets error', () async {
        fakeService.sendOtpResult = Result.failure(
          AuthException('Network error'),
        );

        final error = await notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'john_doe',
          phone: '+966501234567',
        );

        expect(error, 'Network error');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, 'Network error');
        expect(notifier.state.otpSentTo, isNull);
      });

      test('sets isLoading to true during call', () async {
        // Use a completer to observe the intermediate loading state
        final completer = Future<void>.value();

        fakeService.sendOtpResult = Result.success(null);

        // Start the call but don't await yet — capture the future
        final future = notifier.validateAndSendOtp(
          fullName: 'John Doe',
          username: 'john_doe',
          phone: '+966501234567',
        );

        // During execution, isLoading should be true
        expect(notifier.state.isLoading, isTrue);

        await future;
        expect(notifier.state.isLoading, isFalse);
      });
    });

    group('verifyOtp', () {
      test('returns error when OTP code is invalid', () async {
        final error = await notifier.verifyOtp(
          phone: '+966501234567',
          code: '12',
        );
        expect(error, 'Enter a valid 6-digit code');
        expect(fakeService.verifyOtpCallCount, 0);
      });

      test('verifies OTP and authenticates user on success', () async {
        final userProfile = UserProfile(
          id: 'auth-user-1',
          fullName: 'John Doe',
          username: 'john_doe',
          phone: '+966501234567',
        );
        fakeService.verifyOtpResult = Result.success(userProfile);

        final error = await notifier.verifyOtp(
          phone: '+966501234567',
          code: '123456',
          fullName: 'John Doe',
          username: 'john_doe',
        );

        expect(error, isNull);
        expect(fakeService.verifyOtpCallCount, 1);
        expect(fakeService.lastVerifyOtpPhone, '+966501234567');
        expect(fakeService.lastVerifyOtpCode, '123456');
        expect(fakeService.lastVerifyOtpFullName, 'John Doe');
        expect(fakeService.lastVerifyOtpUsername, 'john_doe');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isAuthenticated, isTrue);
        expect(notifier.state.user?.id, 'auth-user-1');
        expect(notifier.state.user?.fullName, 'John Doe');
        expect(notifier.state.error, isNull);
      });

      test('handles verification failure', () async {
        fakeService.verifyOtpResult = Result.failure(
          AuthException('Invalid code'),
        );

        final error = await notifier.verifyOtp(
          phone: '+966501234567',
          code: '123456',
        );

        expect(error, 'Invalid code');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, 'Invalid code');
        expect(notifier.state.isAuthenticated, isFalse);
        expect(notifier.state.user, isNull);
      });
    });

    group('signOut', () {
      test('resets state on successful sign out', () async {
        // First set some authenticated state
        fakeService.verifyOtpResult = Result.success(
          UserProfile(id: 'u1', fullName: 'John', username: 'john'),
        );
        await notifier.verifyOtp(phone: '+123', code: '123456');

        expect(notifier.state.isAuthenticated, isTrue);

        // Now sign out
        final error = await notifier.signOut();
        expect(error, isNull);
        expect(notifier.state.isAuthenticated, isFalse);
        expect(notifier.state.user, isNull);
        expect(notifier.state.otpSentTo, isNull);
      });
    });

    group('clearError', () {
      test('clears the error state', () {
        // Set an error via internal state manipulation
        notifier
          ..validateAndSendOtp(
            fullName: '',
            username: '',
            phone: '',
          )
          // no need to await — the error is set synchronously before the async call
          ;

        // After validating, the state should have been modified; verify clearError works
        // by explicitly setting error and clearing it
        notifier.state = notifier.state.copyWith(error: 'some error');
        expect(notifier.state.error, 'some error');

        notifier.clearError();
        expect(notifier.state.error, isNull);
      });
    });
  });
}