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
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/checkout_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Cart flows to checkout without exceptions', (tester) async {
    final router = GoRouter(
      initialLocation: '/cart',
      routes: [
        GoRoute(
          path: '/cart',
          builder: (context, state) => ChangeNotifierProvider<CartViewModel>(
            create: (_) => _FakeCartViewModel()..seedCart(),
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

    expect(find.text('Keranjang'), findsOneWidget);

    await tester.tap(find.text('CHECKOUT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeCartViewModel extends CartViewModel {
  _FakeCartViewModel()
      : super(
          CartRepository(
            CartService(ApiClient(TokenStorage(), CartStorage())),
            CartStorage(),
          ),
        );

  CartModel? _cartInternal;

  void seedCart() {
    _cartInternal = _cart;
  }

  @override
  CartModel? get cart => _cartInternal;

  @override
  bool get isLoading => false;

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

  List<AddressModel> _addressesInternal = [];
  AddressModel? _selectedAddressInternal;

  void seedAddresses() {
    _addressesInternal = _addresses;
    _selectedAddressInternal = _addresses.first;
  }

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
  }
}

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
