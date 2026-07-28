import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/court_plus_logo.dart';
import '../widgets/country_flag.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                'Sign up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
                            const _FieldLabel('Full name'),
                            const _DarkField(hint: 'Enter your full name'),
                            const SizedBox(height: 16),
                            const _FieldLabel('Email'),
                            const _DarkField(hint: 'Enter your email'),
                            const SizedBox(height: 16),
                            const _FieldLabel('Username'),
                            // Inline error state demo
                            const _DarkField(
                              hint: 'username',
                              errorText: 'User name must be unique',
                            ),
              const SizedBox(height: 16),
              const _FieldLabel('Phone number'),
              const _PhoneField(),
              const SizedBox(height: 16),
              const _FieldLabel('Date of Birth'),
              const _DarkField(
                hint: 'DD / MM / YYYY',
                suffix: Icon(Icons.calendar_today_outlined,
                    color: AppColors.white60, size: 18),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Gender'),
              const _DarkField(
                hint: 'Select gender',
                suffix: Icon(Icons.keyboard_arrow_down,
                    color: AppColors.white60),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  // OTP sending logic would go here
                  Navigator.of(context).pushNamed(Routes.otp);
                },
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(
                      child: Divider(color: AppColors.neonGreen, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: TextStyle(
                            color: AppColors.neonGreen, fontSize: 14)),
                  ),
                  Expanded(
                      child: Divider(color: AppColors.neonGreen, thickness: 1)),
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
                    const Text("Already have an account? ",
                        style: TextStyle(
                            color: AppColors.white60, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacementNamed(Routes.login),
                      child: const Text('Sign In',
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
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white60,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final String hint;
  final String? errorText;
  final Widget? suffix;

  const _DarkField({required this.hint, this.errorText, this.suffix});

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkField,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.darkBorder,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.white60, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 15),
              suffixIcon: hasError
                  ? const Icon(Icons.cancel, color: AppColors.error, size: 20)
                  : suffix,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
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
          const Icon(Icons.keyboard_arrow_down,
              color: AppColors.white60, size: 18),
          Container(
              width: 1,
              height: 26,
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