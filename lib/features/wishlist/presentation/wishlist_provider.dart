import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/data/wishlist_repository.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/domain/models/wishlist_item.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _repository;

  WishlistProvider(this._repository);

  List<WishlistItem> _items = [];
  Set<int> _wishlistedIds = {};
  bool _isLoading = false;
  String? _error;

  List<WishlistItem> get items => _items;
  Set<int> get wishlistedIds => _wishlistedIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getWishlist();
      _wishlistedIds = _items.map((e) => e.productId).toSet();
    } catch (e) {
      _error = 'Gagal memuat wishlist. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleWishlist(int productId) async {
    final wasInWishlist = _wishlistedIds.contains(productId);
    if (wasInWishlist) {
      _wishlistedIds.remove(productId);
      _items.removeWhere((item) => item.productId == productId);
    } else {
      _wishlistedIds.add(productId);
    }
    notifyListeners();

    try {
      final success = wasInWishlist
          ? await _repository.removeFromWishlist(productId)
          : await _repository.addToWishlist(productId);

      if (!success) {
        if (wasInWishlist) {
          _wishlistedIds.add(productId);
        } else {
          _wishlistedIds.remove(productId);
        }
        notifyListeners();
      }

      return success;
    } catch (e) {
      if (wasInWishlist) {
        _wishlistedIds.add(productId);
      } else {
        _wishlistedIds.remove(productId);
      }
      notifyListeners();
      return wasInWishlist;
    }
  }

  bool isInWishlist(int productId) {
    return _wishlistedIds.contains(productId);
  }
}
