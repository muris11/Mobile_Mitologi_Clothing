import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/session/cart_session_manager.dart';

class InMemoryCartStore implements CartSessionStore {
  String? cartId;

  @override
  Future<void> clearCartSessionId() async {
    cartId = null;
  }

  @override
  Future<String?> readCartSessionId() async => cartId;

  @override
  Future<void> writeCartSessionId(String value) async {
    cartId = value;
  }
}

void main() {
  group('CartSessionManager', () {
    test('saves and loads cart session id', () async {
      final store = InMemoryCartStore();
      final manager = CartSessionManager(store);

      await manager.saveCartSessionId('cart-123');

      expect(await manager.loadCartSessionId(), 'cart-123');
    });

    test('returns null when storage is empty', () async {
      final store = InMemoryCartStore();
      final manager = CartSessionManager(store);

      expect(await manager.loadCartSessionId(), isNull);
    });

    test('clears cart session id', () async {
      final store = InMemoryCartStore()..cartId = 'cart-123';
      final manager = CartSessionManager(store);

      await manager.clearCartSessionId();

      expect(await manager.loadCartSessionId(), isNull);
    });
  });
}
