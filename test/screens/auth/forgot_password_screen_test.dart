import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/screens/auth/forgot_password_screen.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
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
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('ForgotPasswordScreen', () {
    testWidgets('renders all elements', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      expect(find.text('Lupa Password'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Kirim Tautan Reset'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Kirim Tautan Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('validates invalid email', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.tap(find.text('Kirim Tautan Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('shows success state after sending email', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.tap(find.text('Kirim Tautan Reset'));
      await tester.pumpAndSettle();

      expect(
        find.text('Tautan reset password telah dikirim ke email Anda'),
        findsOneWidget,
      );
      expect(find.text('Kembali ke Login'), findsOneWidget);
    });

    testWidgets('navigates to login from success state', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.tap(find.text('Kirim Tautan Reset'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kembali ke Login'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('navigates to login from footer', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
