import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/court_plus_logo.dart';
import '../widgets/country_flag.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Phone number'),
              const _PhoneField(),
              const SizedBox(height: 16),
              const _FieldLabel('Password'),
              const _DarkField(
                hint: 'Enter your password',
                suffix: Iconify(Ph.eye_slash, color: AppColors.white60, size: 18),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
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
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.otp),
                child: const Text('Login'),
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
                      child: Image.asset('assets/google_icon.png', height: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SocialButton(
                      child: Image.asset('assets/apple_icon.png', height: 26),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
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
    );
  }
}

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
  final Widget? suffix;
  const _DarkField({required this.hint, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: TextField(
        obscureText: hint.contains('password') || hint.contains('Password'),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.white60, fontSize: 14),
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

class _PhoneField extends StatelessWidget {
  const _PhoneField();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
              width: 1, height: 26,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: AppColors.darkBorder),
          const Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
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
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  const _SocialButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.darkField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Center(child: child),
    );
  }
}