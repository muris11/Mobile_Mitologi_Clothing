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
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/product_detail_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ProductDetailView shows error state on failure', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<CatalogViewModel>(
              create: (_) => _ThrowingCatalogViewModel(),
            ),
            ChangeNotifierProvider<CartViewModel>(
              create: (_) => _FakeCartViewModel(),
            ),
          ],
          builder: (context, child) => const ProductDetailView(slug: 'unknown-product'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Product not found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ThrowingCatalogViewModel extends CatalogViewModel {
  _ThrowingCatalogViewModel()
      : super(
          CatalogRepository(
            CatalogService(ApiClient(TokenStorage(), CartStorage())),
          ),
        );

  bool _isLoadingInternal = false;
  String? _errorInternal;

  @override
  bool get isLoading => _isLoadingInternal;

  @override
  String? get error => _errorInternal;

  @override
  Future<void> getProductDetail(String slug) async {
    _errorInternal = 'Produk tidak ditemukan';
    _isLoadingInternal = false;
    notifyListeners();
  }
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
