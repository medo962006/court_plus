/// Form field validators.
/// Returns null on valid, error message string on invalid.
sealed class Validators {
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 7 || cleaned.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP code is required';
    }
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit code';
    }
    return null;
  }

  static String? dateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final regex = RegExp(r'^\d{2}\s*/\s*\d{2}\s*/\s*\d{4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Use format DD / MM / YYYY';
    }
    return null;
  }

  /// Validates a full form map. Returns first error or null.
  static String? validateAll(Map<String, String?> fields,
      Map<String, String? Function(String?)> rules) {
    for (final entry in fields.entries) {
      final rule = rules[entry.key];
      if (rule != null) {
        final error = rule(entry.value);
        if (error != null) return error;
      }
    }
    return null;
  }
}