import '../../services/secure_storage_service.dart';

abstract class CartSessionStore {
  Future<void> writeCartSessionId(String value);
  Future<String?> readCartSessionId();
  Future<void> clearCartSessionId();
}

class SecureCartSessionStore implements CartSessionStore {
  @override
  Future<void> clearCartSessionId() => SecureStorageService.deleteCartSessionId();

  @override
  Future<String?> readCartSessionId() => SecureStorageService.getCartSessionId();

  @override
  Future<void> writeCartSessionId(String value) =>
      SecureStorageService.setCartSessionId(value);
}

class CartSessionManager {
  final CartSessionStore _store;

  CartSessionManager([CartSessionStore? store])
      : _store = store ?? SecureCartSessionStore();

  Future<void> saveCartSessionId(String cartSessionId) =>
      _store.writeCartSessionId(cartSessionId);

  Future<String?> loadCartSessionId() => _store.readCartSessionId();

  Future<void> clearCartSessionId() => _store.clearCartSessionId();
}
