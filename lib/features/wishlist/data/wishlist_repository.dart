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
      if (data is Map) {
        final map = ParserUtils.parseMap(data);
        items = map['data'] ?? map['items'] ?? map['wishlist'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return ParserUtils.parseList(items, WishlistItem.fromJson);
    } catch (e) {
      log('Error getting wishlist: $e');
      return [];
    }
  }

  Future<bool> addToWishlist(int productId) async {
    try {
      final response = await _wishlistService.addToWishlist(productId);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('Error adding to wishlist: $e');
      return false;
    }
  }

  Future<bool> removeFromWishlist(int productId) async {
    try {
      final response = await _wishlistService.removeFromWishlist(productId);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('Error removing from wishlist: $e');
      return false;
    }
  }

  Future<bool> isInWishlist(int productId) async {
    try {
      final response = await _wishlistService.checkWishlist(productId);
      final data = response.data;
      if (data is Map) {
        final map = ParserUtils.parseMap(data);
        final innerData = ParserUtils.parseMap(map['data']);
        final raw = innerData['isWishlisted'] ?? innerData['is_wishlisted'] ?? innerData['in_wishlist'];
        if (raw != null) {
          return ParserUtils.parseBool(raw);
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
