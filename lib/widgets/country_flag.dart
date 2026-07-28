import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Country flag from bundled SVG assets (country-flags repo).
class CountryFlag extends StatelessWidget {
  final String code; // e.g. 'sa', 'gb'
  final double width;

  const CountryFlag({super.key, required this.code, this.width = 28});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SvgPicture.asset(
        'assets/country-flags/svg/$code.svg',
        width: width,
        fit: BoxFit.cover,
      ),
    );
  }
}