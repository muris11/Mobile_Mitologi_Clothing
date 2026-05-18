import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_service.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_repository.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_service.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/banner_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/category_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/facility_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/feature_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/home_data_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/material_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/order_step_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/partner_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/portfolio_item_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/printing_method_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/product_pricing_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/team_member_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/testimonial_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/main_shell.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/views/home_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomeView renders loaded home data without throwing',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => HomeViewModel(
                  _FakeHomeRepository(_buildLoadedHomeData()),
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => CartViewModel(_FakeCartRepository()),
              ),
            ],
            child: const HomeView(),
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/portfolio',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/layanan',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/tentang-kami',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/kontak',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MITOLOGI'), findsWidgets);
    expect(find.text('Kala Makara'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeView renders fallback hero when home data is empty',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => HomeViewModel(
                  _FakeHomeRepository(HomeDataModel.empty()),
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => CartViewModel(_FakeCartRepository()),
              ),
            ],
            child: const HomeView(),
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MITOLOGI'), findsWidgets);
    expect(find.text('Premium Quality\nCustom Clothing'), findsOneWidget);
    expect(find.text('WHO WE ARE'), findsOneWidget);
    expect(find.text('Pesan Sekarang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeView keeps fallback content visible while loading',
      (tester) async {
    final repository = _PendingHomeRepository();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => HomeViewModel(repository),
              ),
              ChangeNotifierProvider(
                create: (_) => CartViewModel(_FakeCartRepository()),
              ),
            ],
            child: const HomeView(),
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump();

    expect(find.text('MITOLOGI'), findsWidgets);
    expect(find.text('Premium Quality\nCustom Clothing'), findsOneWidget);
    expect(find.text('WHO WE ARE'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    repository.complete(HomeDataModel.empty());
  });

  testWidgets('MainShell renders HomeView fallback content on Beranda',
      (tester) async {
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => HomeViewModel(
                      _FakeHomeRepository(HomeDataModel.empty()),
                    ),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => CartViewModel(_FakeCartRepository()),
                  ),
                ],
                child: const HomeView(),
              ),
            ),
            GoRoute(
              path: '/products',
              builder: (context, state) =>
                  const Scaffold(body: SizedBox.shrink()),
            ),
            GoRoute(
              path: '/wishlist',
              builder: (context, state) =>
                  const Scaffold(body: SizedBox.shrink()),
            ),
            GoRoute(
              path: '/portfolio-tab',
              builder: (context, state) =>
                  const Scaffold(body: SizedBox.shrink()),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const Scaffold(body: SizedBox.shrink()),
            ),
          ],
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Premium Quality\nCustom Clothing'), findsOneWidget);
    expect(find.text('WHO WE ARE'), findsOneWidget);
    expect(find.text('Pesan Sekarang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository(this.data)
      : super(
          HomeService(ApiClient(TokenStorage(), CartStorage())),
        );

  final HomeDataModel data;

  @override
  Future<HomeDataModel> getHomeData() async => data;
}

class _PendingHomeRepository extends HomeRepository {
  _PendingHomeRepository()
      : super(
          HomeService(ApiClient(TokenStorage(), CartStorage())),
        );

  final Completer<HomeDataModel> _completer = Completer<HomeDataModel>();

  @override
  Future<HomeDataModel> getHomeData() => _completer.future;

  void complete(HomeDataModel data) {
    if (!_completer.isCompleted) {
      _completer.complete(data);
    }
  }
}

class _FakeCartRepository extends CartRepository {
  _FakeCartRepository()
      : super(
          CartService(ApiClient(TokenStorage(), CartStorage())),
          CartStorage(),
        );
}

HomeDataModel _buildLoadedHomeData() {
  const image = 'https://example.com/image.jpg';

  return HomeDataModel(
    banners: const [
      BannerModel(
        id: 1,
        title: 'Kala Makara',
        subtitle: 'Koleksi Baru',
        description: 'Rilis terbaru untuk tampilan harian.',
        imageUrl: image,
        link: '/products',
      ),
    ],
    categories: const [
      CategoryModel(id: 1, name: 'Topi', slug: 'topi', iconUrl: image),
    ],
    bestSellers: const [
      ProductModel(
        id: 1,
        name: 'Kala Makara Snapback Cap',
        slug: 'kala-makara-snapback-cap',
        description: 'Topi snapback premium.',
        price: 129000,
        featuredImageUrl: image,
        stock: 10,
      ),
    ],
    newArrivals: const [
      ProductModel(
        id: 2,
        name: 'Mitra Kaos Premium',
        slug: 'mitra-kaos-premium',
        description: 'Kaos premium baru.',
        price: 159000,
        featuredImageUrl: image,
        stock: 8,
      ),
    ],
    features: [
      FeatureModel(
        id: 1,
        title: 'Cepat',
        description: 'Produksi cepat dan tepat waktu.',
        icon: 'clock',
        isActive: true,
        sortOrder: 0,
      ),
    ],
    testimonials: [
      TestimonialModel(
        id: 1,
        name: 'Rifqy',
        role: 'Pelanggan',
        content: 'Hasil sablon rapi dan respons cepat.',
        rating: 5,
        avatarUrl: image,
      ),
    ],
    materials: [
      MaterialModel(
        id: 1,
        name: 'Cotton Combed 24s',
        description: 'Lembut, adem, nyaman dipakai.',
        colorTheme: 'dark',
        image: image,
      ),
    ],
    portfolioItems: [
      PortfolioItemModel(
        id: 1,
        title: 'Project Komunitas',
        slug: 'project-komunitas',
        category: 'Kaos',
        description: 'Kolaborasi custom clothing.',
        imageUrl: image,
      ),
    ],
    partners: [
      PartnerModel(
        id: 1,
        name: 'Partner A',
        logo: image,
        description: 'Partner terpercaya.',
      ),
    ],
    printingMethods: [
      PrintingMethodModel(
        id: 1,
        name: 'Plastisol',
        slug: 'plastisol',
        description: 'Teknik sablon premium dengan hasil tajam.',
        image: image,
        pros: ['Warna awet', 'Detail tajam'],
        priceRange: 'Mulai 12rb',
      ),
    ],
    facilities: [
      FacilityModel(
        id: 1,
        name: 'Mesin Cutting',
        description: 'Presisi tinggi untuk produksi.',
        image: image,
      ),
    ],
    teamMembers: [
      TeamMemberModel(
        id: 1,
        name: 'Rizky',
        position: 'Founder',
        photoUrl: image,
      ),
    ],
    siteSettings: SiteSettingsModel(
      aboutHeadline: 'Tentang Mitologi Clothing',
      aboutDescription1: 'Kami memproduksi custom clothing dengan detail rapi.',
      companyFoundedYear: '2020',
      aboutImage: image,
      guaranteesData: const [
        GuaranteeItem(
          title: 'Garansi Kualitas',
          description: 'Produk diperiksa sebelum dikirim.',
        ),
      ],
      garansiBonusData: const [
        GuaranteeBonusItem(
          title: 'Bonus Konsultasi',
          description: 'Bantuan memilih bahan dan teknik.',
        ),
      ],
      ctaTitle: 'Pesan Sekarang',
      ctaSubtitle: 'Hubungi kami untuk custom clothing terbaik.',
      ctaButtonText: 'Lihat Koleksi',
      contactWhatsapp: '6281234567890',
      pricingPlastisolData: const [
        {
          'title': 'Kaos',
          'image': image,
          'short': '12.000',
          'long': '15.000',
          'min_order': 'Min. 24 pcs',
        },
      ],
      pricingAddonsData: const [
        {'name': 'Plastik', 'price': '1000'},
      ],
      pricingFeaturesData: const [
        PricingFeatureItem(text: 'Full quality control'),
      ],
    ),
    productPricings: const [
      ProductPricingModel(
        id: 1,
        categoryName: 'Kaos',
        items: [PricingItem(name: '24s', priceRange: '12rb - 15rb')],
        minOrder: 'Min. 24 pcs',
      ),
    ],
    orderSteps: const [
      OrderStepModel(
        id: 1,
        stepNumber: 1,
        title: 'Konsultasi',
        description: 'Diskusikan kebutuhan desain dan bahan.',
        type: 'langsung',
        sortOrder: 1,
      ),
      OrderStepModel(
        id: 2,
        stepNumber: 2,
        title: 'Checkout Marketplace',
        description: 'Pesan lewat e-commerce resmi kami.',
        type: 'ecommerce',
        sortOrder: 1,
      ),
    ],
  );
}
