import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/providers/auth_provider.dart';
import 'package:mitologi_clothing_mobile/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_services.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildRouter({required Widget child, String initialLocation = '/'}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, __) => child),
        GoRoute(path: '/login', builder: (_, __) => child),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
        GoRoute(path: '/register', builder: (_, __) => const Scaffold(body: Text('Register'))),
        GoRoute(path: '/forgot-password', builder: (_, __) => const Scaffold(body: Text('Forgot'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('LoginScreen', () {
    testWidgets('renders all elements', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Mitologi Clothing'), findsOneWidget);
      expect(find.text('Masuk untuk melanjutkan belanja'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Lupa Password?'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.ensureVisible(find.text('Masuk'));
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.enterText(find.byType(TextFormField).last, 'short');
      await tester.ensureVisible(find.text('Masuk'));
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('navigates to forgot password', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Lupa Password?'));
      await tester.tap(find.text('Lupa Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot'), findsOneWidget);
    });

    testWidgets('navigates to register', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('disables login button when loading', (tester) async {
      final authService = FakeAuthService();
      authService.startLogin();
      final authProvider = AuthProvider(authService, FakeCartService());

      // Start login but don't complete it
      authProvider.login(email: 'a@b.com', password: 'password123');

      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.ensureVisible(find.text('Masuk'));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
      expect(button.onPressed, isNull);
    });
  });
}
