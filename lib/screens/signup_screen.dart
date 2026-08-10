import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/court_plus_logo.dart';
import '../widgets/country_code_picker.dart';
import '../widgets/country_codes.dart';
import '../presentation/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _gender;
    CountryData _selectedCountry = allCountries.firstWhere((c) => c.code == 'sa');
    bool _obscurePassword = true;
  String? _errorText;

  static const _genderOptions = [
    'Male',
    'Female',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _userCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authStateProvider.notifier);
    final error = await auth.signUpWithPassword(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      fullName: _nameCtrl.text.trim(),
      username: _userCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : "${_selectedCountry.dialCode}${_phoneCtrl.text.trim()}",
      dateOfBirth: _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
      gender: _gender,
    );

    if (error == null && mounted) {
      Navigator.of(context).pushNamed(Routes.otp);
    } else if (mounted) {
      setState(() => _errorText = error);
    }
  }

  Future<void> _onGoogleSignIn() async {
    final auth = ref.read(authStateProvider.notifier);
    final error = await auth.signInWithGoogle();
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
    final auth = ref.read(authStateProvider.notifier);
    final error = await auth.signInWithApple();
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
    }
  }

  void _showGenderPicker() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1C232B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Select Gender',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Color(0xFF2A313A), height: 1),
            ..._genderOptions.map((g) => ListTile(
              title: Text(g, style: const TextStyle(color: Colors.white)),
              trailing: _gender == g
                  ? const Icon(Icons.check, color: Color(0xFFC4FF00), size: 20)
                  : null,
              onTap: () {
                Navigator.of(ctx).pop(g);
              },
            )),
          ],
        ),
      ),
    ).then((selected) {
      if (selected != null && mounted) {
        setState(() => _gender = selected);
      }
    });
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
          child: Form(
            key: _formKey,
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
                _DarkField(
                  hint: 'Enter your full name',
                  controller: _nameCtrl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Full name is required';
                    if (v.trim().length < 2) return 'Full name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                  hint: 'Create a password (min 6 characters)',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white60, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Username'),
                _DarkField(
                  hint: 'username',
                  controller: _userCtrl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username is required';
                    if (v.trim().length < 3) return 'Username must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                                const _FieldLabel('Phone number'),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.darkField,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.darkBorder),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      CountryCodePicker(
                                        selected: _selectedCountry,
                                        onChanged: (c) => setState(() => _selectedCountry = c),
                                        flagWidth: 26,
                                        iconSize: 18,
                                        textColor: Colors.white,
                                        arrowColor: Colors.white60,
                                      ),
                                      Container(
                                        width: 1, height: 26,
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                        color: AppColors.darkBorder,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneCtrl,
                                          keyboardType: TextInputType.phone,
                                          style: const TextStyle(color: Colors.white, fontSize: 15),
                                          decoration: const InputDecoration(
                                            hintText: '5X XXX XXXX',
                                            hintStyle: TextStyle(color: AppColors.lightMuted, fontSize: 14),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                const SizedBox(height: 16),
                const _FieldLabel('Date of Birth'),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: _DarkField(
                      hint: 'DD / MM / YYYY',
                      controller: _dobCtrl,
                      suffix: const Icon(Icons.calendar_today_outlined,
                          color: Colors.white60, size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Gender'),
                GestureDetector(
                  onTap: _showGenderPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.darkField,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _gender ?? 'Select gender',
                            style: TextStyle(
                              color: _gender != null ? Colors.white : Colors.white60,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 20),
                      ],
                    ),
                  ),
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
                    Expanded(child: _SocialButton(
                      onTap: isLoading ? null : _onGoogleSignIn,
                      child: Image.asset('assets/google_icon.png', height: 24),
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _SocialButton(
                      onTap: isLoading ? null : _onAppleSignIn,
                      child: Image.asset('assets/apple-icon-png.png', height: 26),
                    )),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Already have an account? ",
                          style: TextStyle(color: Colors.white60, fontSize: 14)),
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
      ),
    );
  }
}

// ─── Reusable Widgets ───

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
  );
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
  Widget build(BuildContext context) => Container(
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
        suffixIcon: suffix,
      ),
    ),
  );
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