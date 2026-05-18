import 'dart:developer';

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
    Map<String, dynamic> data;
    if (json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    } else if (json['data'] is Map) {
      data = Map<String, dynamic>.from(json['data'] as Map);
    } else {
      data = json;
    }

    log('HomeDataModel: parsing with keys=${data.keys.toList()}', name: 'HOME');

    SiteSettingsModel? settings;
    if (data['siteSettings'] is Map) {
      try {
        settings = SiteSettingsModel.fromJson(
            ParserUtils.parseMap(data['siteSettings']));
      } catch (e) {
        log('HomeDataModel: failed to parse siteSettings: $e', name: 'HOME');
      }
    } else if (data['site_settings'] is Map) {
      try {
        settings = SiteSettingsModel.fromJson(
            ParserUtils.parseMap(data['site_settings']));
      } catch (e) {
        log('HomeDataModel: failed to parse site_settings: $e', name: 'HOME');
      }
    }

    return HomeDataModel(
      banners: _safeParseList(data['heroSlides'] ?? data['banners'] ?? data['hero_slides'], (e) => BannerModel.fromJson(e), 'banners'),
      categories: _safeParseList(data['categories'], (e) => CategoryModel.fromJson(e), 'categories'),
      bestSellers: _safeParseList(data['bestSellers'] ?? data['best_sellers'], (e) => ProductModel.fromJson(e), 'bestSellers'),
      newArrivals: _safeParseList(data['newArrivals'] ?? data['new_arrivals'], (e) => ProductModel.fromJson(e), 'newArrivals'),
      features: _safeParseList(data['features'], (e) => FeatureModel.fromJson(e), 'features'),
      testimonials: _safeParseList(data['testimonials'], (e) => TestimonialModel.fromJson(e), 'testimonials'),
      materials: _safeParseList(data['materials'], (e) => MaterialModel.fromJson(e), 'materials'),
      portfolioItems: _safeParseList(
        data['portfolioItems'] ?? data['portfolio_items'] ?? data['portfolio'],
        (e) => PortfolioItemModel.fromJson(e),
        'portfolioItems',
      ),
      partners: _safeParseList(data['partners'], (e) => PartnerModel.fromJson(e), 'partners'),
      printingMethods: _safeParseList(
        data['printingMethods'] ?? data['printing_methods'],
        (e) => PrintingMethodModel.fromJson(e),
        'printingMethods',
      ),
      facilities: _safeParseList(data['facilities'], (e) => FacilityModel.fromJson(e), 'facilities'),
      teamMembers: _safeParseList(
        data['teamMembers'] ?? data['team_members'],
        (e) => TeamMemberModel.fromJson(e),
        'teamMembers',
      ),
      siteSettings: settings,
      productPricings: _safeParseList(
        data['productPricings'] ?? data['product_pricings'],
        (e) => ProductPricingModel.fromJson(e),
        'productPricings',
      ),
      orderSteps: _safeParseList(
        data['orderSteps'] ?? data['order_steps'],
        (e) => OrderStepModel.fromJson(e),
        'orderSteps',
      ),
    );
  }

  static List<T> _safeParseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) mapper,
    String name,
  ) {
    try {
      final result = ParserUtils.parseList(value, mapper);
      log('HomeDataModel: $name parsed ${result.length} items', name: 'HOME');
      return result;
    } catch (e) {
      log('HomeDataModel: failed to parse $name: $e', name: 'HOME');
      return [];
    }
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
