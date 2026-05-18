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
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/catalog_view.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_repository.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_service.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CatalogView shows error state on failure', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<CatalogViewModel>(
              create: (_) => _ThrowingCatalogViewModel(),
            ),
            ChangeNotifierProvider<HomeViewModel>(
              create: (_) => _FakeHomeViewModel(),
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

    expect(find.text('Gagal memuat produk'), findsOneWidget);
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
  Future<void> searchProducts({String? query, String? categoryHandle, String? sortKey, bool reverse = false, double? minPrice, double? maxPrice, bool refresh = true}) async {
    _errorInternal = 'Gagal memuat produk. Silakan coba lagi';
    _isLoadingInternal = false;
    notifyListeners();
  }
}

class _FakeHomeViewModel extends HomeViewModel {
  _FakeHomeViewModel()
      : super(
          HomeRepository(HomeService(ApiClient(TokenStorage(), CartStorage()))),
        );

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchHomeData() async {}
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
