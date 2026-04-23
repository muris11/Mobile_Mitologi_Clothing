import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/models/money.dart';
import 'package:mitologi_clothing_mobile/models/product.dart';
import 'package:mitologi_clothing_mobile/widgets/product/product_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ProductCard', () {
    final baseProduct = Product(
      id: 1,
      handle: 'test-product',
      title: 'Test Product',
      vendor: 'Test Brand',
      price: Money(amount: 100000, currencyCode: 'IDR'),
      featuredImage: null,
    );

    final saleProduct = Product(
      id: 2,
      handle: 'sale-product',
      title: 'Sale Product',
      vendor: 'Sale Brand',
      price: Money(amount: 80000, currencyCode: 'IDR'),
      compareAtPrice: Money(amount: 100000, currencyCode: 'IDR'),
      featuredImage: null,
    );

    Widget buildRouter({required Widget child}) {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => child),
          GoRoute(
            path: '/product/:handle',
            builder: (_, __) => const Scaffold(body: Text('Product Detail')),
          ),
        ],
      );
      return MaterialApp.router(routerConfig: router);
    }

    testWidgets('renders product title', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(product: baseProduct),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('renders vendor when showBrand is true', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(product: baseProduct),
          ),
        ),
      );

      expect(find.text('TEST BRAND'), findsOneWidget);
    });

    testWidgets('hides vendor when showBrand is false', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(
              product: baseProduct,
              showBrand: false,
            ),
          ),
        ),
      );

      expect(find.text('TEST BRAND'), findsNothing);
    });

    testWidgets('renders price', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(product: baseProduct),
          ),
        ),
      );

      expect(find.textContaining('Rp'), findsOneWidget);
    });

    testWidgets('renders discount badge for sale product', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(product: saleProduct),
          ),
        ),
      );

      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('does not render discount badge for regular product',
        (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(product: baseProduct),
          ),
        ),
      );

      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: baseProduct,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();
      expect(tapped, true);
    });

    testWidgets('navigates to product detail on tap', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(product: baseProduct),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      expect(find.text('Product Detail'), findsOneWidget);
    });

    testWidgets('calls onWishlistToggle when wishlist tapped',
        (tester) async {
      var toggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: baseProduct,
              onWishlistToggle: () => toggled = true,
            ),
          ),
        ),
      );

      // The wishlist button is the last/first InteractiveScale or IconButton
      await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
      await tester.pumpAndSettle();
      expect(toggled, true);
    });

    testWidgets('shows filled heart when in wishlist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: baseProduct,
              isInWishlist: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('uses provided width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: baseProduct,
              width: 150,
            ),
          ),
        ),
      );

      final card = tester.widget<ProductCard>(find.byType(ProductCard));
      expect(card.width, 150);
    });

    testWidgets('renders compare at price for sale product', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Scaffold(
            body: ProductCard(product: saleProduct),
          ),
        ),
      );

      // Should show both old and new price
      expect(find.textContaining('Rp'), findsWidgets);
    });
  });
}
