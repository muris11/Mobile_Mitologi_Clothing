import '../../services/secure_storage_service.dart';

abstract class AuthTokenStore {
  Future<void> writeToken(String value);
  Future<String?> readToken();
  Future<void> writeUserData(String value);
  Future<String?> readUserData();
  Future<void> clear();
}

class SecureAuthTokenStore implements AuthTokenStore {
  @override
  Future<void> clear() => SecureStorageService.clearAuthData();

  @override
  Future<String?> readToken() => SecureStorageService.getAuthToken();

  @override
  Future<String?> readUserData() => SecureStorageService.getUserData();

  @override
  Future<void> writeToken(String value) => SecureStorageService.setAuthToken(value);

  @override
  Future<void> writeUserData(String value) =>
      SecureStorageService.setUserData(value);
}

class AuthSessionManager {
  final AuthTokenStore _store;

  AuthSessionManager([AuthTokenStore? store])
      : _store = store ?? SecureAuthTokenStore();

  Future<void> saveToken(String token) => _store.writeToken(token);
  Future<String?> loadToken() => _store.readToken();
  Future<void> saveUserData(String userData) => _store.writeUserData(userData);
  Future<String?> loadUserData() => _store.readUserData();
  Future<void> clear() => _store.clear();
}
