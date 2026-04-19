import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/cart.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Cart Model Tests', () {
    test('can parse sample cart', () {
      final cart = Cart.fromJson(TestHelpers.sampleCart);
      expect(cart, isNotNull);
      expect(cart.id, 'cart_123');
    });
  });
}
