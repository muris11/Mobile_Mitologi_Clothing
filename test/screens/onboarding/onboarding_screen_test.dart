import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/screens/onboarding/onboarding_screen.dart';

import '../../helpers/test_binding.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
    setupMockSecureStorage();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    clearMockStorage();
  });

  Widget buildRouter({required Widget child, String initialLocation = '/'}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, __) => child),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  /// Fling PageView to next page with high velocity to ensure snap.
  /// Uses pump(Duration) instead of pumpAndSettle because
  /// CachedNetworkImage placeholder has an infinite CircularProgressIndicator
  /// animation which would cause pumpAndSettle to time out.
  Future<void> flingToNextPage(WidgetTester tester) async {
    await tester.fling(
      find.byType(PageView),
      const Offset(-400, 0),
      2000,
    );
    // Allow PageView snap + page transition animation to settle
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 200));
  }

  group('OnboardingScreen', () {
    testWidgets('renders first page', (tester) async {
      await tester.pumpWidget(
        buildRouter(child: const OnboardingScreen()),
      );

      expect(find.text('The Tactile Atelier'), findsOneWidget);
      expect(find.text('Belanja Mudah & Cepat'), findsOneWidget);
      expect(find.text('Lewati'), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);
    });

    testWidgets('navigates to next page on swipe', (tester) async {
      await tester.pumpWidget(
        buildRouter(child: const OnboardingScreen()),
      );

      await flingToNextPage(tester);

      expect(find.text('Fashion Berkualitas'), findsOneWidget);
    });

    testWidgets('navigates to last page and shows Mulai Belanja',
        (tester) async {
      await tester.pumpWidget(
        buildRouter(child: const OnboardingScreen()),
      );

      await flingToNextPage(tester);
      await flingToNextPage(tester);

      expect(find.text('Pengiriman Cepat'), findsOneWidget);
      expect(find.text('Mulai Belanja'), findsOneWidget);
    });

    testWidgets('skip button navigates to login', (tester) async {
      await tester.pumpWidget(
        buildRouter(child: const OnboardingScreen()),
      );

      await tester.tap(find.text('Lewati'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('completing onboarding navigates to login', (tester) async {
      await tester.pumpWidget(
        buildRouter(child: const OnboardingScreen()),
      );

      await flingToNextPage(tester);
      await flingToNextPage(tester);
      await tester.tap(find.text('Mulai Belanja'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('page indicators update on page change', (tester) async {
      await tester.pumpWidget(
        buildRouter(child: const OnboardingScreen()),
      );

      // Initially on first page - should have 3 indicators
      expect(find.byType(AnimatedContainer), findsNWidgets(3));

      await flingToNextPage(tester);

      // Still 3 indicators after page change
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });
  });
}
