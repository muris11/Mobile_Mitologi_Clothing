import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  Future<Response> getCart() async {
    return await _apiClient.dio.get(ApiEndpoints.cart);
  }

  Future<Response> addToCart({
    required int quantity,
    required int variantId,
  }) async {
    return await _apiClient.dio.post(
      ApiEndpoints.cartItems,
      data: {
        'merchandiseId': variantId,
        'quantity': quantity,
      },
    );
  }

  Future<Response> updateQuantity(int itemId, int quantity) async {
    return await _apiClient.dio.put(
      ApiEndpoints.cartItem(itemId),
      data: {'quantity': quantity},
    );
  }

  Future<Response> removeFromCart(int itemId) async {
    return await _apiClient.dio.delete(ApiEndpoints.cartItem(itemId));
  }

  Future<Response> clearCart() async {
    return await _apiClient.dio.delete(ApiEndpoints.clearCart);
  }
}
