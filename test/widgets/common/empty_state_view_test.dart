import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state_view.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('EmptyStateView', () {
    testWidgets('renders with default icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Data Kosong',
              description: 'Belum ada data tersedia',
              actionLabel: 'Muat Ulang',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('Data Kosong'), findsOneWidget);
      expect(find.text('Belum ada data tersedia'), findsOneWidget);
      expect(find.text('Muat Ulang'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders with custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'No WiFi',
              description: 'Tidak ada koneksi',
              actionLabel: 'Retry',
              onAction: () {},
              icon: Icons.wifi_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('calls onAction when button pressed', (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Test',
              description: 'Desc',
              actionLabel: 'Action',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Test',
              description: 'Desc',
              actionLabel: 'Action',
              onAction: () {},
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(Padding).first,
        ),
      );
      expect(padding.padding, const EdgeInsets.all(32));
    });
  });
}
