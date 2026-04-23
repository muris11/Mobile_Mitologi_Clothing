import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import '../mocks/mock_api_client.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_binding.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
  });

  group('AuthService Tests', () {
    late MockApiClient mockClient;
    late ApiService apiService;
    late AuthService authService;

    setUp(() {
      // Reset storage to authenticated state
      resetMockStorageToDefaultAuthenticatedState();
      mockClient = MockApiClient();
      apiService = ApiService(client: mockClient.client);
      authService = AuthService(apiService);
    });

    tearDown(() {
      mockClient.clear();
    });

    group('register', () {
      test('registers new user successfully', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/register',
          TestHelpers.sampleAuthResponse,
        );

        // Act
        final result = await authService.register(
          name: 'Test User',
          email: 'test@example.com',
          password: 'Password123',
          passwordConfirmation: 'Password123',
          phone: '08123456789',
        );

        // Assert
        expect(result.user, isNotNull);
        expect(result.token, isNotNull);
        expect(result.user?.email, 'test@example.com');
      });

      test('throws exception on registration failure', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/register',
          {'message': 'Email already exists'},
          statusCode: 422,
        );

        // Act & Assert
        expect(
          () => authService.register(
            name: 'Test',
            email: 'existing@example.com',
            password: 'Password123',
            passwordConfirmation: 'Password123',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('login', () {
      test('logs in user successfully', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/login',
          TestHelpers.sampleAuthResponse,
        );

        // Act
        final result = await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.user, isNotNull);
        expect(result.token, 'test_auth_token_12345');
      });

      test('supports cart session merge', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/login',
          TestHelpers.sampleAuthResponse,
        );

        // Act
        final result = await authService.login(
          email: 'test@example.com',
          password: 'password123',
          cartSessionId: 'cart_session_123',
        );

        // Assert
        expect(result.user, isNotNull);
      });

      test('throws exception on invalid credentials', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/login',
          {'message': 'Invalid credentials'},
          statusCode: 401,
        );

        // Act & Assert
        expect(
          () => authService.login(
            email: 'wrong@example.com',
            password: 'wrongpass',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('logout', () {
      test('logs out user and clears token', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/logout',
          {'message': 'Logged out successfully'},
        );

        // Act & Assert - should not throw
        await expectLater(authService.logout(), completes);
      });
    });

    group('getCurrentUser', () {
      test('returns current user when authenticated', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/user',
          {'user': TestHelpers.sampleUser},
        );

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result?.email, 'test@example.com');
        expect(result?.name, 'Test User');
      });

      test('returns null when not authenticated', () async {
        // Arrange - clear auth token to simulate unauthenticated
        resetMockStorageToEmptyState();

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('forgotPassword', () {
      test('sends password reset email', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/forgot-password',
          {'message': 'Password reset link sent'},
        );

        // Act & Assert - should not throw
        await expectLater(
          authService.forgotPassword('test@example.com'),
          completes,
        );
      });

      test('throws exception on invalid email', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/forgot-password',
          {'message': 'Email not found'},
          statusCode: 404,
        );

        // Act & Assert
        expect(
          () => authService.forgotPassword('nonexistent@example.com'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('resetPassword', () {
      test('resets password with valid token', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/reset-password',
          {'message': 'Password reset successful'},
        );

        // Act & Assert - should not throw
        await expectLater(
          authService.resetPassword(
            token: 'valid_token',
            email: 'test@example.com',
            password: 'newpassword123',
            passwordConfirmation: 'newpassword123',
          ),
          completes,
        );
      });

      test('throws exception on invalid token', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/auth/reset-password',
          {'message': 'Invalid token'},
          statusCode: 400,
        );

        // Act & Assert
        expect(
          () => authService.resetPassword(
            token: 'invalid_token',
            email: 'test@example.com',
            password: 'NewPassword123',
            passwordConfirmation: 'NewPassword123',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
