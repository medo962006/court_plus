import 'package:court_plus/core/result.dart';
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';

/// Hand-rolled test service that replaces mockito. Subclasses
/// [SupabaseService] so providers can take it as a `dynamic` SUT, and overrides
/// the auth-mutation methods with optional, per-test stubs.
///
/// Also overrides [onAuthStateChange]: the real getter reads `late _auth`,
/// which is only set by [SupabaseService.init] (never run in unit/widget tests),
/// so it would throw LateInitializationError as soon as a [StateNotifier]
/// subscribes. Surf a clean broadcast stream instead.
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

  @override
  Stream<Never> get onAuthStateChange => const Stream.empty();
}