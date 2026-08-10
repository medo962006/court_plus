import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/court_plus_logo.dart';
import '../presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final authNotifier = ref.read(authStateProvider.notifier);
    final error = await authNotifier.signInWithEmailPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _onGoogleSignIn() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    final error = await authNotifier.signInWithGoogle();
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _onAppleSignIn() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    final error = await authNotifier.signInWithApple();
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _onGuestSignIn() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    final error = await authNotifier.signInAsGuest();
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authNotifier = ref.read(authStateProvider.notifier);
    final error = await authNotifier.sendPasswordResetEmail(email);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Password reset email sent to $email. Check your inbox.',
        ),
        backgroundColor: error != null ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Center(child: CourtPlusLogo(height: 32)),
                const SizedBox(height: 28),
                const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const _FieldLabel('Email'),
                _DarkField(
                  hint: 'Enter your email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Password'),
                _DarkField(
                  hint: 'Enter your password',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  suffix: IconButton(
                    icon: Iconify(
                      _obscurePassword ? Ph.eye_slash : Ph.eye,
                      color: AppColors.white60,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _onForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: AppColors.darkText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkText,
                            ),
                          )
                        : const Text('Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                ),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.neonGreen, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or',
                          style: TextStyle(color: AppColors.neonGreen, fontSize: 14)),
                    ),
                    Expanded(child: Divider(color: AppColors.neonGreen, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        onTap: isLoading ? null : _onGoogleSignIn,
                        child: Image.asset('assets/google_icon.png', height: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SocialButton(
                        onTap: isLoading ? null : _onAppleSignIn,
                        child: Image.asset('assets/apple-icon-png.png', height: 26),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Quick actions row: Join as Guest + Quick Test Login
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : _onGuestSignIn,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.neonGreen,
                            side: const BorderSide(color: AppColors.neonGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.neonGreen,
                                  ),
                                )
                              : const Text('Join as Guest',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _quickTestLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonGreen,
                            foregroundColor: AppColors.darkText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.darkText,
                                  ),
                                )
                              : const Text('Quick Test Login',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: AppColors.white60, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacementNamed(Routes.signup),
                        child: const Text('Sign Up',
                            style: TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isTestLoginLoading = false;

  Future<void> _quickTestLogin() async {
    if (_isTestLoginLoading) return;
    setState(() => _isTestLoginLoading = true);
    try {
      // 1. Ensure test user exists via Edge Function
      final fnResponse = await http.post(
        Uri.parse('${AppConfig.supabaseUrl}/functions/v1/create-test-user'),
        headers: {'Content-Type': 'application/json'},
      );

      if (fnResponse.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Test user setup failed. Run this in your terminal:\n'
                '  cd court_plus && supabase functions deploy create-test-user',
              ),
              backgroundColor: Colors.deepOrange,
              duration: const Duration(seconds: 8),
            ),
          );
        }
        return;
      }

      // 2. Sign in with test credentials
      final authNotifier = ref.read(authStateProvider.notifier);
      final error = await authNotifier.signInWithEmailPassword(
        email: 'testuser@courtplus.com',
        password: 'TestPassword123!',
      );
      if (!mounted) return;

      if (error == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTestLoginLoading = false);
    }
  }
}

// ─── Reusable Widgets ───

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}

class _DarkField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _DarkField({
    required this.hint,
    this.controller,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.lightMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          suffixIcon: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
              : null,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _SocialButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.darkField,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Center(child: child),
      ),
    );
  }
}