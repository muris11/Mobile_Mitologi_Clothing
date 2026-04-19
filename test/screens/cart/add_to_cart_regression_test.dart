import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/config/theme.dart';
import 'package:mitologi_clothing_mobile/models/product.dart';

class _FakeAddToCartHarness extends StatefulWidget {
  const _FakeAddToCartHarness();

  @override
  State<_FakeAddToCartHarness> createState() => _FakeAddToCartHarnessState();
}

class _FakeAddToCartHarnessState extends State<_FakeAddToCartHarness> {
  int callCount = 0;
  String? lastMerchandiseId;

  Future<void> addFromProductDetail(Product product) async {
    final merchandiseId = product.firstVariant?.id;

    if (merchandiseId == null || merchandiseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Varian produk tidak valid',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      callCount += 1;
      lastMerchandiseId = merchandiseId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = Product(
      id: 1,
      handle: 'hanoman-hoodie',
      title: 'Hanoman Hoodie',
      variants: [
        ProductVariant(id: 'variant_123', title: 'M / Black'),
      ],
    );

    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => addFromProductDetail(product),
            child: const Text('Keranjang'),
          ),
          Text('count:$callCount'),
          Text('id:${lastMerchandiseId ?? '-'}'),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('tap Keranjang memakai variant id valid', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: _FakeAddToCartHarness()),
    );

    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();

    expect(find.text('count:1'), findsOneWidget);
    expect(find.text('id:variant_123'), findsOneWidget);
  });
}
