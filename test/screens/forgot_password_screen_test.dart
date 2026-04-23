import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/screens/auth/forgot_password_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';

class _FakeAuthServiceForForgot extends AuthService {
  _FakeAuthServiceForForgot() : super(ApiService());

  String? lastEmail;
  bool shouldSucceed = true;

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(Duration.zero);
    lastEmail = email;
    if (!shouldSucceed) throw Exception('Failed');
  }
}

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    TestWidgetsFlutterBinding.instance.window.physicalSizeTestValue = const Size(1080, 1920);
    TestWidgetsFlutterBinding.instance.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      TestWidgetsFlutterBinding.instance.window.clearPhysicalSizeTestValue();
      TestWidgetsFlutterBinding.instance.window.clearDevicePixelRatioTestValue();
    });
  });

  Widget buildForgotPasswordScreen(AuthService authService) {
    final router = GoRouter(
      initialLocation: '/forgot-password',
      routes: [
        GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
      ],
    );
    return Provider<AuthService>.value(
      value: authService,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders forgot password screen', (tester) async {
    final authService = _FakeAuthServiceForForgot();

    await tester.pumpWidget(buildForgotPasswordScreen(authService));
    await tester.pumpAndSettle();

    expect(find.text('Lupa Password'), findsOneWidget);
    expect(find.text('Masukkan email Anda untuk menerima tautan reset password'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kirim Tautan Reset'), findsOneWidget);
    expect(find.text('Ingat password?'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('validates invalid email', (tester) async {
    final authService = _FakeAuthServiceForForgot();

    await tester.pumpWidget(buildForgotPasswordScreen(authService));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kirim Tautan Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Email tidak valid'), findsOneWidget);
  });

  testWidgets('sends reset link and shows success', (tester) async {
    final authService = _FakeAuthServiceForForgot();

    await tester.pumpWidget(buildForgotPasswordScreen(authService));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.tap(find.text('Kirim Tautan Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Tautan reset password telah dikirim ke email Anda'), findsOneWidget);
    expect(find.text('Cek email Anda untuk reset password. Tautan berlaku 60 menit.'), findsOneWidget);
    expect(find.text('Kembali ke Login'), findsOneWidget);
    expect(authService.lastEmail, 'test@example.com');
  });

  testWidgets('shows error on failure', (tester) async {
    final authService = _FakeAuthServiceForForgot()..shouldSucceed = false;

    await tester.pumpWidget(buildForgotPasswordScreen(authService));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.tap(find.text('Kirim Tautan Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Gagal mengirim tautan reset. Email mungkin tidak terdaftar.'), findsOneWidget);
  });

  testWidgets('shows loading overlay during request', (tester) async {
    final authService = _FakeAuthServiceForForgot();

    await tester.pumpWidget(buildForgotPasswordScreen(authService));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.tap(find.text('Kirim Tautan Reset'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the delayed future
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('success state login button navigates to login', (tester) async {
    final authService = _FakeAuthServiceForForgot();

    await tester.pumpWidget(buildForgotPasswordScreen(authService));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.tap(find.text('Kirim Tautan Reset'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kembali ke Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('login link navigates to login', (tester) async {
    final authService = _FakeAuthServiceForForgot();

    await tester.pumpWidget(buildForgotPasswordScreen(authService));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('back button pops navigation', (tester) async {
    final authService = _FakeAuthServiceForForgot();

    // Start from login then navigate to forgot-password so there is something to pop
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
        GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      ],
    );

    await tester.pumpWidget(
      Provider<AuthService>.value(
        value: authService,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to forgot-password
    router.push('/forgot-password');
    await tester.pumpAndSettle();

    expect(find.text('Lupa Password'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
