import 'package:flutter_test/flutter_test.dart';
import 'package:court_plus/core/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error for null value', () {
        final result = Validators.required(null);
        expect(result, 'This field is required');
      });

      test('returns error for empty string', () {
        final result = Validators.required('');
        expect(result, 'This field is required');
      });

      test('returns error for whitespace-only string', () {
        final result = Validators.required('   ');
        expect(result, 'This field is required');
      });

      test('returns null for valid value', () {
        final result = Validators.required('hello');
        expect(result, isNull);
      });

      test('accepts custom field name', () {
        final result = Validators.required(null, 'Email');
        expect(result, 'Email is required');
      });
    });

    group('email', () {
      test('returns null for null (optional)', () {
        expect(Validators.email(null), isNull);
      });

      test('returns null for empty string (optional)', () {
        expect(Validators.email(''), isNull);
      });

      test('returns null for whitespace-only (optional)', () {
        expect(Validators.email('   '), isNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
      });

      test('returns null for email with subdomain', () {
        expect(Validators.email('user@sub.example.com'), isNull);
      });

      test('returns null for email with dots in local part', () {
        expect(Validators.email('first.last@example.com'), isNull);
      });

      test('returns null for email with underscores', () {
              expect(Validators.email('user_name@example.com'), isNull);
            });

      test('returns error for missing @', () {
        expect(Validators.email('userexample.com'), isNotNull);
      });

      test('returns error for missing domain', () {
        expect(Validators.email('user@'), isNotNull);
      });

      test('returns error for missing local part', () {
        expect(Validators.email('@example.com'), isNotNull);
      });

      test('returns error for spaces in email', () {
        expect(Validators.email('user @example.com'), isNotNull);
      });
    });

    group('phone', () {
      test('returns error for null', () {
        expect(Validators.phone(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.phone(''), isNotNull);
      });

      test('returns error for too short (less than 7 digits)', () {
        expect(Validators.phone('12345'), isNotNull);
      });

      test('returns error for too long (more than 15 digits after cleaning)', () {
        expect(Validators.phone('1' * 20), isNotNull);
      });

      test('returns null for minimum valid phone (7 digits)', () {
        expect(Validators.phone('1234567'), isNull);
      });

      test('returns null for valid phone with formatting', () {
        expect(Validators.phone('+1 (555) 123-4567'), isNull);
      });

      test('returns null for valid international phone', () {
              expect(Validators.phone('+966501234567'), isNull);
            });
    });

    group('username', () {
      test('returns error for null', () {
        expect(Validators.username(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.username(''), isNotNull);
      });

      test('returns error for too short (less than 3 chars)', () {
        expect(Validators.username('ab'), isNotNull);
      });

      test('returns error for invalid characters', () {
        expect(Validators.username('user name!'), isNotNull);
      });

      test('returns error for special characters', () {
        expect(Validators.username('user@name'), isNotNull);
      });

      test('returns null for valid username with letters', () {
        expect(Validators.username('john_doe'), isNull);
      });

      test('returns null for valid username with numbers', () {
        expect(Validators.username('user123'), isNull);
      });

      test('returns null for valid username with underscores', () {
        expect(Validators.username('my_user_name'), isNull);
      });
    });

    group('fullName', () {
      test('returns error for null', () {
        expect(Validators.fullName(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.fullName(''), isNotNull);
      });

      test('returns error for too short (less than 2 chars)', () {
        expect(Validators.fullName('A'), isNotNull);
      });

      test('returns null for valid name', () {
        expect(Validators.fullName('John Doe'), isNull);
      });

      test('returns null for minimum length (2 chars)', () {
        expect(Validators.fullName('Jo'), isNull);
      });

      test('trims whitespace before checking', () {
        expect(Validators.fullName('   '), isNotNull);
      });
    });

    group('password', () {
      test('returns error for null', () {
        expect(Validators.password(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.password(''), isNotNull);
      });

      test('returns error for too short (less than 8 chars)', () {
        expect(Validators.password('Abc123'), isNotNull);
      });

      test('returns error when missing uppercase letter', () {
        expect(Validators.password('abcdefgh1'), isNotNull);
      });

      test('returns error when missing digit', () {
        expect(Validators.password('Abcdefghi'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('StrongPass1'), isNull);
      });

      test('returns null for complex password', () {
        expect(Validators.password('P@ssw0rd!'), isNull);
      });
    });

    group('otp', () {
      test('returns error for null', () {
        expect(Validators.otp(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.otp(''), isNotNull);
      });

      test('returns error for wrong length (5 digits)', () {
        expect(Validators.otp('12345'), isNotNull);
      });

      test('returns error for wrong length (7 digits)', () {
        expect(Validators.otp('1234567'), isNotNull);
      });

      test('returns error for non-digit characters', () {
        expect(Validators.otp('12A456'), isNotNull);
      });

      test('returns null for valid 6-digit code', () {
        expect(Validators.otp('123456'), isNull);
      });

      test('returns null for valid code with leading zeros', () {
        expect(Validators.otp('000123'), isNull);
      });
    });

    group('dateOfBirth', () {
      test('returns null for null (optional)', () {
        expect(Validators.dateOfBirth(null), isNull);
      });

      test('returns null for empty string (optional)', () {
              expect(Validators.dateOfBirth(''), isNull);
            });

      test('returns error for invalid format', () {
        expect(Validators.dateOfBirth('01-01-2000'), isNotNull);
      });

      test('returns error for partial date', () {
        expect(Validators.dateOfBirth('01/2000'), isNotNull);
      });

      test('returns null for valid date format DD / MM / YYYY', () {
        expect(Validators.dateOfBirth('01 / 01 / 2000'), isNull);
      });

      test('returns null for valid date format without spaces', () {
        expect(Validators.dateOfBirth('01/01/2000'), isNull);
      });
    });

    group('validateAll', () {
      test('returns first error found', () {
        final fields = {'name': '', 'email': 'bad'};
        final rules = <String, String? Function(String?)>{
          'name': Validators.required,
          'email': Validators.email,
        };
        final result = Validators.validateAll(fields, rules);
        expect(result, 'This field is required');
      });

      test('returns second error if first field is valid', () {
        final fields = {'name': 'John', 'email': 'bad'};
        final rules = <String, String? Function(String?)>{
          'name': Validators.required,
          'email': Validators.email,
        };
        final result = Validators.validateAll(fields, rules);
        expect(result, startsWith('Enter a valid'));
      });

      test('returns null when all fields pass', () {
        final fields = {'name': 'John', 'email': 'john@example.com'};
        final rules = <String, String? Function(String?)>{
          'name': Validators.required,
          'email': Validators.email,
        };
        final result = Validators.validateAll(fields, rules);
        expect(result, isNull);
      });

      test('skips fields without a rule', () {
        final fields = {'name': 'John', 'unused': ''};
        final rules = <String, String? Function(String?)>{
          'name': Validators.required,
        };
        final result = Validators.validateAll(fields, rules);
        expect(result, isNull);
      });
    });
  });
}