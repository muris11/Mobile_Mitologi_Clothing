import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class WishlistService {
  final ApiClient _apiClient;

  WishlistService(this._apiClient);

  Future<Response> getWishlist() async {
    return await _apiClient.dio.get(ApiEndpoints.wishlist);
  }

  Future<Response> addToWishlist(int productId) async {
    return await _apiClient.dio.post(ApiEndpoints.toggleWishlist(productId));
  }

  Future<Response> removeFromWishlist(int productId) async {
    return await _apiClient.dio.delete(ApiEndpoints.toggleWishlist(productId));
  }

  Future<Response> checkWishlist(int productId) async {
    return await _apiClient.dio.get(ApiEndpoints.checkWishlist(productId));
  }
}
