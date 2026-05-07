import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/main_shell.dart';

void main() {
  testWidgets('MainShell switches bottom navigation tabs without exceptions',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const _TabScreen(title: 'Beranda'),
            ),
            GoRoute(
              path: '/products',
              builder: (context, state) =>
                  const _TabScreen(title: 'Katalog Produk'),
            ),
            GoRoute(
              path: '/wishlist',
              builder: (context, state) => const _TabScreen(title: 'WISHLIST'),
            ),
            GoRoute(
              path: '/portfolio-tab',
              builder: (context, state) => const _TabScreen(title: 'PORTFOLIO'),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const _TabScreen(title: 'Akun Saya'),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Halaman Beranda'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Katalog'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Katalog Produk'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman WISHLIST'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Portfolio'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman PORTFOLIO'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman Akun Saya'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TabScreen extends StatelessWidget {
  const _TabScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Halaman $title'),
      ),
    );
  }
}
