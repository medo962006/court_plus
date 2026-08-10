import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes.dart';
import '../widgets/court_plus_logo.dart';
import '../presentation/providers/auth_provider.dart';
import '../l10n/app_strings.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const Color kBackground = Color(0xFF0D1117);
  static const Color kNeonGreen = Color(0xFFC4FF00);
  static const Color kActiveBoxFill = Color(0xFF1C232B);
  static const Color kInactiveBoxFill = Color(0xFFEDEDED);
  static const Color kSubtleBorder = Color(0xFF2A313A);

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 60;
  bool _timerActive = false; // ← starts false, no auto-resend

  @override
  void initState() {
    super.initState();
    for (final f in _focusNodes) {
      f.addListener(() => setState(() {}));
    }
    // Do NOT auto-send OTP on load. Resend only on user tap.
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Starts the 60s cooldown timer and sends a new OTP.
  Future<void> _onResendTap() async {
    if (_timerActive) return;

    setState(() {
      _resendSeconds = 60;
      _timerActive = true;
    });

    final error = await ref.read(authStateProvider.notifier).resendOtp();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      if (mounted) setState(() => _timerActive = false);
      return;
    }

    // Start 60s countdown
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) _resendSeconds--;
      });
      if (_resendSeconds == 0) {
        if (mounted) setState(() => _timerActive = false);
        return false;
      }
      return mounted;
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) return;

    final auth = ref.read(authStateProvider.notifier);
    final state = ref.read(authStateProvider);
    final destination = state.otpSentTo;
    if (destination == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No verification code was sent. Please go back and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final error = await auth.verifyOtp(email: destination, code: code);
    if (error == null) {
      if (mounted) Navigator.of(context).pushNamed(Routes.profileSetup);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

    @override
    Widget build(BuildContext context) {
      final isLoading = ref.watch(authLoadingProvider);
      final screenHeight = MediaQuery.of(context).size.height;
      final t = AppStrings.of(context).t;
      final destination = ref.watch(authStateProvider).otpSentTo;

      return Scaffold(
        backgroundColor: kBackground,
        body: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0, height: screenHeight * 0.5,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent], stops: [0.35, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset('assets/images/player.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, height: screenHeight * 0.5,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, kBackground.withValues(alpha: 0.55), kBackground],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Center(child: CourtPlusLogo(height: 34)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('inputOtp'),
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.45),
                            children: [
                              TextSpan(text: t('otpSentMessage')),
                              TextSpan(
                                text: destination ?? 'your email',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: t('otpCheckMessages')),
                            ],
                          ),
                        ),
                      const SizedBox(height: 28),
                      Row(
                        children: List.generate(6, (index) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: index < 5 ? 10 : 0),
                            child: _otpBox(index),
                          ),
                        )),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNeonGreen,
                            foregroundColor: const Color(0xFF14181D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : Text(t('signUp'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: OutlinedButton(
                          onPressed: !_timerActive ? _onResendTap : null,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: kActiveBoxFill,
                            disabledBackgroundColor: kActiveBoxFill,
                            side: const BorderSide(color: kSubtleBorder, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _timerActive
                                ? '${t('resendOtpTimer')}${_resendSeconds.toString().padLeft(2, '0')}'
                                : t('resendOtp'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kNeonGreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacementNamed(Routes.signup),
                    child: Text(t('didntReceiveCode'),
                        style: const TextStyle(color: kNeonGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(int index) {
    final bool isFocused = _focusNodes[index].hasFocus ||
        (index == 0 && !_focusNodes.any((f) => f.hasFocus));
    return SizedBox(
      height: 58,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onChanged: (v) => _onDigitChanged(index, v),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        cursorColor: kNeonGreen,
        cursorWidth: 2.5, cursorHeight: 24, showCursor: true,
        style: TextStyle(
          color: isFocused ? Colors.white : const Color(0xFF14181D),
          fontSize: 20, fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isFocused ? kActiveBoxFill : kInactiveBoxFill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: isFocused ? const BorderSide(color: kSubtleBorder, width: 1) : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kSubtleBorder, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}