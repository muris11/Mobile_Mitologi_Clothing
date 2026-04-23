import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/models/cart.dart';
import 'package:mitologi_clothing_mobile/models/money.dart';
import 'package:mitologi_clothing_mobile/providers/cart_provider.dart';
import 'package:mitologi_clothing_mobile/screens/cart/cart_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';

class _FakeCartService extends CartService {
  _FakeCartService() : super(ApiService());

  @override
  Future<Cart> getCart() async {
    await Future.delayed(Duration.zero);
    return Cart(id: 'test_cart', items: []);
  }
}

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('CartScreen loads without error', (tester) async {
    final fakeCartService = _FakeCartService();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => CartProvider(fakeCartService),
          child: const CartScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should render without throwing (at least one scaffold present)
    expect(find.byType(Scaffold), findsWidgets);
  });
}
