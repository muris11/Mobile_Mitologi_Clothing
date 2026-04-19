import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';

class ToggleSource implements WishlistDataSource {
  final List<int> _ids = [];

  @override
  Future<List<int>> fetchWishlistIds() async => List<int>.from(_ids);

  @override
  Future<void> remove(int productId) async {
    _ids.remove(productId);
  }

  @override
  Future<void> save(int productId) async {
    if (!_ids.contains(productId)) {
      _ids.add(productId);
    }
  }
}

void main() {
  test('toggle adds and removes product deterministically', () async {
    final provider = WishlistProvider(ToggleSource());

    await provider.load();
    await provider.toggle(10);
    expect(provider.ids.contains(10), isTrue);

    await provider.toggle(10);
    expect(provider.ids.contains(10), isFalse);
  });
}
