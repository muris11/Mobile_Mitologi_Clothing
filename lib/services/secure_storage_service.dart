import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(accountName: 'mitologi_clothing_secure_storage'),
  );

  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _cartSessionIdKey = 'cart_session_id';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _searchHistoryKey = 'search_history';

  static Future<void> setAuthToken(String token) async =>
      await _storage.write(key: _authTokenKey, value: token);
  static Future<String?> getAuthToken() async =>
      await _storage.read(key: _authTokenKey);
  static Future<void> deleteAuthToken() async =>
      await _storage.delete(key: _authTokenKey);

  static Future<void> setUserData(String userData) async =>
      await _storage.write(key: _userDataKey, value: userData);
  static Future<String?> getUserData() async =>
      await _storage.read(key: _userDataKey);
  static Future<void> deleteUserData() async =>
      await _storage.delete(key: _userDataKey);

  static Future<String> getOrCreateCartSessionId() async {
    String? sessionId = await _storage.read(key: _cartSessionIdKey);
    if (sessionId == null) {
      sessionId = const Uuid().v4();
      await _storage.write(key: _cartSessionIdKey, value: sessionId);
    }
    return sessionId;
  }

  static Future<String?> getCartSessionId() async =>
      await _storage.read(key: _cartSessionIdKey);
  static Future<void> setCartSessionId(String sessionId) async =>
      await _storage.write(key: _cartSessionIdKey, value: sessionId);
  static Future<void> deleteCartSessionId() async =>
      await _storage.delete(key: _cartSessionIdKey);

  static Future<bool> isOnboardingCompleted() async =>
      (await _storage.read(key: _onboardingCompletedKey)) == 'true';
  static Future<void> setOnboardingCompleted(bool completed) async =>
      await _storage.write(
          key: _onboardingCompletedKey, value: completed ? 'true' : 'false');

  // Search History
  static Future<List<String>> getSearchHistory() async {
    final data = await _storage.read(key: _searchHistoryKey);
    if (data == null) return [];
    try {
      return List<String>.from(json.decode(data));
    } catch (_) {
      return [];
    }
  }

  static Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final history = await getSearchHistory();
    history.remove(query);
    history.insert(0, query);
    if (history.length > 10) {
      history.removeLast();
    }
    await _storage.write(key: _searchHistoryKey, value: json.encode(history));
  }

  static Future<void> removeSearchHistory(String query) async {
    final history = await getSearchHistory();
    history.remove(query);
    await _storage.write(key: _searchHistoryKey, value: json.encode(history));
  }

  static Future<void> clearSearchHistory() async =>
      await _storage.delete(key: _searchHistoryKey);

  static Future<void> clearAll() async => await _storage.deleteAll();
  static Future<void> clearAuthData() async {
    await deleteAuthToken();
    await deleteUserData();
  }
}
