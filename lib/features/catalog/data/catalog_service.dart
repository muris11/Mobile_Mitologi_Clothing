import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class CatalogService {
  final ApiClient _apiClient;

  CatalogService(this._apiClient);

  Future<Response> getProducts({
    String? query,
    int? categoryId,
    String? sort,
    double? minPrice,
    double? maxPrice,
    int page = 1,
  }) async {
    return await _apiClient.dio.get(
      ApiEndpoints.products,
      queryParameters: {
        if (query != null) 'search': query,
        if (categoryId != null) 'category_id': categoryId,
        if (sort != null) 'sort': sort,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
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

  Future<Response> getReviews(int productId) async {
    return await _apiClient.dio.get('${ApiEndpoints.products}/$productId/reviews');
  }
}
