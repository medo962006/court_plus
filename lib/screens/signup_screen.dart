import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/court_plus_logo.dart';
import '../widgets/country_flag.dart';
import '../presentation/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _gender;
  String? _errorText;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _userCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    final auth = ref.read(authStateProvider.notifier);
    final error = await auth.validateAndSendOtp(
      fullName: _nameCtrl.text.trim(),
      username: _userCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
    if (error == null && mounted) {
      Navigator.of(context).pushNamed(Routes.otp);
    } else if (mounted) {
      setState(() => _errorText = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final serverError = ref.watch(authErrorProvider);
    final displayError = _errorText ?? serverError;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(child: CourtPlusLogo(height: 32)),
              const SizedBox(height: 28),
              const Text('Sign up',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const _FieldLabel('Full name'),
              _DarkField(hint: 'Enter your full name', controller: _nameCtrl),
              const SizedBox(height: 16),
              const _FieldLabel('Email'),
              _DarkField(hint: 'Enter your email', controller: _emailCtrl),
              const SizedBox(height: 16),
              const _FieldLabel('Username'),
              _DarkField(hint: 'username', controller: _userCtrl),
              const SizedBox(height: 16),
              const _FieldLabel('Phone number'),
              _PhoneField(controller: _phoneCtrl),
              const SizedBox(height: 16),
              const _FieldLabel('Date of Birth'),
              _DarkField(
                hint: 'DD / MM / YYYY',
                controller: _dobCtrl,
                suffix: const Icon(Icons.calendar_today_outlined,
                    color: AppColors.white60, size: 18),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Gender'),
              _DarkField(
                hint: 'Select gender',
                controller: TextEditingController(text: _gender ?? ''),
                suffix: const Icon(Icons.keyboard_arrow_down, color: AppColors.white60),
              ),
              if (displayError != null) ...[
                const SizedBox(height: 8),
                Text(displayError, style: const TextStyle(color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onSignUp,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Sign up'),
                ),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.neonGreen, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: AppColors.neonGreen, fontSize: 14)),
                  ),
                  Expanded(child: Divider(color: AppColors.neonGreen, thickness: 1)),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: _SocialButton(child: Image.asset('assets/google_icon.png', height: 24))),
                  const SizedBox(width: 16),
                  Expanded(child: _SocialButton(child: Image.asset('assets/apple_icon.png', height: 26))),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(color: AppColors.white60, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacementNamed(Routes.login),
                      child: const Text('Sign In',
                          style: TextStyle(color: AppColors.neonGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: AppColors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
  );
}

class _DarkField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final Widget? suffix;
  const _DarkField({required this.hint, this.controller, this.suffix});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.darkField,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.darkBorder),
    ),
    child: TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.white60, fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        suffixIcon: suffix,
      ),
    ),
  );
}

class _PhoneField extends StatelessWidget {
  final TextEditingController? controller;
  const _PhoneField({this.controller});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.darkField,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.darkBorder),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        const CountryFlag(code: 'sa', width: 26),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, color: AppColors.white60, size: 18),
        Container(width: 1, height: 26, margin: const EdgeInsets.symmetric(horizontal: 10), color: AppColors.darkBorder),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(
              hintText: '5X XXX XXXX',
              hintStyle: TextStyle(color: AppColors.white60, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  const _SocialButton({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    decoration: BoxDecoration(
      color: AppColors.darkField,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.darkBorder),
    ),
    child: Center(child: child),
  );
}