import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/cart.dart';
import 'package:mitologi_clothing_mobile/providers/cart_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';

class FakeCartService extends CartService {
  FakeCartService() : super(ApiService());

  Cart? cart;
  bool addCalled = false;
  bool clearCalled = false;

  @override
  Future<Cart?> getCart() async => cart;

  @override
  Future<Cart> addItem({required String merchandiseId, required int quantity}) async {
    addCalled = true;
    return cart!;
  }

  @override
  Future<Cart> clearCart() async {
    clearCalled = true;
    return cart!;
  }
}

void main() {
  group('CartProvider', () {
    test('loadCart restores cart from service', () async {
      final service = FakeCartService()
        ..cart = Cart.fromJson({
          'id': 'cart-1',
          'items': [],
          'total_quantity': 0,
          'total': 0,
        });
      final provider = CartProvider(service);

      await provider.loadCart();

      expect(provider.cart?.id, 'cart-1');
      expect(provider.isLoading, isFalse);
    });

    test('addItem updates cart state', () async {
      final service = FakeCartService()
        ..cart = Cart.fromJson({
          'id': 'cart-2',
          'items': [],
          'total_quantity': 1,
          'total': 150000,
        });
      final provider = CartProvider(service);

      final result = await provider.addItem(merchandiseId: 'sku-1', quantity: 1);

      expect(result, isTrue);
      expect(service.addCalled, isTrue);
      expect(provider.cart?.id, 'cart-2');
    });

    test('clearCart updates state', () async {
      final service = FakeCartService()
        ..cart = Cart.fromJson({
          'id': 'cart-3',
          'items': [],
          'total_quantity': 0,
          'total': 0,
        });
      final provider = CartProvider(service);

      final result = await provider.clearCart();

      expect(result, isTrue);
      expect(service.clearCalled, isTrue);
      expect(provider.cart?.id, 'cart-3');
    });
  });
}
