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
    final removed = await _service.removeFromWishlist(productId);
    if (!removed) {
      throw Exception('Gagal menghapus produk dari wishlist');
    }
  }

  @override
  Future<void> save(int productId) async {
    final saved = await _service.addToWishlist(productId);
    if (!saved) {
      throw Exception('Gagal menambahkan produk ke wishlist');
    }
  }
}
