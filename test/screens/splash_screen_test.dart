import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/providers/auth_provider.dart';
import 'package:mitologi_clothing_mobile/screens/splash/splash_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';
import 'package:mitologi_clothing_mobile/services/secure_storage_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';
import '../providers/auth_provider_test.dart';
import 'package:mitologi_clothing_mobile/models/user.dart';

class _TestSplashRouter {
  static GoRouter create(AuthProvider authProvider, {String initial = '/splash'}) {
    return GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (_, __) => const Scaffold(body: Text('Onboarding'))),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
      ],
    );
  }
}

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    clearMockStorage();
  });

  testWidgets('renders splash screen with logo and title', (tester) async {
    final authService = FakeAuthService()..loggedIn = false;
    final authProvider = AuthProvider(authService, FakeCartService());
    final router = _TestSplashRouter.create(authProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text('Mitologi'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
    expect(find.text('The Digital Curator'), findsOneWidget);
    expect(find.text('Memuat aplikasi...'), findsOneWidget);

    // Pump out the Future.delayed in _initializeApp
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('navigates to onboarding when not completed', (tester) async {
    await SecureStorageService.setOnboardingCompleted(false);
    final authService = FakeAuthService()..loggedIn = false;
    final authProvider = AuthProvider(authService, FakeCartService());
    final router = _TestSplashRouter.create(authProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('navigates to login when onboarding completed and not authenticated', (tester) async {
    await SecureStorageService.setOnboardingCompleted(true);
    final authService = FakeAuthService()..loggedIn = false;
    final authProvider = AuthProvider(authService, FakeCartService());
    final router = _TestSplashRouter.create(authProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('navigates to home when onboarding completed and authenticated', (tester) async {
    await SecureStorageService.setOnboardingCompleted(true);
    final authService = FakeAuthService()
      ..loggedIn = true
      ..currentUser = User(id: 1, name: 'Test', email: 'test@example.com');
    final authProvider = AuthProvider(authService, FakeCartService());
    final router = _TestSplashRouter.create(authProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('shows progress bar animation', (tester) async {
    final authService = FakeAuthService()..loggedIn = false;
    final authProvider = AuthProvider(authService, FakeCartService());
    final router = _TestSplashRouter.create(authProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    expect(find.byType(AnimatedBuilder), findsWidgets);

    // Progress should animate over 2 seconds
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
