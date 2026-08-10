import 'package:flutter/services.dart';
import 'country_codes.dart';

/// Formats a phone number as the user types, based on the selected country's pattern.
class PhoneFormatter extends TextInputFormatter {
  final CountryData country;

  PhoneFormatter({required this.country});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only process if text was actually added (not deleted)
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = _formatForCountry(digitsOnly);

    // Calculate cursor position
    final cursorOffset = formatted.length -
        (newValue.text.length - newValue.selection.end);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, formatted.length),
      ),
    );
  }

  String _formatForCountry(String digits) {
    switch (country.code) {
      case 'sa': // Saudi Arabia: 5XX XXX XXXX
        return _formatSaudi(digits);
      case 'ae': // UAE: 5X XXX XXXX
        return _formatUAE(digits);
      case 'eg': // Egypt: XXXX XXX XXXX
        return _formatEgypt(digits);
      case 'kw': // Kuwait: XXXX XXXX
        return _formatKuwait(digits);
      case 'qa': // Qatar: XXXX XXXX
        return _formatQatar(digits);
      case 'bh': // Bahrain: XXXX XXXX
        return _formatBahrain(digits);
      case 'om': // Oman: XXXX XXXX
        return _formatOman(digits);
      case 'jo': // Jordan: 7XXX XXXX
        return _formatJordan(digits);
      case 'lb': // Lebanon: XX XXX XXX
        return _formatLebanon(digits);
      case 'us': // US: (XXX) XXX-XXXX
        return _formatUS(digits);
      case 'gb': // UK: XXXX XXX XXX
        return _formatUK(digits);
      case 'in': // India: XXXXX-XXXXX
        return _formatIndia(digits);
      case 'pk': // Pakistan: XXXX-XXXXXXX
        return _formatPakistan(digits);
      default: // Generic: group in 3-3-4
        return _formatGeneric(digits);
    }
  }

  String _formatSaudi(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 3) return d;
    if (d.length <= 6) return '${d.substring(0, 3)} ${d.substring(3)}';
    if (d.length <= 9) {
      return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
    }
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6, 9)} ${d.substring(9, d.length.clamp(0, 12))}';
  }

  String _formatUAE(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 3) return d;
    if (d.length <= 6) return '${d.substring(0, 3)} ${d.substring(3)}';
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6, d.length.clamp(0, 10))}';
  }

  String _formatEgypt(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 4) return d;
    if (d.length <= 7) return '${d.substring(0, 4)} ${d.substring(4)}';
    return '${d.substring(0, 4)} ${d.substring(4, 7)} ${d.substring(7, d.length.clamp(0, 11))}';
  }

  String _formatKuwait(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 4) return d;
    return '${d.substring(0, 4)} ${d.substring(4, d.length.clamp(0, 8))}';
  }

  String _formatQatar(String d) => _formatKuwait(d);
  String _formatBahrain(String d) => _formatKuwait(d);
  String _formatOman(String d) => _formatKuwait(d);

  String _formatJordan(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 4) return d;
    return '${d.substring(0, 4)} ${d.substring(4, d.length.clamp(0, 8))}';
  }

  String _formatLebanon(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 2) return d;
    if (d.length <= 5) return '${d.substring(0, 2)} ${d.substring(2)}';
    return '${d.substring(0, 2)} ${d.substring(2, 5)} ${d.substring(5, d.length.clamp(0, 8))}';
  }

  String _formatUS(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 3) return d;
    if (d.length <= 6) return '(${d.substring(0, 3)}) ${d.substring(3)}';
    return '(${d.substring(0, 3)}) ${d.substring(3, 6)}-${d.substring(6, d.length.clamp(0, 10))}';
  }

  String _formatUK(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 4) return d;
    if (d.length <= 7) return '${d.substring(0, 4)} ${d.substring(4)}';
    return '${d.substring(0, 4)} ${d.substring(4, 7)} ${d.substring(7, d.length.clamp(0, 10))}';
  }

  String _formatIndia(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 5) return d;
    return '${d.substring(0, 5)}-${d.substring(5, d.length.clamp(0, 10))}';
  }

  String _formatPakistan(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 4) return d;
    return '${d.substring(0, 4)}-${d.substring(4, d.length.clamp(0, 11))}';
  }

  String _formatGeneric(String d) {
    if (d.isEmpty) return '';
    if (d.length <= 3) return d;
    if (d.length <= 6) return '${d.substring(0, 3)} ${d.substring(3)}';
    if (d.length <= 10) {
      return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
    }
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6, 10)} ${d.substring(10, d.length.clamp(0, 14))}';
  }
}

/// Strips formatting from a phone number, returning only digits.
String stripPhoneFormat(String formatted) {
  return formatted.replaceAll(RegExp(r'\D'), '');
}

/// Returns the full phone number with dial code (digits only) for API calls.
String fullPhoneDigits(String dialCode, String formattedPhone) {
  final digits = stripPhoneFormat(dialCode) + stripPhoneFormat(formattedPhone);
  return digits;
}