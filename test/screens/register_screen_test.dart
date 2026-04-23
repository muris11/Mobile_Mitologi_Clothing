import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/models/user.dart';
import 'package:mitologi_clothing_mobile/providers/auth_provider.dart';
import 'package:mitologi_clothing_mobile/screens/auth/register_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';

class _FakeAuthServiceForRegister extends AuthService {
  _FakeAuthServiceForRegister() : super(ApiService());

  String? lastName;
  String? lastEmail;
  String? lastPassword;
  bool shouldSucceed = true;
  bool throwException = false;

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    await Future.delayed(Duration.zero);
    lastName = name;
    lastEmail = email;
    lastPassword = password;
    if (throwException) throw Exception('Registration failed');
    if (!shouldSucceed) {
      return AuthResponse(user: null, token: null, message: 'Email already exists');
    }
    return AuthResponse(
      user: User(id: 1, name: name, email: email),
      token: 'test_token',
      message: 'Success',
    );
  }

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> logout() async {}
}

class _FakeCartServiceForRegister extends CartService {
  _FakeCartServiceForRegister() : super(ApiService());

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

  Widget buildRegisterScreen(AuthProvider authProvider) {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
      ],
    );
    return MultiProvider(
      providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders register screen elements', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    expect(find.text('Mitologi Clothing'), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
    expect(find.text('Sudah punya akun?'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('validates empty name', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Nama harus diisi'), findsOneWidget);
  });

  testWidgets('validates invalid email', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'invalid-email');
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Email tidak valid'), findsOneWidget);
  });

  testWidgets('validates password requirements', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'short');
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('validates password uppercase requirement', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'lowercase1');
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Password harus mengandung huruf besar'), findsOneWidget);
  });

  testWidgets('validates password number requirement', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'PasswordOnly');
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Password harus mengandung angka'), findsOneWidget);
  });

  testWidgets('validates password confirmation match', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'Password123');
    await tester.enterText(fields.at(3), 'Different123');
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Password tidak cocok'), findsOneWidget);
  });

  testWidgets('successful registration navigates to home', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'Password123');
    await tester.enterText(fields.at(3), 'Password123');
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(authService.lastName, 'Test User');
    expect(authService.lastEmail, 'test@example.com');
  });

  testWidgets('failed registration shows error', (tester) async {
    final authService = _FakeAuthServiceForRegister()..shouldSucceed = false;
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'Password123');
    await tester.enterText(fields.at(3), 'Password123');
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Email already exists'), findsOneWidget);
  });

  testWidgets('shows loading overlay during registration', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'Password123');
    await tester.enterText(fields.at(3), 'Password123');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the delayed future
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('toggles password visibility for both fields', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    await tester.pumpWidget(buildRegisterScreen(authProvider));
    await tester.pumpAndSettle();

    final visibilityIcons = find.byIcon(Icons.visibility_outlined);
    expect(visibilityIcons, findsNWidgets(2));

    await tester.tap(visibilityIcons.first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('login button navigates to login', (tester) async {
    final authService = _FakeAuthServiceForRegister();
    final authProvider = AuthProvider(authService, _FakeCartServiceForRegister());

    // Start from login then push to register so pop works
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<AuthProvider>.value(value: authProvider)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.push('/register');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
