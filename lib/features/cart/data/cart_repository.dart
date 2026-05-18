import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/features/cart/domain/models/cart_model.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';

class CartRepository {
  final CartService _cartService;
  final CartStorage _cartStorage;

  CartRepository(this._cartService, this._cartStorage);

  Future<CartModel> getCart() async {
    final response = await _cartService.getCart();
    return _processCartResponse(response);
  }

  Future<CartModel> addToCart({
    required int quantity,
    required int variantId,
  }) async {
    final response = await _cartService.addToCart(
      quantity: quantity,
      variantId: variantId,
    );
    return _processCartResponse(response);
  }

  Future<CartModel> updateQuantity(int itemId, int quantity) async {
    final response = await _cartService.updateQuantity(itemId, quantity);
    return _processCartResponse(response);
  }

  Future<CartModel> removeFromCart(int itemId) async {
    final response = await _cartService.removeFromCart(itemId);
    return _processCartResponse(response);
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
    await _cartStorage.deleteCartId();
  }

  Future<CartModel> _processCartResponse(dynamic response) async {
    final data = response.data['data'] ?? {};
    final cart = CartModel.fromJson(data);
    
    final cartId = response.data['cart_id'] ?? cart.id;
    if (cartId != null) {
      await _cartStorage.saveCartId(cartId);
    }
    
    return cart;
  }
}

