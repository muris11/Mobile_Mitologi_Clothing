import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/models/user.dart';
import 'package:mitologi_clothing_mobile/providers/auth_provider.dart';
import 'package:mitologi_clothing_mobile/screens/auth/login_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';

class _FakeAuthServiceForLogin extends AuthService {
  _FakeAuthServiceForLogin() : super(ApiService());

  String? lastEmail;
  String? lastPassword;
  bool shouldSucceed = true;
  bool throwException = false;

  @override
  Future<AuthResponse> login({required String email, required String password, String? cartSessionId}) async {
    await Future.delayed(Duration.zero);
    lastEmail = email;
    lastPassword = password;
    if (throwException) throw Exception('Login failed');
    if (!shouldSucceed) {
      return AuthResponse(user: null, token: null, message: 'Invalid credentials');
    }
    return AuthResponse(
      user: User(id: 1, name: 'Test', email: email),
      token: 'test_token',
      message: 'Success',
    );
  }

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> logout() async {}
}

class _FakeCartServiceForLogin extends CartService {
  _FakeCartServiceForLogin() : super(ApiService());

  @override
  Future<void> mergeGuestCart(String authToken) async {}
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

  Widget buildLoginScreen(AuthProvider authProvider) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
        GoRoute(path: '/register', builder: (_, __) => const Scaffold(body: Text('Register'))),
        GoRoute(path: '/forgot-password', builder: (_, __) => const Scaffold(body: Text('Forgot'))),
      ],
    );
    return MultiProvider(
      providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders login screen elements', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    expect(find.text('Mitologi Clothing'), findsOneWidget);
    expect(find.text('Masuk untuk melanjutkan belanja'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
    expect(find.text('Belum punya akun?'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('validates empty email', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email tidak valid'), findsOneWidget);
  });

  testWidgets('validates invalid email', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email tidak valid'), findsOneWidget);
  });

  testWidgets('validates short password', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('successful login navigates to home', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(authService.lastEmail, 'test@example.com');
    expect(authService.lastPassword, 'password123');
  });

  testWidgets('failed login shows error message', (tester) async {
    final authService = _FakeAuthServiceForLogin()..shouldSucceed = false;
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('exception during login shows mapped error', (tester) async {
    final authService = _FakeAuthServiceForLogin()..throwException = true;
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Login failed'), findsOneWidget);
  });

  testWidgets('shows loading overlay during login', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the delayed future
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('toggles password visibility', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('forgot password button navigates', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lupa Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot'), findsOneWidget);
  });

  testWidgets('register button navigates', (tester) async {
    final authService = _FakeAuthServiceForLogin();
    final authProvider = AuthProvider(authService, _FakeCartServiceForLogin());

    await tester.pumpWidget(buildLoginScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);
  });
}
