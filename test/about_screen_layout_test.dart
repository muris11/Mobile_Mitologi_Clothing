import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/content/presentation/about_screen.dart';
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
import 'package:provider/provider.dart';

void main() {
  testWidgets('AboutScreen stays within bounds on compact mobile width',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => HomeViewModel(_FakeHomeRepository()),
          child: const AboutScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Kejujuran'), findsOneWidget);
    expect(find.text('Tepat Waktu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository()
      : super(
          HomeService(ApiClient(TokenStorage(), CartStorage())),
        );

  @override
  Future<HomeDataModel> getHomeData() async {
    return HomeDataModel(
      banners: const <BannerModel>[],
      categories: const <CategoryModel>[],
      bestSellers: const [],
      newArrivals: const [],
      features: const <FeatureModel>[],
      testimonials: const <TestimonialModel>[],
      materials: const <MaterialModel>[],
      portfolioItems: const <PortfolioItemModel>[],
      partners: const <PartnerModel>[],
      printingMethods: const <PrintingMethodModel>[],
      facilities: const <FacilityModel>[],
      teamMembers: const <TeamMemberModel>[],
      siteSettings: SiteSettingsModel(
        aboutHeadline: 'Tentang Mitologi Clothing',
        aboutShortHistory: 'Kami membangun apparel custom yang rapi dan konsisten.',
        visionStatement: 'Menjadi vendor terpercaya.',
        missionStatement: 'Memberikan hasil terbaik.',
        valuesText: 'Kejujuran, kualitas, tepat waktu, dan budaya.',
      ),
      productPricings: const <ProductPricingModel>[],
      orderSteps: const <OrderStepModel>[],
    );
  }
}
