import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AnimatedEmptyState', () {
    testWidgets('renders all elements', (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Keranjang Kosong',
              subtitle: 'Belum ada barang di keranjang',
              actionLabel: 'Belanja Sekarang',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.text('Keranjang Kosong'), findsOneWidget);
      expect(find.text('Belum ada barang di keranjang'), findsOneWidget);
      expect(find.text('Belanja Sekarang'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onAction when button pressed', (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyState(
              icon: Icons.inbox,
              title: 'Title',
              subtitle: 'Subtitle',
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

    testWidgets('uses custom icon color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyState(
              icon: Icons.star,
              title: 'Title',
              subtitle: 'Subtitle',
              actionLabel: 'Action',
              onAction: () {},
              iconColor: Colors.red,
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(iconWidget.color, Colors.red);
    });
  });

  group('LoginRequiredState', () {
    testWidgets('renders with lock icon and login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginRequiredState(
              title: 'Login Diperlukan',
              subtitle: 'Silakan login untuk melanjutkan',
              onLogin: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Login Diperlukan'), findsOneWidget);
      expect(find.text('Silakan login untuk melanjutkan'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('renders error icon and retry button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Gagal memuat data',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('calls onRetry when button pressed', (WidgetTester tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });
  });
}
