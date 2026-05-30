import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_service.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class CatalogRepository {
  final CatalogService _catalogService;

  CatalogRepository(this._catalogService);

  Future<List<ProductModel>> searchProducts({
    String? query,
    String? categoryHandle,
    String? sortKey,
    bool reverse = false,
    double? minPrice,
    double? maxPrice,
    int page = 1,
  }) async {
    try {
      final response = await _catalogService.getProducts(
        query: query,
        categoryHandle: categoryHandle,
        sortKey: sortKey,
        reverse: reverse,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
      );
      final responseData = response.data;

      // Try multiple possible response structures
      dynamic productsList;

      if (responseData is Map) {
        final dataField = responseData['data'];
        if (dataField is List) {
          productsList = dataField; // Structure: { "data": [...] }
        } else if (dataField is Map) {
          // Structure: { "data": { "data": [...] } } (Laravel pagination)
          // Or { "data": { "products": [...] } }
          productsList = dataField['data'] ?? dataField['products'];
        } else {
          // Structure: { "products": [...] }
          productsList = responseData['products'];
        }
      } else if (responseData is List) {
        productsList = responseData; // Direct list
      }

      return ParserUtils.parseList(productsList, ProductModel.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductDetailModel> getProductDetail(String slug) async {
    final response = await _catalogService.getProductDetail(slug);
    return ProductDetailModel.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getProductReviews(
    String slug, {
    int page = 1,
  }) async {
    final response = await _catalogService.getReviews(slug, page: page);
    final data = response.data['data'] as Map? ?? {};
    final reviews =
        ParserUtils.parseList(data['reviews'], ProductReview.fromJson);
    final summary =
        data['summary'] is Map ? ReviewSummary.fromJson(data['summary']) : null;
    return {'reviews': reviews, 'summary': summary};
  }

  Future<bool> submitProductReview(
    String slug, {
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _catalogService.submitReview(slug, rating: rating, comment: comment);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductRecommendations(int productId) async {
    try {
      final response =
          await _catalogService.getProductRecommendations(productId);
      return _parseProductList(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<ProductModel>> getRecommendations({int limit = 10}) async {
    List<ProductModel>? products;

    try {
      final response = await _catalogService.getHomeRecommendations(limit: limit);
      products = _parseProductList(response.data);
    } catch (_) {}

    if (products != null && products.isNotEmpty) return products;

    try {
      final response = await _catalogService.getBestSellers(limit: limit);
      products = _parseProductList(response.data);
    } catch (_) {}

    return products ?? [];
  }

  List<ProductModel> _parseProductList(dynamic responseData) {
    dynamic productsList;

    if (responseData is Map) {
      final dataField = responseData['data'];
      if (dataField is List) {
        productsList = dataField;
      } else if (dataField is Map) {
        productsList = dataField['data'] ?? dataField['products'];
      } else {
        productsList = responseData['products'];
      }
    } else if (responseData is List) {
      productsList = responseData;
    }

    return ParserUtils.parseList(productsList, ProductModel.fromJson);
  }
}
