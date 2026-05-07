import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/widgets/product/product_card.dart';

void main() {
  testWidgets('ProductCard does not overflow in compact grid constraints',
      (tester) async {
    const product = ProductModel(
      id: 1,
      name: 'Kala Makara Snapback Cap Premium Edition',
      slug: 'kala-makara-snapback-cap-premium',
      description: 'Topi premium dengan detail bordir.',
      price: 129000,
      featuredImageUrl: 'https://example.com/image.jpg',
      stock: 3,
      reviewsCount: 0,
      vendor: 'Mitologi Clothing',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 172,
              height: 280,
              child: ProductCard(product: product),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Kala Makara'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
