import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/input_validator.dart';

void main() {
  group('InputValidator Tests', () {
    group('validatePasswordConfirmation Tests', () {
      test('returns null when passwords match', () {
        final result = InputValidator.validatePasswordConfirmation(
          'password123',
          'password123',
        );

        expect(result, null);
      });

      test('returns error when passwords do not match', () {
        final result = InputValidator.validatePasswordConfirmation(
          'password123',
          'password456',
        );

        expect(
          result,
          'Password dan konfirmasi tidak cocok',
        );
      });

      test('returns error when confirmation is empty', () {
        final result = InputValidator.validatePasswordConfirmation(
          'password123',
          '',
        );

        expect(
          result,
          'Konfirmasi password wajib diisi',
        );
      });

      test('returns error when both are empty', () {
        final result = InputValidator.validatePasswordConfirmation('', '');

        expect(
          result,
          'Konfirmasi password wajib diisi',
        );
      });

      test('is case sensitive', () {
        final result = InputValidator.validatePasswordConfirmation(
          'Password123',
          'password123',
        );

        expect(
          result,
          'Password dan konfirmasi tidak cocok',
        );
      });
    });

    group('validatePassword Tests', () {
      test('returns null for valid password', () {
        final result = InputValidator.validatePassword('Password123');

        expect(result, null);
      });

      test('returns error for empty password', () {
        final result = InputValidator.validatePassword('');

        expect(result, 'Password wajib diisi');
      });

      test('returns error for short password (less than 8 chars)', () {
        final result = InputValidator.validatePassword('Pass1');

        expect(result, 'Password minimal 8 karakter');
      });

      test('returns error for password without uppercase', () {
        final result = InputValidator.validatePassword('password123');

        expect(
          result,
          'Password harus mengandung huruf besar',
        );
      });

      test('returns error for password without lowercase', () {
        final result = InputValidator.validatePassword('PASSWORD123');

        expect(
          result,
          'Password harus mengandung huruf kecil',
        );
      });

      test('returns error for password without numbers', () {
        final result = InputValidator.validatePassword('PasswordABC');

        expect(
          result,
          'Password harus mengandung angka',
        );
      });

      test('returns null for exactly 8 characters', () {
        final result = InputValidator.validatePassword('Pass1234');

        expect(result, null);
      });

      test('returns error for password with only numbers', () {
        final result = InputValidator.validatePassword('12345678');

        expect(
          result,
          'Password harus mengandung huruf besar',
        );
      });

      test('returns error for password with only letters', () {
        final result = InputValidator.validatePassword('Password');

        expect(
          result,
          'Password harus mengandung angka',
        );
      });

      test('validates complex password with special chars', () {
        final result = InputValidator.validatePassword('Pass1234!@#');

        expect(result, null);
      });

      test('validates password with spaces', () {
        final result = InputValidator.validatePassword('Pass 1234');

        expect(result, null); // spaces are allowed
      });
    });

    group('validateEmail Tests', () {
      test('returns null for valid email', () {
        final result = InputValidator.validateEmail('test@example.com');

        expect(result, null);
      });

      test('returns null for valid email with subdomain', () {
        final result = InputValidator.validateEmail('test@mail.example.com');

        expect(result, null);
      });

      test('returns null for valid email with plus sign', () {
        final result = InputValidator.validateEmail('test+label@example.com');

        expect(result, null);
      });

      test('returns error for empty email', () {
        final result = InputValidator.validateEmail('');

        expect(result, 'Email wajib diisi');
      });

      test('returns error for email without @', () {
        final result = InputValidator.validateEmail('testexample.com');

        expect(result, 'Format email tidak valid');
      });

      test('returns error for email without domain', () {
        final result = InputValidator.validateEmail('test@');

        expect(result, 'Format email tidak valid');
      });

      test('returns error for email without local part', () {
        final result = InputValidator.validateEmail('@example.com');

        expect(result, 'Format email tidak valid');
      });

      test('returns error for email with spaces', () {
        final result = InputValidator.validateEmail('test @example.com');

        expect(result, 'Format email tidak valid');
      });

      test('returns error for email with invalid characters', () {
        final result = InputValidator.validateEmail('test<>@example.com');

        expect(result, 'Format email tidak valid');
      });

      test('returns null for email with numbers', () {
        final result = InputValidator.validateEmail('test123@example.com');

        expect(result, null);
      });

      test('returns null for email with dots in local part', () {
        final result = InputValidator.validateEmail('first.last@example.com');

        expect(result, null);
      });

      test('returns error for email with double dots in domain', () {
        final result = InputValidator.validateEmail('test@example..com');

        expect(result, 'Format email tidak valid');
      });
    });

    group('sanitizeInput Tests', () {
      test('escapes less-than bracket', () {
        final result = InputValidator.sanitizeInput('<script>');

        expect(result, '&lt;script&gt;');
      });

      test('escapes greater-than bracket', () {
        final result = InputValidator.sanitizeInput('>');

        expect(result, '&gt;');
      });

      test('escapes double quotes', () {
        final result = InputValidator.sanitizeInput('"test"');

        expect(result, '&quot;test&quot;');
      });

      test('escapes single quotes', () {
        final result = InputValidator.sanitizeInput("'test'");

        expect(result, '&#x27;test&#x27;');
      });

      test('escapes all special characters together', () {
        final result =
            InputValidator.sanitizeInput('<script>alert("xss")</script>');

        expect(
          result,
          '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;',
        );
      });

      test('trims whitespace', () {
        final result = InputValidator.sanitizeInput('  hello  ');

        expect(result, 'hello');
      });

      test('handles empty string', () {
        final result = InputValidator.sanitizeInput('');

        expect(result, '');
      });

      test('handles string with only whitespace', () {
        final result = InputValidator.sanitizeInput('   ');

        expect(result, '');
      });

      test('does not modify safe characters', () {
        final result = InputValidator.sanitizeInput('Hello World 123!@#');

        expect(result, 'Hello World 123!@#');
      });

      test('preserves unicode characters', () {
        final result = InputValidator.sanitizeInput('Hello 世界 🌍');

        expect(result, 'Hello 世界 🌍');
      });
    });
  });
}
