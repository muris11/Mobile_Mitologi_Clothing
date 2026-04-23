import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/widgets/common/error_state_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ErrorStateCard', () {
    testWidgets('renders with default title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateCard(
              message: 'Gagal memuat data',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders with custom title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateCard(
              title: 'Kesalahan Jaringan',
              message: 'Tidak dapat terhubung',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kesalahan Jaringan'), findsOneWidget);
      expect(find.text('Tidak dapat terhubung'), findsOneWidget);
    });

    testWidgets('calls onRetry when button pressed', (WidgetTester tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateCard(
              message: 'Error',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('has container with margin and padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateCard(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.margin, const EdgeInsets.all(16));
      expect(container.padding, const EdgeInsets.all(20));
    });
  });
}
