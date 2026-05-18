import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/auth/data/auth_repository.dart';
import 'package:mitologi_clothing_mobile/features/auth/data/auth_service.dart';
import 'package:mitologi_clothing_mobile/features/auth/presentation/auth_view_model.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/checkout_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CheckoutView shows premium empty-cart heading', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
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
              ChangeNotifierProvider<AuthViewModel>(
                create: (_) => _FakeAuthViewModel(),
              ),
              ChangeNotifierProvider<CartViewModel>(
                create: (_) => _EmptyCartViewModel(),
              ),
              ChangeNotifierProvider<CheckoutViewModel>(
                create: (_) => _FakeCheckoutViewModel(),
              ),
            ],
            child: const CheckoutView(),
          ),
        ),
        GoRoute(path: '/products', builder: (_, __) => const Scaffold()),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Keranjang kosong'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeAuthViewModel extends AuthViewModel {
  _FakeAuthViewModel()
      : super(AuthRepository(
            AuthService(ApiClient(TokenStorage(), CartStorage())),
            TokenStorage()));

  @override
  bool get isAuthenticated => true;
}

class _EmptyCartViewModel extends CartViewModel {
  _EmptyCartViewModel()
      : super(
          CartRepository(
            CartService(ApiClient(TokenStorage(), CartStorage())),
            CartStorage(),
          ),
        );

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

  @override
  bool get isAddressesLoading => false;

  @override
  Future<void> fetchAddresses() async {}
}
