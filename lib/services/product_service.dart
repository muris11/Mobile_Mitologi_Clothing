import '../config/api_config.dart';
import '../models/money.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService;
  ProductService(this._apiService);

  Map<String, dynamic> _withLegacyAliases(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    void alias(String camel, String snake) {
      if (result.containsKey(camel) && !result.containsKey(snake)) {
        result[snake] = result[camel];
      }
    }

    alias('heroSlides', 'hero_slides');
    alias('bestSellers', 'best_sellers');
    alias('newArrivals', 'new_arrivals');
    alias('averageRating', 'average_rating');
    alias('totalReviews', 'total_reviews');
    alias('featuredImage', 'featured_image');
    alias('portfolioItems', 'portfolio_items');
    alias('orderSteps', 'order_steps');

    return result;
  }

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return _withLegacyAliases(data);
      return _withLegacyAliases(response);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _listFromResponse(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = value['items'] ??
            value['products'] ??
            value['results'] ??
            value['data'];
        if (nested is List) return nested;
      }
    }
    return const [];
  }

  Map<String, dynamic>? _mapFromResponse(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is Map<String, dynamic>) return _withLegacyAliases(value);
    }
    return null;
  }

  Future<Map<String, dynamic>> getLandingPage() async {
    final response = await _apiService.get(ApiEndpoints.landingPage);
    return _unwrapResponse(response);
  }

  Future<List<Product>> getProducts({
    String? query,
    String? category,
    String? sortKey,
    bool? reverse,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
    String? ids,
  }) async {
    final normalizedQuery = query?.trim();
    final normalizedCategory = category?.trim();
    final normalizedSortKey = sortKey?.trim();

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (normalizedQuery != null && normalizedQuery.isNotEmpty)
        'q': normalizedQuery,
      if (normalizedCategory != null && normalizedCategory.isNotEmpty)
        'category': normalizedCategory,
      if (normalizedSortKey != null && normalizedSortKey.isNotEmpty)
        'sortKey': normalizedSortKey,
      if (reverse != null) 'reverse': reverse.toString(),
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      if (ids != null && ids.isNotEmpty) 'ids': ids,
    };

    final response = await _apiService.get(
      ApiEndpoints.products,
      queryParams: queryParams,
    );
    final data = _unwrapResponse(response);
    final productsData = _listFromResponse(data, ['products', 'items', 'results']);

    return productsData
        .map((json) {
          if (json is Map<String, dynamic>) {
            return Product.fromJson(json);
          }
          return null;
        })
        .where((p) => p != null)
        .cast<Product>()
        .toList();
  }

  Future<List<Product>> getBestSellers({int limit = 8}) async {
    final response = await _apiService.get(
      ApiEndpoints.productsBestSellers,
      queryParams: {'limit': limit.toString()},
    );
    final data = _unwrapResponse(response);
    final products = _listFromResponse(data, [
      'bestSellers',
      'best_sellers',
      'products',
      'items',
      'results',
    ]);
    return products.whereType<Map<String, dynamic>>().map(_convertToProduct).toList();
  }

  Future<List<Product>> getNewArrivals({int limit = 8}) async {
    final response = await _apiService.get(
      ApiEndpoints.productsNewArrivals,
      queryParams: {'limit': limit.toString()},
    );
    final data = _unwrapResponse(response);
    final products = _listFromResponse(data, [
      'newArrivals',
      'new_arrivals',
      'products',
      'items',
      'results',
    ]);
    return products.whereType<Map<String, dynamic>>().map(_convertToProduct).toList();
  }

  Product _convertToProduct(Map<String, dynamic> json) {
    final id = int.tryParse(json['itemId']?.toString() ??
            json['item_id']?.toString() ??
            json['id']?.toString() ??
            '0') ??
        0;
    final title = json['itemName'] ??
        json['item_name'] ??
        json['title'] ??
        json['name'] ??
        json['product_name'] ??
        json['productName'] ??
        'Untitled Product';
    final description = json['description'] as String?;
    final category =
        json['category'] ?? json['productType'] ?? json['product_type'];

    Money? priceMoney;
    final priceData = json['price'];
    if (priceData is num) {
      priceMoney = Money(amount: priceData.toDouble());
    } else if (priceData is Map<String, dynamic>) {
      priceMoney = Money.fromJson(priceData);
    }

    final available = json['availability'] ??
        json['availableForSale'] ??
        json['available_for_sale'] ??
        json['inStock'] ??
        json['in_stock'] ??
        true;

    return Product(
      id: id,
      handle: json['handle']?.toString() ?? id.toString(),
      title: title,
      description: description,
      price: priceMoney,
      productType: category as String?,
      availableForSale: available is bool ? available : true,
    );
  }

  Future<Product> getProductDetail(String handle) async {
    final response = await _apiService.get(ApiEndpoints.productDetail(handle));
    final data = _unwrapResponse(response);
    final productData = _mapFromResponse(data, ['product', 'item']) ?? data;

    if (productData['id'] == null &&
        productData['itemId'] == null &&
        productData['item_id'] == null) {
      throw FormatException('Product missing ID field');
    }

    return Product.fromJson(productData);
  }

  Future<Map<String, dynamic>> getProductReviews(String handle,
      {int page = 1}) async {
    final response = await _apiService.get(
      ApiEndpoints.productReviews(handle),
      queryParams: {'page': page.toString()},
    );
    return _unwrapResponse(response);
  }

  Future<List<Product>> getProductRecommendations(int productId,
      {int limit = 5}) async {
    final response = await _apiService.get(
      ApiEndpoints.productRecommendations(productId),
      queryParams: {'limit': limit.toString()},
    );
    final data = _unwrapResponse(response);
    final products = _listFromResponse(data, [
      'products',
      'recommendations',
      'items',
      'results',
    ]);
    return products.whereType<Map<String, dynamic>>().map(Product.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _apiService.get(ApiEndpoints.categories);
    final data = _unwrapResponse(response);
    final categories = _listFromResponse(data, ['categories', 'items']);
    return categories.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getCategoryDetail(String handle) async {
    return await _apiService.get(ApiEndpoints.categoryDetail(handle));
  }

  Future<List<Map<String, dynamic>>> getCollections() async {
    final response = await _apiService.get(ApiEndpoints.collections);
    final data = _unwrapResponse(response);
    final collections = _listFromResponse(data, ['collections', 'items']);
    return collections.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getCollectionDetail(String handle) async {
    return await _apiService.get(ApiEndpoints.collectionDetail(handle));
  }

  Future<List<Product>> getCollectionProducts(String handle) async {
    final response = await _apiService.get(ApiEndpoints.collectionProducts(handle));
    final data = _unwrapResponse(response);
    final products = _listFromResponse(data, ['products', 'items', 'results']);
    return products.whereType<Map<String, dynamic>>().map(Product.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getOrderSteps(
      {String? type, bool? grouped}) async {
    final queryParams = <String, String>{
      if (type != null) 'type': type,
      if (grouped != null) 'grouped': grouped.toString(),
    };

    final response = await _apiService.get(
      ApiEndpoints.orderSteps,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = _unwrapResponse(response);
    final steps = _listFromResponse(data, ['steps', 'order_steps', 'items']);
    return steps.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> getMaterials() async {
    final response = await _apiService.get(ApiEndpoints.materials);
    final data = _unwrapResponse(response);
    final materials = _listFromResponse(data, ['materials', 'items']);
    return materials.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getPage(String handle) async {
    final response = await _apiService.get(ApiEndpoints.pageDetail(handle));
    final data = _unwrapResponse(response);
    final page = _mapFromResponse(data, ['page', 'content']) ?? data;
    return page;
  }

  Future<List<Map<String, dynamic>>> getPortfolios() async {
    final response = await _apiService.get(ApiEndpoints.portfolios);
    final data = _unwrapResponse(response);
    final portfolios = _listFromResponse(data, ['portfolios', 'items']);
    return portfolios.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getPortfolioDetail(String slug) async {
    return await _apiService.get(ApiEndpoints.portfolioDetail(slug));
  }

  Future<Map<String, dynamic>> getMenu(String handle) async {
    return await _apiService.get(ApiEndpoints.menuDetail(handle));
  }

  Future<void> addReview(String handle,
      {required int rating, required String comment}) async {
    await _apiService.post(
      ApiEndpoints.addReview(handle),
      body: {
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<Map<String, dynamic>> getSiteSettings() async {
    final response = await _apiService.get(ApiEndpoints.siteSettings);
    return _unwrapResponse(response);
  }

  Future<List<Map<String, dynamic>>> getPages() async {
    final response = await _apiService.get(ApiEndpoints.pages);
    final data = _unwrapResponse(response);
    final pages = _listFromResponse(data, ['pages', 'items', 'results']);
    return pages.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getTeamMemberPhoto(int id) async {
    final response = await _apiService.get(ApiEndpoints.teamMemberPhoto(id));
    return _unwrapResponse(response);
  }

  Future<List<Product>> getUserRecommendations({int limit = 10}) async {
    final response = await _apiService.get(
      ApiEndpoints.recommendations,
      queryParams: {'limit': limit.toString()},
      requiresAuth: true,
    );
    final data = _unwrapResponse(response);
    final products = _listFromResponse(data, [
      'products',
      'recommendations',
      'items',
      'results',
    ]);
    return products.whereType<Map<String, dynamic>>().map(Product.fromJson).toList();
  }

  Future<void> trackInteractions(List<Map<String, dynamic>> interactions) async {
    await _apiService.post(
      ApiEndpoints.interactionsBatch,
      body: {'interactions': interactions},
      requiresAuth: true,
    );
  }
}
