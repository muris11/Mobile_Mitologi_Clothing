import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/screens/auth/reset_password_screen.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_binding.dart';

class _FakeAuthServiceForReset extends AuthService {
  _FakeAuthServiceForReset() : super(ApiService());

  String? lastToken;
  String? lastEmail;
  String? lastPassword;
  bool shouldSucceed = true;

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future.delayed(Duration.zero);
    lastToken = token;
    lastEmail = email;
    lastPassword = password;
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

  Widget buildResetPasswordScreen({String? token, String? email, AuthService? authService}) {
    final router = GoRouter(
      initialLocation: '/reset-password',
      routes: [
        GoRoute(
          path: '/reset-password',
          builder: (_, __) => ResetPasswordScreen(token: token, email: email),
        ),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login'))),
      ],
    );
    return Provider<AuthService>.value(
      value: authService ?? _FakeAuthServiceForReset(),
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders reset password screen with valid token', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsNWidgets(2)); // Title + button
    expect(find.text('Masukkan password baru untuk akun Anda'), findsOneWidget);
    expect(find.text('Password Baru'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
  });

  testWidgets('shows invalid token warning when token is missing', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: null,
      email: null,
      authService: authService,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tautan reset password tidak valid. Silakan minta tautan baru.'), findsOneWidget);
    // The reset button should be disabled when token is invalid
    final buttons = find.byType(ElevatedButton);
    // There is a "Masuk dengan Password Baru" button in success state, but we're not in success state
    // The only ElevatedButton should be the Reset Password button which is disabled
    final resetButton = tester.widget<ElevatedButton>(buttons.last);
    expect(resetButton.onPressed, isNull);
  });

  testWidgets('validates short password', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset Password').last);
    await tester.pumpAndSettle();

    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('validates password confirmation match', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Password123');
    await tester.enterText(fields.at(1), 'Different123');
    await tester.tap(find.text('Reset Password').last);
    await tester.pumpAndSettle();

    expect(find.text('Password tidak cocok'), findsOneWidget);
  });

  testWidgets('successful reset shows success state', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Password123');
    await tester.enterText(fields.at(1), 'Password123');
    await tester.tap(find.text('Reset Password').last);
    await tester.pumpAndSettle();

    expect(find.text('Password Berhasil Diubah'), findsOneWidget);
    expect(find.text('Password berhasil direset. Silakan login dengan password baru.'), findsOneWidget);
    expect(find.text('Masuk dengan Password Baru'), findsOneWidget);
    expect(authService.lastToken, 'valid_token');
    expect(authService.lastEmail, 'test@example.com');
  });

  testWidgets('failed reset shows error', (tester) async {
    final authService = _FakeAuthServiceForReset()..shouldSucceed = false;

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Password123');
    await tester.enterText(fields.at(1), 'Password123');
    await tester.tap(find.text('Reset Password').last);
    await tester.pumpAndSettle();

    expect(find.text('Gagal reset password. Tautan mungkin sudah kedaluwarsa.'), findsOneWidget);
  });

  testWidgets('shows loading overlay during reset', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Password123');
    await tester.enterText(fields.at(1), 'Password123');
    await tester.tap(find.text('Reset Password').last);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the delayed future
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('success state login button navigates', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Password123');
    await tester.enterText(fields.at(1), 'Password123');
    await tester.tap(find.text('Reset Password').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk dengan Password Baru'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('login link navigates to login', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('back button navigates to login', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    final authService = _FakeAuthServiceForReset();

    await tester.pumpWidget(buildResetPasswordScreen(
      token: 'valid_token',
      email: 'test@example.com',
      authService: authService,
    ));
    await tester.pumpAndSettle();

    final visibilityIcons = find.byIcon(Icons.visibility_outlined);
    expect(visibilityIcons, findsNWidgets(2));

    await tester.tap(visibilityIcons.first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
