import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/providers/auth_provider.dart';
import 'package:mitologi_clothing_mobile/screens/auth/register_screen.dart';
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
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('RegisterScreen', () {
    testWidgets('renders all elements', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.text('Mitologi Clothing'), findsOneWidget);
      expect(find.text('Buat Akun Baru'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('validates empty name', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Nama harus diisi'), findsOneWidget);
    });

    testWidgets('validates invalid email', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'invalid');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('validates password requirements', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'test@email.com');
      await tester.enterText(fields.at(2), 'short');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });

    testWidgets('validates password confirmation mismatch', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'test@email.com');
      await tester.enterText(fields.at(2), 'Password1');
      await tester.enterText(fields.at(3), 'Different1');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Password tidak cocok'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      final authProvider = AuthProvider(FakeAuthService(), FakeCartService());
      await tester.pumpWidget(
        buildRouter(
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const RegisterScreen(),
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
