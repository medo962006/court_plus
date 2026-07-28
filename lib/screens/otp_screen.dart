import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes.dart';
import '../widgets/court_plus_logo.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Design tokens
  static const Color kBackground = Color(0xFF0D1117);
  static const Color kNeonGreen = Color(0xFFC4FF00);
  static const Color kActiveBoxFill = Color(0xFF1C232B);
  static const Color kInactiveBoxFill = Color(0xFFEDEDED);
  static const Color kSubtleBorder = Color(0xFF2A313A);

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 30;
  bool _timerActive = true;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Rebuild on focus changes so box fills update
    for (final f in _focusNodes) {
      f.addListener(() => setState(() {}));
    }
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

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _timerActive = true;
    });
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── Background hero image bleeding into the screen bg ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.5,
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.transparent],
                stops: [0.35, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/player.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Gradient overlay: transparent → background color
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.5,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      kBackground.withValues(alpha: 0.55),
                      kBackground,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // ── Foreground content ──
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Transparent logo over the image — no container/borders
                const Center(child: CourtPlusLogo(height: 34)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading — left aligned
                      const Text(
                        'Input OTP for Account to\nSign up',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle — left aligned, muted
                      RichText(
                        textAlign: TextAlign.left,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            height: 1.45,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Court+ just sent you a 6-Digit Code to ',
                            ),
                            TextSpan(
                              text: '+201018088964',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' please check your messages & enter the code below.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // ── OTP boxes ──
                      Row(
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: index < 5 ? 10 : 0),
                              child: _otpBox(index),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      // ── Sign up (primary) button ──
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.profileSetup),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNeonGreen,
                            foregroundColor: const Color(0xFF14181D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // ── Resend (secondary) button ──
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed:
                              !_timerActive ? _startResendTimer : null,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: kActiveBoxFill,
                            disabledBackgroundColor: kActiveBoxFill,
                            side: const BorderSide(
                              color: kSubtleBorder,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _timerActive
                                ? 'Resend OTP code in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                                : 'Resend OTP code',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kNeonGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // ── Footer ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have any account? ",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: kNeonGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
        cursorWidth: 2.5,
        cursorHeight: 24,
        showCursor: true,
        style: TextStyle(
          color: isFocused ? Colors.white : const Color(0xFF14181D),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isFocused ? kActiveBoxFill : kInactiveBoxFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: isFocused
                ? const BorderSide(color: kSubtleBorder, width: 1)
                : BorderSide.none,
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