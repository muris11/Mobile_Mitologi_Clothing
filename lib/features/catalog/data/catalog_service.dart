import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class CatalogService {
  final ApiClient _apiClient;

  CatalogService(this._apiClient);

  Future<Response> getProducts({
    String? query,
    String? categoryHandle,
    String? sortKey,
    bool reverse = false,
    double? minPrice,
    double? maxPrice,
    int page = 1,
  }) async {
    return await _apiClient.dio.get(
      ApiEndpoints.products,
      queryParameters: {
        if (query != null) 'q': query,
        if (categoryHandle != null) 'category': categoryHandle,
        if (sortKey != null) 'sortKey': sortKey,
        if (reverse) 'reverse': 'true',
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        'page': page,
      },
    );
  }

  Future<Response> getProductDetail(String slug) async {
    return await _apiClient.dio.get('${ApiEndpoints.products}/$slug');
  }

  Future<Response> getCategories() async {
    return await _apiClient.dio.get(ApiEndpoints.categories);
  }

  Future<Response> getReviews(String handle, {int page = 1}) async {
    return await _apiClient.dio.get(
      ApiEndpoints.productReviews(handle),
      queryParameters: {'page': page},
    );
  }

  Future<Response> submitReview(String handle, {required int rating, required String comment}) async {
    return await _apiClient.dio.post(
      ApiEndpoints.productReviews(handle),
      data: {
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<Response> getProductRecommendations(int productId) async {
    return await _apiClient.dio.get(ApiEndpoints.relatedProducts(productId));
  }

  Future<Response> getHomeRecommendations({int limit = 10}) async {
    return await _apiClient.dio.get(
      ApiEndpoints.aiRecommendations,
      queryParameters: {'limit': limit},
    );
  }

  Future<Response> getBestSellers({int limit = 10}) async {
    return await _apiClient.dio.get(
      ApiEndpoints.bestSellers,
      queryParameters: {'limit': limit},
    );
  }
}
