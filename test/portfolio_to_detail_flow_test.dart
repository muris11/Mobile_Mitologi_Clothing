import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_repository.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_service.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/content_provider.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/portfolio_detail_screen.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/portfolio_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Portfolio flows to detail without exceptions', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      initialLocation: '/portfolio',
      routes: [
        GoRoute(
          path: '/portfolio',
          builder: (context, state) => ChangeNotifierProvider<ContentProvider>(
            create: (_) => _FakeContentProvider()..seedPortfolios(),
            child: const PortfolioScreen(),
          ),
        ),
        GoRoute(
          path: '/portfolio/:slug',
          builder: (context, state) => ChangeNotifierProvider<ContentProvider>(
            create: (_) => _FakeContentProvider()..seedPortfolios(),
            child: PortfolioDetailScreen(slug: state.pathParameters['slug']!),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PORTFOLIO'), findsOneWidget);
    expect(find.text('Project Komunitas'), findsOneWidget);

    await tester.tap(find.text('Project Komunitas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Project Komunitas'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class _FakeContentProvider extends ContentProvider {
  _FakeContentProvider()
      : super(
          ContentRepository(
            ContentService(ApiClient(TokenStorage(), CartStorage())),
          ),
        );

  List<PortfolioItem> _portfoliosInternal = [];

  void seedPortfolios() {
    _portfoliosInternal = _portfolios;
  }

  @override
  List<PortfolioItem> get portfolios => _portfoliosInternal;

  @override
  bool get isLoading => false;

  @override
  Future<void> loadPortfolios() async {}

  @override
  Future<PortfolioItem?> getPortfolioDetail(String slug) async {
    return _portfolios.firstWhere((item) => item.slug == slug);
  }
}

const _portfolios = [
  PortfolioItem(
    slug: 'project-komunitas',
    title: 'Project Komunitas',
    description: 'Kolaborasi custom clothing untuk komunitas.',
    category: 'Kaos',
    imageUrl: 'https://example.com/image.jpg',
  ),
];
