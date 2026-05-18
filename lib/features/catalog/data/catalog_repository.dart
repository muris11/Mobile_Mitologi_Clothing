import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_service.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class CatalogRepository {
  final CatalogService _catalogService;

  CatalogRepository(this._catalogService);

  Future<List<ProductModel>> searchProducts({
    String? query,
    int? categoryId,
    String? sort,
    int page = 1,
  }) async {
    try {
      final response = await _catalogService.getProducts(
        query: query,
        categoryId: categoryId,
        sort: sort,
        page: page,
      );
      final data = response.data['data'];
      final productsList = data is Map ? data['products'] : null;
      return ParserUtils.parseList(productsList, ProductModel.fromJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductDetailModel> getProductDetail(String slug) async {
    final response = await _catalogService.getProductDetail(slug);
    return ProductDetailModel.fromJson(response.data['data']);
  }
}
