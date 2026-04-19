import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/address.dart';
import 'package:mitologi_clothing_mobile/models/cart.dart';
import 'package:mitologi_clothing_mobile/models/order.dart';
import 'package:mitologi_clothing_mobile/providers/cart_provider.dart';
import 'package:mitologi_clothing_mobile/providers/checkout_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';
import 'package:mitologi_clothing_mobile/services/order_service.dart';
import 'package:mitologi_clothing_mobile/services/profile_service.dart';

class FakeCartService extends CartService {
  FakeCartService() : super(ApiService());
  Cart? cart;

  @override
  Future<Cart?> getCart() async => cart;

  @override
  Future<Cart> clearCart() async => cart!;
}

class FakeProfileService extends ProfileService {
  FakeProfileService() : super(ApiService());
  List<Address> addresses = [];

  @override
  Future<List<Address>> getAddresses() async => addresses;
}

class FakeOrderService extends OrderService {
  FakeOrderService() : super(ApiService());

  double shipping = 20000;
  bool checkoutCalled = false;

  @override
  Future<double> calculateShipping(int addressId) async => shipping;

  @override
  Future<Order> getOrderDetail(String orderNumber) async => Order.fromJson({
        'id': 1,
        'order_number': orderNumber,
        'status': 'pending',
        'total': 170000,
        'items': [],
      });
}

void main() {
  group('CheckoutProvider', () {
    test('submit blocked when address missing', () async {
      final cartService = FakeCartService()
        ..cart = Cart.fromJson({
          'id': 'cart-1',
          'items': [],
          'total_quantity': 1,
          'subtotal': {'amount': 150000},
          'total': 150000,
        });
      final cartProvider = CartProvider(cartService);
      final provider = CheckoutProvider(
        cartProvider,
        FakeProfileService(),
        FakeOrderService(),
      );

      final result = await provider.submitOrder();

      expect(result, isFalse);
      expect(provider.error, contains('Pilih alamat'));
    });
  });
}
