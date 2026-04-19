import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

/// Service for wishlist operations
class WishlistService {
  final ApiService _apiService;

  WishlistService(this._apiService);

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _listFromResponse(
      Map<String, dynamic> response, List<String> keys) {
    for (final key in keys) {
      final value = response[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = value['items'] ??
            value['wishlist_items'] ??
            value['products'] ??
            value['data'];
        if (nested is List) return nested;
      }
    }
    return const [];
  }

  bool _boolFromResponse(Map<String, dynamic> response, List<String> keys) {
    for (final key in keys) {
      final value = response[key];
      if (value is bool) return value;
    }
    return false;
  }

  /// Get wishlist items
  Future<List<Product>> getWishlist() async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) return [];

    try {
      final response = await _apiService.get(
        ApiEndpoints.wishlist,
        requiresAuth: true,
        authToken: token,
      );

      final data = _unwrapResponse(response);
      final products = _listFromResponse(data, [
        'wishlist',
        'wishlist_items',
        'products',
        'items',
        'results',
      ]);

      return products
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add product to wishlist
  Future<bool> addToWishlist(int productId) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) return false;

    try {
      final response = await _apiService.post(
        ApiEndpoints.wishlistItem(productId),
        requiresAuth: true,
        authToken: token,
      );

      final data = _unwrapResponse(response);
      return _boolFromResponse(data, [
            'success',
            'isWishlisted',
            'is_wishlist',
            'inWishlist',
            'in_wishlist',
          ]) ||
          response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Remove product from wishlist
  Future<bool> removeFromWishlist(int productId) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) return false;

    try {
      final response = await _apiService.delete(
        ApiEndpoints.wishlistItem(productId),
        requiresAuth: true,
        authToken: token,
      );

      final data = _unwrapResponse(response);
      return _boolFromResponse(data, [
            'success',
            'removed',
            'deleted',
          ]) ||
          response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(int productId) async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null) return false;

    try {
      final response = await _apiService.get(
        ApiEndpoints.wishlistCheck(productId),
        requiresAuth: true,
        authToken: token,
      );

      final data = _unwrapResponse(response);
      return data['isWishlisted'] == true ||
          data['is_wishlist'] == true ||
          data['inWishlist'] == true ||
          data['in_wishlist'] == true ||
          data['wishlist'] == true ||
          data['exists'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle wishlist status
  Future<bool> toggleWishlist(int productId) async {
    final currentlyInWishlist = await isInWishlist(productId);

    if (currentlyInWishlist) {
      await removeFromWishlist(productId);
      return false;
    } else {
      await addToWishlist(productId);
      return true;
    }
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    final wishlist = await getWishlist();
    return wishlist.length;
  }
}
