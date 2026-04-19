import '../../../services/wishlist_service.dart';
import '../presentation/wishlist_provider.dart';

class WishlistServiceAdapter implements WishlistDataSource {
  final WishlistService _service;

  WishlistServiceAdapter(this._service);

  @override
  Future<List<int>> fetchWishlistIds() async {
    final items = await _service.getWishlist();
    return items.map((p) => p.id).toList();
  }

  @override
  Future<void> remove(int productId) async {
    await _service.removeFromWishlist(productId);
  }

  @override
  Future<void> save(int productId) async {
    await _service.addToWishlist(productId);
  }
}
