import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';

class FakeWishlistSource implements WishlistDataSource {
  List<int> ids = [];
  Exception? error;

  @override
  Future<List<int>> fetchWishlistIds() async {
    if (error != null) throw error!;
    return ids;
  }

  @override
  Future<void> remove(int productId) async {
    ids.remove(productId);
  }

  @override
  Future<void> save(int productId) async {
    if (!ids.contains(productId)) ids.add(productId);
  }
}

void main() {
  group('WishlistProvider', () {
    test('loads wishlist ids', () async {
      final source = FakeWishlistSource()..ids = [1, 2];
      final provider = WishlistProvider(source);

      await provider.load();

      expect(provider.ids, {1, 2});
      expect(provider.error, isNull);
    });

    test('toggles product in wishlist', () async {
      final source = FakeWishlistSource()..ids = [1];
      final provider = WishlistProvider(source);

      await provider.load();
      await provider.toggle(2);
      await provider.toggle(1);

      expect(provider.ids, {2});
    });
  });
}
