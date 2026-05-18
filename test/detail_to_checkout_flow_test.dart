import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';
import 'package:mitologi_clothing_mobile/features/cart/domain/models/cart_model.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/views/cart_view.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_repository.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_service.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/product_detail_view.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/checkout_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Product detail flows to cart and checkout without exceptions',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/product/kala-makara-snapback-cap',
      routes: [
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
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider<CartViewModel>(
                create: (_) => _FakeCartViewModel()..seedCart(),
              ),
            ],
            child: const CartView(),
          ),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider<CartViewModel>(
                create: (_) => _FakeCartViewModel()..seedCart(),
              ),
              ChangeNotifierProvider<CheckoutViewModel>(
                create: (_) => _FakeCheckoutViewModel()..seedAddresses(),
              ),
            ],
            child: const CheckoutView(),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Description'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('BELI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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

  void seedCart() {
    _cartInternal = _cart;
  }

  CartModel? _cartInternal;

  @override
  CartModel? get cart => _cartInternal;

  @override
  bool get isLoading => false;

  @override
  Future<void> addToCart({required int quantity, required int variantId}) async {
    _cartInternal = _cart;
    notifyListeners();
  }

  @override
  Future<void> fetchCart() async {}
}

class _FakeCheckoutViewModel extends CheckoutViewModel {
  _FakeCheckoutViewModel()
      : super(
          CheckoutRepository(
            CheckoutService(ApiClient(TokenStorage(), CartStorage())),
          ),
        );

  void seedAddresses() {
    _addressesInternal = _addresses;
    _selectedAddressInternal = _addresses.first;
  }

  List<AddressModel> _addressesInternal = [];
  AddressModel? _selectedAddressInternal;

  @override
  List<AddressModel> get addresses => _addressesInternal;

  @override
  AddressModel? get selectedAddress => _selectedAddressInternal;

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchAddresses() async {}

  @override
  Future<PlaceOrderResult> placeOrder() async => PlaceOrderResult.success;

  @override
  void selectAddress(AddressModel address) {
    _selectedAddressInternal = address;
    notifyListeners();
  }
}

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

const _cart = CartModel(
  id: 'cart-1',
  items: [
    CartItemModel(
      id: 1,
      productId: 1,
      name: 'Kala Makara Snapback Cap',
      price: 129000,
      quantity: 1,
      featuredImageUrl: 'https://example.com/image.jpg',
    ),
  ],
  totalPrice: 129000,
  totalItems: 1,
);

const _addresses = [
  AddressModel(
    id: 1,
    label: 'Rumah',
    recipientName: 'Rifqy',
    phone: '081234567890',
    address: 'Jl. Mitologi No. 1',
    city: 'Cirebon',
    province: 'Jawa Barat',
    postalCode: '45111',
    isDefault: true,
  ),
];
