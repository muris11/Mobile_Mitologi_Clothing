import 'dart:developer';

import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/data/wishlist_service.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/domain/models/wishlist_item.dart';

class WishlistRepository {
  final WishlistService _wishlistService;

  WishlistRepository(this._wishlistService);

  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _wishlistService.getWishlist();
      final data = response.data;

      List items = [];
      if (data is Map<String, dynamic>) {
        items = data['data'] ?? data['items'] ?? data['wishlist'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return ParserUtils.parseList(items, WishlistItem.fromJson);
    } catch (e) {
      log('Error getting wishlist: $e');
      return [];
    }
  }

  Future<bool> toggleWishlist(int productId) async {
    try {
      final response = await _wishlistService.toggleWishlist(productId);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ParserUtils.parseBool(
            data['in_wishlist'] ?? data['is_wishlisted'] ?? data['success']);
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('Error toggling wishlist: $e');
      return false;
    }
  }

  Future<bool> isInWishlist(int productId) async {
    try {
      final response = await _wishlistService.checkWishlist(productId);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ParserUtils.parseBool(
            data['in_wishlist'] ?? data['is_wishlisted']);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
