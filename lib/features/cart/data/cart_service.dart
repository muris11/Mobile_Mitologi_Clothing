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
    required int productId,
    required int quantity,
    int? variantId,
  }) async {
    return await _apiClient.dio.post(
      ApiEndpoints.cart,
      data: {
        'product_id': productId,
        'quantity': quantity,
        if (variantId != null) 'variant_id': variantId,
      },
    );
  }

  Future<Response> updateQuantity(int itemId, int quantity) async {
    return await _apiClient.dio.put(
      '${ApiEndpoints.cart}/$itemId',
      data: {'quantity': quantity},
    );
  }

  Future<Response> removeFromCart(int itemId) async {
    return await _apiClient.dio.delete('${ApiEndpoints.cart}/$itemId');
  }

  Future<Response> clearCart() async {
    return await _apiClient.dio.delete(ApiEndpoints.cart);
  }
}
