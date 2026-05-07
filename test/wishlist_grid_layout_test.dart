import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/data/wishlist_repository.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/data/wishlist_service.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/domain/models/wishlist_item.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('WishlistScreen grid renders product cards without overflow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<WishlistProvider>(
              create: (_) => _FakeWishlistProvider()..seedItems(_items),
            ),
            ChangeNotifierProvider<CartViewModel>(
              create: (_) => _FakeCartViewModel(),
            ),
          ],
          builder: (context, child) => const WishlistScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('WISHLIST'), findsOneWidget);
    expect(find.textContaining('Kala Makara'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class _FakeWishlistProvider extends WishlistProvider {
  _FakeWishlistProvider()
      : super(
          WishlistRepository(
            WishlistService(ApiClient(TokenStorage(), CartStorage())),
          ),
        );

  List<WishlistItem> _itemsInternal = [];

  void seedItems(List<WishlistItem> items) {
    _itemsInternal = items;
  }

  @override
  List<WishlistItem> get items => _itemsInternal;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<void> loadWishlist() async {}
}

class _FakeCartViewModel extends CartViewModel {
  _FakeCartViewModel()
      : super(
          CartRepository(
            CartService(ApiClient(TokenStorage(), CartStorage())),
            CartStorage(),
          ),
        );
}

const _items = [
  WishlistItem(
    id: 1,
    productId: 1,
    name: 'Kala Makara Snapback Cap Premium Edition',
    slug: 'kala-makara-snapback-cap-premium',
    price: 129000,
    featuredImageUrl: 'https://example.com/image.jpg',
    vendor: 'Mitologi Clothing',
  ),
  WishlistItem(
    id: 2,
    productId: 2,
    name: 'Mitologi Heavyweight Tee Shadow Myth',
    slug: 'mitologi-heavyweight-tee-shadow-myth',
    price: 159000,
    featuredImageUrl: 'https://example.com/image2.jpg',
    vendor: 'Mitologi Clothing',
  ),
];
