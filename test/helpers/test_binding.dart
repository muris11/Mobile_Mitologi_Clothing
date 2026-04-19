import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

/// Global storage untuk mock secure storage
final Map<String, String> _mockStorage = <String, String>{};

/// Initialize Flutter binding for tests
void initializeTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// Setup mock secure storage channel
void setupMockSecureStorage() {
  const channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'read':
        final key = methodCall.arguments['key'] as String?;
        return _mockStorage[key];
      case 'write':
        final key = methodCall.arguments['key'] as String?;
        final value = methodCall.arguments['value'] as String?;
        if (key != null && value != null) {
          _mockStorage[key] = value;
        }
        return null;
      case 'delete':
        final key = methodCall.arguments['key'] as String?;
        _mockStorage.remove(key);
        return null;
      case 'deleteAll':
        _mockStorage.clear();
        return null;
      case 'readAll':
        return Map<String, String>.from(_mockStorage);
      default:
        return null;
    }
  });
}

/// Setup complete test environment dengan authenticated user
void setupTestEnvironment() {
  initializeTestBinding();
  setupMockSecureStorage();
  resetToAuthenticatedState();
}

/// Reset storage ke authenticated state
void resetToAuthenticatedState() {
  _mockStorage.clear();
  _mockStorage['auth_token'] = 'test_auth_token_12345';
  _mockStorage['user_data'] =
      '{"id": 1, "name": "Test User", "email": "test@example.com"}';
  _mockStorage['cart_session_id'] = 'test_cart_session_67890';
}

/// Setup untuk unauthenticated state
void resetToUnauthenticatedState() {
  _mockStorage.clear();
}

/// Set auth token
void setMockAuthToken(String token) {
  _mockStorage['auth_token'] = token;
}

/// Set cart session ID
void setMockCartSessionId(String sessionId) {
  _mockStorage['cart_session_id'] = sessionId;
}

/// Clear semua storage
void clearMockStorage() {
  _mockStorage.clear();
}

void resetMockStorageToDefaultAuthenticatedState() {
  _mockStorage
    ..clear()
    ..['auth_token'] = 'test_auth_token_12345'
    ..['user_data'] = '{"id": 1, "name": "Test User", "email": "test@example.com"}'
    ..['cart_session_id'] = 'test_cart_session_67890';
}

void resetMockStorageToEmptyState() {
  _mockStorage.clear();
}

/// Get storage value (for debugging)
String? getMockStorageValue(String key) {
  return _mockStorage[key];
}

/// Check if storage has key
bool hasMockStorageKey(String key) {
  return _mockStorage.containsKey(key);
}

/// Legacy function names for backward compatibility
void mockSecureStorageChannel() => setupMockSecureStorage();
void setupTestMocks() => setupTestEnvironment();
void setupUnauthenticatedMocks() {
  initializeTestBinding();
  setupMockSecureStorage();
  resetToUnauthenticatedState();
}
