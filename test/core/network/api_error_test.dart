import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/network/api_error.dart';

void main() {
  group('ApiError', () {
    test('classifies validation errors', () {
      const error = ApiError(
        message: 'Validation failed',
        statusCode: 422,
        fieldErrors: {
          'email': ['Email wajib diisi'],
        },
      );

      expect(error.isValidationError, isTrue);
      expect(error.isAuthError, isFalse);
      expect(error.isNotFound, isFalse);
      expect(error.firstFieldError('email'), 'Email wajib diisi');
    });

    test('classifies auth errors', () {
      const error = ApiError(message: 'Unauthorized', statusCode: 401);

      expect(error.isAuthError, isTrue);
      expect(error.isValidationError, isFalse);
    });

    test('classifies not found errors', () {
      const error = ApiError(message: 'Not found', statusCode: 404);

      expect(error.isNotFound, isTrue);
    });

    test('creates network error helper', () {
      final error = ApiError.network('No internet connection');

      expect(error.statusCode, 0);
      expect(error.message, 'No internet connection');
      expect(error.isNetworkError, isTrue);
    });
  });
}
