import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/cart.dart';
import 'package:mitologi_clothing_mobile/providers/cart_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';

class FakeCartService extends CartService {
  FakeCartService() : super(ApiService());

  Cart? cart;
  bool addCalled = false;
  bool updateCalled = false;
  bool removeCalled = false;
  bool clearCalled = false;
  bool shouldThrow = false;

  @override
  Future<Cart?> getCart() async {
    if (shouldThrow) throw Exception('Network error');
    return cart;
  }

  @override
  Future<Cart> addItem({required String merchandiseId, required int quantity}) async {
    addCalled = true;
    if (shouldThrow) throw Exception('Add failed');
    return cart!;
  }

  @override
  Future<Cart> updateItem(String itemId,
      {required String merchandiseId, required int quantity}) async {
    updateCalled = true;
    if (shouldThrow) throw Exception('Update failed');
    return cart!;
  }

  @override
  Future<Cart> removeItem(String itemId) async {
    removeCalled = true;
    if (shouldThrow) throw Exception('Remove failed');
    return cart!;
  }

  @override
  Future<Cart> clearCart() async {
    clearCalled = true;
    if (shouldThrow) throw Exception('Clear failed');
    return cart!;
  }
}

class CountingCartService extends FakeCartService {
  int callCount = 0;

  @override
  Future<Cart?> getCart() async {
    callCount++;
    return Cart.fromJson({
      'id': 'cart-6',
      'items': [],
      'total_quantity': 0,
      'total': 0,
    });
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

    test('updateItem updates cart state', () async {
      final service = FakeCartService()
        ..cart = Cart.fromJson({
          'id': 'cart-4',
          'items': [],
          'total_quantity': 2,
          'total': 300000,
        });
      final provider = CartProvider(service);

      final result = await provider.updateItem(
        'item-1',
        merchandiseId: 'sku-1',
        quantity: 2,
      );

      expect(result, isTrue);
      expect(service.updateCalled, isTrue);
      expect(provider.cart?.id, 'cart-4');
    });

    test('removeItem removes item from cart', () async {
      final service = FakeCartService()
        ..cart = Cart.fromJson({
          'id': 'cart-5',
          'items': [],
          'total_quantity': 1,
          'total': 150000,
        });
      final provider = CartProvider(service);

      final result = await provider.removeItem('item-1');

      expect(result, isTrue);
      expect(service.removeCalled, isTrue);
    });

    test('ensureInitialized loads cart only once', () async {
      final service = CountingCartService();
      final provider = CartProvider(service);

      await provider.ensureInitialized();
      await provider.ensureInitialized();
      await provider.ensureInitialized();

      expect(service.callCount, 1);
      expect(provider.cart?.id, 'cart-6');
    });

    test('loadCart handles error', () async {
      final service = FakeCartService()
        ..shouldThrow = true;
      final provider = CartProvider(service);

      await provider.loadCart();

      expect(provider.cart, isNull);
      expect(provider.error, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('addItem handles error', () async {
      final service = FakeCartService()
        ..shouldThrow = true
        ..cart = Cart.fromJson({
          'id': 'cart-7',
          'items': [],
          'total_quantity': 0,
          'total': 0,
        });
      final provider = CartProvider(service);

      final result = await provider.addItem(merchandiseId: 'sku-1', quantity: 1);

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('clearError clears error state', () async {
      final service = FakeCartService()
        ..shouldThrow = true;
      final provider = CartProvider(service);

      await provider.loadCart();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });

    test('getters return correct values', () async {
      final service = FakeCartService()
        ..cart = Cart.fromJson({
          'id': 'cart-8',
          'items': [
            {
              'id': 'item-1',
              'quantity': 2,
              'merchandise': {
                'id': 'sku-1',
                'title': 'Kaos',
                'price': {'amount': 150000},
              },
            },
          ],
          'total_quantity': 2,
          'total': 300000,
        });
      final provider = CartProvider(service);

      await provider.loadCart();

      expect(provider.hasItems, isTrue);
      expect(provider.itemCount, 2);
      expect(provider.total, 300000.0);
      expect(provider.items.length, 1);
      expect(provider.items.first.quantity, 2);
    });

    test('getters return defaults when cart is null', () {
      final service = FakeCartService();
      final provider = CartProvider(service);

      expect(provider.hasItems, isFalse);
      expect(provider.itemCount, 0);
      expect(provider.total, 0.0);
      expect(provider.items, isEmpty);
      expect(provider.cart, isNull);
    });
  });
}
