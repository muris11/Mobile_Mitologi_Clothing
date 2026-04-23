import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/screens/auth/reset_password_screen.dart';
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

  group('ResetPasswordScreen', () {
    testWidgets('renders form with valid token', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ResetPasswordScreen(
              token: 'valid_token',
              email: 'test@email.com',
            ),
          ),
        ),
      );

      expect(find.text('Reset Password'), findsWidgets);
      expect(find.text('Password Baru'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reset Password'), findsOneWidget);
    });

    testWidgets('shows invalid token warning when token is missing',
        (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ResetPasswordScreen(),
          ),
        ),
      );

      expect(
        find.text('Tautan reset password tidak valid. Silakan minta tautan baru.'),
        findsOneWidget,
      );
    });

    testWidgets('validates password length', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ResetPasswordScreen(
              token: 'valid_token',
              email: 'test@email.com',
            ),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'short');
      final resetButton = find.widgetWithText(ElevatedButton, 'Reset Password');
      await tester.ensureVisible(resetButton);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });

    testWidgets('validates password confirmation mismatch', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ResetPasswordScreen(
              token: 'valid_token',
              email: 'test@email.com',
            ),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'Password1');
      await tester.enterText(fields.last, 'Password2');
      final resetButton = find.widgetWithText(ElevatedButton, 'Reset Password');
      await tester.ensureVisible(resetButton);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(find.text('Password tidak cocok'), findsOneWidget);
    });

    testWidgets('shows success state after reset', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ResetPasswordScreen(
              token: 'valid_token',
              email: 'test@email.com',
            ),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'NewPass123');
      await tester.enterText(fields.last, 'NewPass123');
      final resetButton = find.widgetWithText(ElevatedButton, 'Reset Password');
      await tester.ensureVisible(resetButton);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(find.text('Password Berhasil Diubah'), findsOneWidget);
      expect(find.text('Masuk dengan Password Baru'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        buildRouter(
          child: Provider<AuthService>.value(
            value: FakeAuthService(),
            child: const ResetPasswordScreen(
              token: 'valid_token',
              email: 'test@email.com',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
