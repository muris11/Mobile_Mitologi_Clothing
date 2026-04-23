import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/widgets/common/section_header.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SectionHeader', () {
    testWidgets('renders title only when onSeeAll is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(title: 'Produk Terbaru'),
          ),
        ),
      );

      expect(find.text('Produk Terbaru'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsNothing);
    });

    testWidgets('renders title and see all button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Kategori',
              onSeeAll: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsOneWidget);
    });

    testWidgets('calls onSeeAll when tapped', (WidgetTester tester) async {
      bool seeAllCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Test',
              onSeeAll: () => seeAllCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Lihat Semua'));
      await tester.pump();

      expect(seeAllCalled, isTrue);
    });

    testWidgets('uses Row layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Test',
              onSeeAll: () {},
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    });
  });
}
