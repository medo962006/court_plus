import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../core/validators.dart';
import '../../core/logger.dart';
import '../../services/models.dart';
import '../../services/supabase_service.dart';
import 'supabase_provider.dart';

// ─── State ───

final class AuthState {
  final bool isLoading;
  final String? error;
  final UserProfile? user;
  final bool isAuthenticated;
  final String? otpSentTo;
  final bool isPhoneOtp;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
    this.otpSentTo,
    this.isPhoneOtp = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserProfile? user,
    bool? isAuthenticated,
    String? otpSentTo,
    bool? isPhoneOtp,
    bool clearError = false,
  }) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    user: user ?? this.user,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    otpSentTo: otpSentTo ?? this.otpSentTo,
    isPhoneOtp: isPhoneOtp ?? this.isPhoneOtp,
  );
}

// ─── Providers ───

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(supabaseServiceProvider));
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

// ─── Notifier ───

final class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabase;
  DateTime? _lastOtpSent;
  static const Duration _minOtpInterval = Duration(seconds: 60);

  AuthNotifier(this._supabase) : super(const AuthState()) {
    _listenToAuthChanges();
  }

  /// Listen for auth state changes (session refresh, sign-out, etc.).
  void _listenToAuthChanges() {
    _supabase.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedOut) {
        state = const AuthState();
      } else if (authState.event == AuthChangeEvent.tokenRefreshed) {
        AppLogger.info('Auth token refreshed successfully');
      } else if (authState.event == AuthChangeEvent.signedIn) {
        _loadProfile(authState.session?.user.id);
      }
    });
  }

  Future<void> _loadProfile(String? userId) async {
    if (userId == null) return;
    final result = await _supabase.getProfile(userId);
    result.fold(
      (profile) {
        state = state.copyWith(
          user: profile,
          isAuthenticated: true,
          isLoading: false,
        );
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
      },
    );
  }

  /// Validate and send OTP via email, with rate-limiting.
  Future<String?> validateAndSendOtp({
    required String fullName,
    required String username,
    required String email,
  }) async {
    // Rate-limit check
    if (_lastOtpSent != null &&
        DateTime.now().difference(_lastOtpSent!) < _minOtpInterval) {
      final remaining = _minOtpInterval.inSeconds -
          DateTime.now().difference(_lastOtpSent!).inSeconds;
      return 'Please wait ${remaining}s before requesting another code';
    }

    final nameErr = Validators.fullName(fullName);
    if (nameErr != null) return nameErr;
    final userErr = Validators.username(username);
    if (userErr != null) return userErr;
    final emailErr = Validators.email(email);
    if (emailErr != null) return emailErr;

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.sendOtp(email);
    _lastOtpSent = DateTime.now();
    return result.fold(
      (_) {
        state = state.copyWith(isLoading: false, otpSentTo: email, isPhoneOtp: false);
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  /// Send phone OTP with rate-limiting.
  Future<String?> sendPhoneOtp(String phone) async {
    if (_lastOtpSent != null &&
        DateTime.now().difference(_lastOtpSent!) < _minOtpInterval) {
      final remaining = _minOtpInterval.inSeconds -
          DateTime.now().difference(_lastOtpSent!).inSeconds;
      return 'Please wait ${remaining}s before requesting another code';
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.sendPhoneOtp(phone);
    _lastOtpSent = DateTime.now();
    return result.fold(
      (_) {
        state = state.copyWith(isLoading: false, otpSentTo: phone, isPhoneOtp: true);
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  /// Verify OTP (email or phone based on `isPhoneOtp` flag).
  Future<String?> verifyOtp({
    required String email,
    required String code,
    String? fullName,
    String? username,
  }) async {
    if (state.isPhoneOtp) {
      return verifyPhoneOtp(phone: email, code: code);
    }

    final otpErr = Validators.otp(code);
    if (otpErr != null) return otpErr;

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.verifyOtp(
      email: email,
      code: code,
      fullName: fullName,
      username: username,
    );
    return result.fold(
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          error: null,
        );
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  /// Verify phone OTP.
  Future<String?> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    final otpErr = Validators.otp(code);
    if (otpErr != null) return otpErr;

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.verifyPhoneOtp(phone: phone, code: code);
    return result.fold(
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          error: null,
        );
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  /// Login with email + OTP.
  Future<String?> login(String email) async {
    final emailErr = Validators.email(email);
    if (emailErr != null) return emailErr;

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.sendOtp(email);
    _lastOtpSent = DateTime.now();
    return result.fold(
      (_) {
        state = state.copyWith(isLoading: false, otpSentTo: email, isPhoneOtp: false);
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  /// Resend OTP to the last-used email/phone.
  Future<String?> resendOtp() async {
    final destination = state.otpSentTo;
    if (destination == null) return 'No email or phone to resend to';
    if (state.isPhoneOtp) {
      return sendPhoneOtp(destination);
    }
    return login(destination);
  }

  /// Sign out.
  Future<String?> signOut() async {
    final result = await _supabase.signOut();
    return result.fold(
      (_) {
        state = const AuthState();
        return null;
      },
      (e) => e.message,
    );
  }

  /// Sign in with Google.
  Future<String?> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.signInWithGoogle();
    return result.fold(
      (user) {
        if (user != null) {
          state = state.copyWith(
            isLoading: false,
            user: user,
            isAuthenticated: true,
            error: null,
          );
        }
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  /// Sign in with Apple.
    Future<String?> signInWithApple() async {
      state = state.copyWith(isLoading: true, clearError: true);
      final result = await _supabase.signInWithApple();
      return result.fold(
        (user) {
          if (user != null) {
            state = state.copyWith(
              isLoading: false,
              user: user,
              isAuthenticated: true,
              error: null,
            );
          }
          return null;
        },
        (e) {
          state = state.copyWith(isLoading: false, error: e.message);
          return e.message;
        },
      );
    }

    /// Sign in with email + password.
    Future<String?> signInWithEmailPassword({
      required String email,
      required String password,
    }) async {
      state = state.copyWith(isLoading: true, clearError: true);
      final result = await _supabase.signInWithPassword(
        email: email,
        password: password,
      );
      return result.fold(
        (user) {
          if (user != null) {
            state = state.copyWith(
              isLoading: false,
              user: user,
              isAuthenticated: true,
              error: null,
            );
          }
          return null;
        },
        (e) {
          state = state.copyWith(isLoading: false, error: e.message);
          return e.message;
        },
      );
    }

    /// Sign in as guest (anonymous).
    Future<String?> signInAsGuest() async {
          state = state.copyWith(isLoading: true, clearError: true);
          final result = await _supabase.signInAnonymously();
          return result.fold(
            (user) {
              final guestProfile = UserProfile(
                              id: 'guest',
                              fullName: 'Guest Player',
                              username: 'guest',
                              bio: 'Just exploring court+',
                              avatarUrl: 'assets/images/player.png',
                              matchesCount: 12,
                            );
              state = state.copyWith(
                isLoading: false,
                user: guestProfile,
                isAuthenticated: true,
                error: null,
              );
              return null;
            },
        (e) {
          state = state.copyWith(isLoading: false, error: e.message);
          return e.message;
        },
      );
    }

    /// Send a password reset email.
        Future<String?> sendPasswordResetEmail(String email) async {
          state = state.copyWith(isLoading: true, clearError: true);
          final result = await _supabase.sendPasswordResetEmail(email);
          return result.fold(
            (_) {
              state = state.copyWith(isLoading: false);
              return null;
            },
            (e) {
              state = state.copyWith(isLoading: false, error: e.message);
              return e.message;
            },
          );
        }

        /// Register a new user with email + password + full profile metadata.
        Future<String?> signUpWithPassword({
          required String email,
          required String password,
          required String fullName,
          required String username,
          String? phone,
          String? dateOfBirth,
          String? gender,
        }) async {
          state = state.copyWith(isLoading: true, clearError: true);
          final result = await _supabase.signUp(
            email: email,
            password: password,
            fullName: fullName,
            username: username,
            phone: phone,
            dateOfBirth: dateOfBirth,
            gender: gender,
          );
          return result.fold(
            (_) {
              state = state.copyWith(
                isLoading: false,
                otpSentTo: email,
                isPhoneOtp: false,
              );
              return null;
            },
            (e) {
              state = state.copyWith(isLoading: false, error: e.message);
              return e.message;
            },
          );
        }

    /// Update user profile in state.
  void updateUserProfile(UserProfile profile) {
    state = state.copyWith(user: profile);
  }

  /// Update the authenticated user's profile data.
  void updateProfile(UserProfile updated) {
    state = state.copyWith(user: updated);
  }

  /// Clear error state.
  void clearError() => state = state.copyWith(clearError: true);
}