import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/banner_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/category_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/facility_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/feature_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/material_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/order_step_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/partner_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/portfolio_item_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/printing_method_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/product_pricing_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/team_member_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/testimonial_model.dart';

class HomeDataModel {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> bestSellers;
  final List<ProductModel> newArrivals;
  final List<FeatureModel> features;
  final List<TestimonialModel> testimonials;
  final List<MaterialModel> materials;
  final List<PortfolioItemModel> portfolioItems;
  final List<PartnerModel> partners;
  final List<PrintingMethodModel> printingMethods;
  final List<FacilityModel> facilities;
  final List<TeamMemberModel> teamMembers;
  final SiteSettingsModel? siteSettings;
  final List<ProductPricingModel> productPricings;
  final List<OrderStepModel> orderSteps;

  HomeDataModel({
    required this.banners,
    required this.categories,
    required this.bestSellers,
    required this.newArrivals,
    required this.features,
    required this.testimonials,
    required this.materials,
    required this.portfolioItems,
    required this.partners,
    required this.printingMethods,
    required this.facilities,
    required this.teamMembers,
    this.siteSettings,
    this.productPricings = const [],
    this.orderSteps = const [],
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map) ? json['data'] as Map<String, dynamic> : json;

    SiteSettingsModel? settings;
    if (data['siteSettings'] is Map) {
      settings = SiteSettingsModel.fromJson(
          data['siteSettings'] as Map<String, dynamic>);
    }

    return HomeDataModel(
      banners: ParserUtils.parseList(
        data['heroSlides'] ?? data['banners'] ?? data['hero_slides'],
        (e) => BannerModel.fromJson(e),
      ),
      categories: ParserUtils.parseList(
        data['categories'],
        (e) => CategoryModel.fromJson(e),
      ),
      bestSellers: ParserUtils.parseList(
        data['bestSellers'] ?? data['best_sellers'],
        (e) => ProductModel.fromJson(e),
      ),
      newArrivals: ParserUtils.parseList(
        data['newArrivals'] ?? data['new_arrivals'],
        (e) => ProductModel.fromJson(e),
      ),
      features: ParserUtils.parseList(
        data['features'],
        (e) => FeatureModel.fromJson(e),
      ),
      testimonials: ParserUtils.parseList(
        data['testimonials'],
        (e) => TestimonialModel.fromJson(e),
      ),
      materials: ParserUtils.parseList(
        data['materials'],
        (e) => MaterialModel.fromJson(e),
      ),
      portfolioItems: ParserUtils.parseList(
        data['portfolioItems'] ?? data['portfolio_items'] ?? data['portfolio'],
        (e) => PortfolioItemModel.fromJson(e),
      ),
      partners: ParserUtils.parseList(
        data['partners'],
        (e) => PartnerModel.fromJson(e),
      ),
      printingMethods: ParserUtils.parseList(
        data['printingMethods'] ?? data['printing_methods'],
        (e) => PrintingMethodModel.fromJson(e),
      ),
      facilities: ParserUtils.parseList(
        data['facilities'],
        (e) => FacilityModel.fromJson(e),
      ),
      teamMembers: ParserUtils.parseList(
        data['teamMembers'] ?? data['team_members'],
        (e) => TeamMemberModel.fromJson(e),
      ),
      siteSettings: settings,
      productPricings: ParserUtils.parseList(
        data['productPricings'] ?? data['product_pricings'],
        (e) => ProductPricingModel.fromJson(e),
      ),
      orderSteps: ParserUtils.parseList(
        data['orderSteps'] ?? data['order_steps'],
        (e) => OrderStepModel.fromJson(e),
      ),
    );
  }

  factory HomeDataModel.empty() {
    return HomeDataModel(
      banners: [],
      categories: [],
      bestSellers: [],
      newArrivals: [],
      features: [],
      testimonials: [],
      materials: [],
      portfolioItems: [],
      partners: [],
      printingMethods: [],
      facilities: [],
      teamMembers: [],
      siteSettings: null,
      productPricings: [],
      orderSteps: [],
    );
  }
}
