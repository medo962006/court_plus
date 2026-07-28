import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/validators.dart';
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

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
    this.otpSentTo,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserProfile? user,
    bool? isAuthenticated,
    String? otpSentTo,
    bool clearError = false,
  }) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    user: user ?? this.user,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    otpSentTo: otpSentTo ?? this.otpSentTo,
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

  AuthNotifier(this._supabase) : super(const AuthState());

  /// Validate and send OTP for signup.
  Future<String?> validateAndSendOtp({
    required String fullName,
    required String username,
    required String phone,
    String? email,
  }) async {
    // Client-side validation
    final nameErr = Validators.fullName(fullName);
    if (nameErr != null) return nameErr;
    final userErr = Validators.username(username);
    if (userErr != null) return userErr;
    final phoneErr = Validators.phone(phone);
    if (phoneErr != null) return phoneErr;
    if (email != null && email.isNotEmpty) {
      final emailErr = Validators.email(email);
      if (emailErr != null) return emailErr;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.sendOtp(phone);
    return result.fold(
      (_) {
        state = state.copyWith(isLoading: false, otpSentTo: phone);
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
  }

  /// Verify OTP and authenticate.
  Future<String?> verifyOtp({
    required String phone,
    required String code,
    String? fullName,
    String? username,
  }) async {
    final otpErr = Validators.otp(code);
    if (otpErr != null) return otpErr;

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.verifyOtp(
      phone: phone,
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

  /// Login with phone + password (for future password auth).
  Future<String?> login(String phone) async {
    final phoneErr = Validators.phone(phone);
    if (phoneErr != null) return phoneErr;

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.sendOtp(phone);
    return result.fold(
      (_) {
        state = state.copyWith(isLoading: false, otpSentTo: phone);
        return null;
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return e.message;
      },
    );
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

  /// Clear error state.
  void clearError() => state = state.copyWith(clearError: true);
}