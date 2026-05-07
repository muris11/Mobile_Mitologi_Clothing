import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_repository.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_service.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/product_detail_view.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_repository.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_service.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/home_data_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/views/home_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Home product opens product detail without exceptions',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeViewModel>(
                create: (_) => _FakeHomeViewModel()..seed(),
              ),
              ChangeNotifierProvider<CatalogViewModel>(
                create: (_) => _FakeCatalogViewModel(),
              ),
              ChangeNotifierProvider<CartViewModel>(
                create: (_) => _FakeCartViewModel(),
              ),
            ],
            child: const HomeView(),
          ),
        ),
        GoRoute(
          path: '/product/:slug',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider<CatalogViewModel>(
                create: (_) => _FakeCatalogViewModel(),
              ),
              ChangeNotifierProvider<CartViewModel>(
                create: (_) => _FakeCartViewModel(),
              ),
            ],
            child: ProductDetailView(slug: state.pathParameters['slug']!),
          ),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/portfolio',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/tentang-kami',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/kontak',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Kala Makara'), findsWidgets);

    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -900));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Kala Makara Snapback Cap').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Description'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeHomeViewModel extends HomeViewModel {
  _FakeHomeViewModel()
      : super(
          HomeRepository(HomeService(ApiClient(TokenStorage(), CartStorage()))),
        );

  void seed() {
    _homeDataInternal = HomeDataModel(
      banners: const [],
      categories: const [],
      bestSellers: const [_product],
      newArrivals: const [],
      features: const [],
      testimonials: const [],
      materials: const [],
      portfolioItems: const [],
      partners: const [],
      printingMethods: const [],
      facilities: const [],
      teamMembers: const [],
      productPricings: const [],
      orderSteps: const [],
    );
  }

  HomeDataModel _homeDataInternal = HomeDataModel.empty();

  @override
  bool get isLoading => false;

  @override
  HomeDataModel get homeData => _homeDataInternal;

  @override
  List<ProductModel> get bestSellers => _homeDataInternal.bestSellers;

  @override
  List<ProductModel> get newArrivals => _homeDataInternal.newArrivals;

  @override
  Future<void> fetchHomeData() async {}
}

class _FakeCatalogViewModel extends CatalogViewModel {
  _FakeCatalogViewModel()
      : super(
          CatalogRepository(
            CatalogService(ApiClient(TokenStorage(), CartStorage())),
          ),
        );

  ProductDetailModel? _selected;

  @override
  ProductDetailModel? get selectedProduct => _selected;

  @override
  bool get isLoading => false;

  @override
  Future<void> getProductDetail(String slug) async {
    _selected = _detail;
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

const _product = ProductModel(
  id: 1,
  name: 'Kala Makara Snapback Cap',
  slug: 'kala-makara-snapback-cap',
  description: 'Topi premium.',
  price: 129000,
  featuredImageUrl: 'https://example.com/image.jpg',
  stock: 10,
);

const _detail = ProductDetailModel(
  id: 1,
  name: 'Kala Makara Snapback Cap',
  slug: 'kala-makara-snapback-cap',
  description: 'Topi premium dengan detail bordir.',
  price: 129000,
  featuredImageUrl: 'https://example.com/image.jpg',
  stock: 10,
  images: ['https://example.com/image.jpg'],
  variants: [],
  reviews: [],
  relatedProducts: [],
);
