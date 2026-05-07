import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_repository.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_service.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/catalog_view.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_repository.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_service.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/category_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CatalogView grid renders product cards without overflow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<CatalogViewModel>(
              create: (_) => _FakeCatalogViewModel()..seedProducts(_products),
            ),
            ChangeNotifierProvider<HomeViewModel>(
              create: (_) => _FakeHomeViewModel()..seedCategories(_categories),
            ),
            ChangeNotifierProvider<CartViewModel>(
              create: (_) => _FakeCartViewModel(),
            ),
          ],
          builder: (context, child) => const CatalogView(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Katalog Produk'), findsOneWidget);
    expect(find.textContaining('Kala Makara'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class _FakeCatalogViewModel extends CatalogViewModel {
  _FakeCatalogViewModel()
      : super(
          _FakeCatalogRepository(),
        );

  void seedProducts(List<ProductModel> products) {
    _productsInternal = products;
    _isLoadingInternal = false;
    _hasMoreInternal = false;
  }

  List<ProductModel> _productsInternal = [];
  bool _isLoadingInternal = false;
  bool _hasMoreInternal = false;

  @override
  List<ProductModel> get products => _productsInternal;

  @override
  bool get isLoading => _isLoadingInternal;

  @override
  bool get hasMore => _hasMoreInternal;

  @override
  Future<void> searchProducts({String? query, int? categoryId, String? sort, bool refresh = true}) async {}
}

class _FakeHomeViewModel extends HomeViewModel {
  _FakeHomeViewModel()
      : super(
          _FakeHomeRepository(),
        );

  List<CategoryModel> _categoriesInternal = [];

  void seedCategories(List<CategoryModel> categories) {
    _categoriesInternal = categories;
  }

  @override
  List<CategoryModel> get categories => _categoriesInternal;

  @override
  bool get isLoading => false;
}

class _FakeCartViewModel extends CartViewModel {
  _FakeCartViewModel()
      : super(
          _FakeCartRepository(),
        );
}

class _FakeCatalogRepository extends CatalogRepository {
  _FakeCatalogRepository()
      : super(
          CatalogService(ApiClient(TokenStorage(), CartStorage())),
        );
}

class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository()
      : super(
          HomeService(ApiClient(TokenStorage(), CartStorage())),
        );
}

class _FakeCartRepository extends CartRepository {
  _FakeCartRepository()
      : super(
          CartService(ApiClient(TokenStorage(), CartStorage())),
          CartStorage(),
        );
}

const _categories = [
  CategoryModel(id: 1, name: 'Topi', slug: 'topi', iconUrl: null),
  CategoryModel(id: 2, name: 'Kaos', slug: 'kaos', iconUrl: null),
];

const _products = [
  ProductModel(
    id: 1,
    name: 'Kala Makara Snapback Cap Premium Edition',
    slug: 'kala-makara-snapback-cap-premium',
    description: 'Topi premium dengan detail bordir.',
    price: 129000,
    featuredImageUrl: 'https://example.com/image.jpg',
    stock: 3,
    reviewsCount: 0,
    vendor: 'Mitologi Clothing',
  ),
  ProductModel(
    id: 2,
    name: 'Mitologi Heavyweight Tee Shadow Myth',
    slug: 'mitologi-heavyweight-tee-shadow-myth',
    description: 'Kaos heavyweight.',
    price: 159000,
    featuredImageUrl: 'https://example.com/image2.jpg',
    stock: 8,
    reviewsCount: 12,
    rating: 4.8,
    vendor: 'Mitologi Clothing',
  ),
];
