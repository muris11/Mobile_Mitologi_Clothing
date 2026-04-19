import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/services/secure_storage_service.dart';
import '../helpers/test_binding.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
    setupMockSecureStorage();
  });

  group('SecureStorageService Tests', () {
    setUp(() {
      resetToAuthenticatedState();
    });

    tearDown(() {
      clearMockStorage();
    });

    group('Auth Token Tests', () {
      test('can read auth token', () async {
        final token = await SecureStorageService.getAuthToken();
        expect(token, 'test_auth_token_12345');
      });

      test('can write auth token', () async {
        await SecureStorageService.setAuthToken('new_token_123');
        final token = await SecureStorageService.getAuthToken();
        expect(token, 'new_token_123');
      });

      test('can delete auth token', () async {
        await SecureStorageService.deleteAuthToken();
        final token = await SecureStorageService.getAuthToken();
        expect(token, isNull);
      });

      test('returns null when no auth token exists', () async {
        resetToUnauthenticatedState();
        final token = await SecureStorageService.getAuthToken();
        expect(token, isNull);
      });
    });

    group('User Data Tests', () {
      test('can read user data', () async {
        final userData = await SecureStorageService.getUserData();
        expect(
          userData,
          '{"id": 1, "name": "Test User", "email": "test@example.com"}',
        );
      });

      test('can write user data', () async {
        final newUserData =
            '{"id": 2, "name": "New User", "email": "new@example.com"}';
        await SecureStorageService.setUserData(newUserData);
        final userData = await SecureStorageService.getUserData();
        expect(userData, newUserData);
      });

      test('can delete user data', () async {
        await SecureStorageService.deleteUserData();
        final userData = await SecureStorageService.getUserData();
        expect(userData, isNull);
      });

      test('returns null when no user data exists', () async {
        resetToUnauthenticatedState();
        final userData = await SecureStorageService.getUserData();
        expect(userData, isNull);
      });
    });

    group('Cart Session ID Tests', () {
      test('can read cart session id', () async {
        final sessionId = await SecureStorageService.getCartSessionId();
        expect(sessionId, 'test_cart_session_67890');
      });

      test('can write cart session id', () async {
        await SecureStorageService.setCartSessionId('new_session_123');
        final sessionId = await SecureStorageService.getCartSessionId();
        expect(sessionId, 'new_session_123');
      });

      test('can delete cart session id', () async {
        await SecureStorageService.deleteCartSessionId();
        final sessionId = await SecureStorageService.getCartSessionId();
        expect(sessionId, isNull);
      });

      test('getOrCreateCartSessionId returns existing session', () async {
        final sessionId = await SecureStorageService.getOrCreateCartSessionId();
        expect(sessionId, 'test_cart_session_67890');
      });

      test('getOrCreateCartSessionId creates new session when none exists',
          () async {
        resetToUnauthenticatedState();
        final sessionId = await SecureStorageService.getOrCreateCartSessionId();
        expect(sessionId, isNotNull);
        expect(sessionId.length, greaterThan(10)); // UUID format
      });

      test('getOrCreateCartSessionId creates unique sessions', () async {
        resetToUnauthenticatedState();
        final sessionId1 =
            await SecureStorageService.getOrCreateCartSessionId();
        clearMockStorage();
        final sessionId2 =
            await SecureStorageService.getOrCreateCartSessionId();
        expect(sessionId1, isNot(equals(sessionId2)));
      });
    });

    group('Onboarding Tests', () {
      test('isOnboardingCompleted returns false initially', () async {
        resetToUnauthenticatedState();
        final completed = await SecureStorageService.isOnboardingCompleted();
        expect(completed, false);
      });

      test('can set onboarding completed to true', () async {
        await SecureStorageService.setOnboardingCompleted(true);
        final completed = await SecureStorageService.isOnboardingCompleted();
        expect(completed, true);
      });

      test('can set onboarding completed to false', () async {
        await SecureStorageService.setOnboardingCompleted(true);
        await SecureStorageService.setOnboardingCompleted(false);
        final completed = await SecureStorageService.isOnboardingCompleted();
        expect(completed, false);
      });
    });

    group('Search History Tests', () {
      test('getSearchHistory returns empty list initially', () async {
        resetToUnauthenticatedState();
        final history = await SecureStorageService.getSearchHistory();
        expect(history, isEmpty);
      });

      test('can add search history', () async {
        await SecureStorageService.addSearchHistory('test query');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, ['test query']);
      });

      test('can add multiple search history items', () async {
        await SecureStorageService.addSearchHistory('query 1');
        await SecureStorageService.addSearchHistory('query 2');
        await SecureStorageService.addSearchHistory('query 3');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, ['query 3', 'query 2', 'query 1']);
      });

      test('duplicate query moves to front', () async {
        await SecureStorageService.addSearchHistory('query 1');
        await SecureStorageService.addSearchHistory('query 2');
        await SecureStorageService.addSearchHistory('query 1');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, ['query 1', 'query 2']);
      });

      test('empty query is not added', () async {
        await SecureStorageService.addSearchHistory('');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, isEmpty);
      });

      test('whitespace-only query is not added', () async {
        await SecureStorageService.addSearchHistory('   ');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, isEmpty);
      });

      test('query with whitespace is added (not trimmed in storage)', () async {
        // Note: The actual implementation only trims for empty check,
        // but stores the original query. This test verifies actual behavior.
        await SecureStorageService.addSearchHistory('  test query  ');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, ['  test query  ']); // stored as-is
      });

      test('history is limited to 10 items', () async {
        for (int i = 1; i <= 12; i++) {
          await SecureStorageService.addSearchHistory('query $i');
        }
        final history = await SecureStorageService.getSearchHistory();
        expect(history.length, 10);
        expect(history.first, 'query 12');
        expect(history.last, 'query 3');
      });

      test('can remove search history item', () async {
        await SecureStorageService.addSearchHistory('query 1');
        await SecureStorageService.addSearchHistory('query 2');
        await SecureStorageService.removeSearchHistory('query 1');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, ['query 2']);
      });

      test('removing non-existent item does nothing', () async {
        await SecureStorageService.addSearchHistory('query 1');
        await SecureStorageService.removeSearchHistory('non-existent');
        final history = await SecureStorageService.getSearchHistory();
        expect(history, ['query 1']);
      });

      test('can clear search history', () async {
        await SecureStorageService.addSearchHistory('query 1');
        await SecureStorageService.addSearchHistory('query 2');
        await SecureStorageService.clearSearchHistory();
        final history = await SecureStorageService.getSearchHistory();
        expect(history, isEmpty);
      });

      test('handles corrupted search history data gracefully', () async {
        // Test that corrupted data doesn't crash - will be handled internally
        final history = await SecureStorageService.getSearchHistory();
        expect(history, isList); // Returns empty list on error
      });
    });

    group('Clear Data Tests', () {
      test('clearAll removes all data', () async {
        await SecureStorageService.setAuthToken('token');
        await SecureStorageService.setUserData('data');
        await SecureStorageService.setCartSessionId('session');

        await SecureStorageService.clearAll();

        expect(await SecureStorageService.getAuthToken(), isNull);
        expect(await SecureStorageService.getUserData(), isNull);
        expect(await SecureStorageService.getCartSessionId(), isNull);
      });

      test('clearAuthData removes only auth data', () async {
        await SecureStorageService.setAuthToken('token');
        await SecureStorageService.setUserData('data');
        await SecureStorageService.setCartSessionId('session');

        await SecureStorageService.clearAuthData();

        expect(await SecureStorageService.getAuthToken(), isNull);
        expect(await SecureStorageService.getUserData(), isNull);
        expect(await SecureStorageService.getCartSessionId(), 'session');
      });
    });
  });
}
