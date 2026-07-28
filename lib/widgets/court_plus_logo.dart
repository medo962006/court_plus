import 'package:flutter/material.dart';

/// court+ logo — real transparent PNG assets.
class CourtPlusLogo extends StatelessWidget {
  final double height;
  final bool full; // full logo with wordmark vs icon only

  const CourtPlusLogo({
    super.key,
    this.height = 36,
    this.full = true,
    double size = 36,
    double fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      full ? 'assets/full_logo_transparent.png' : 'assets/logo_transparent.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}