import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/cart.dart';
import 'package:mitologi_clothing_mobile/providers/cart_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';

class FakeInitCartService extends CartService {
  FakeInitCartService() : super(ApiService());

  int loadCalls = 0;
  Cart? cart;

  @override
  Future<Cart?> getCart() async {
    loadCalls++;
    return cart;
  }
}

void main() {
  test('ensureInitialized loads cart only once', () async {
    final service = FakeInitCartService()
      ..cart = Cart.fromJson({
        'id': 'cart-1',
        'items': [],
        'total_quantity': 0,
        'total': 0,
      });
    final provider = CartProvider(service);

    await provider.ensureInitialized();
    await provider.ensureInitialized();

    expect(service.loadCalls, 1);
  });
}
