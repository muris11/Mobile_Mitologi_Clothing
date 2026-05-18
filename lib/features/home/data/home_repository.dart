import 'dart:developer';

import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_service.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/category_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/home_data_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/material_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/order_step_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/portfolio_item_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/team_member_model.dart';

class HomeRepository {
  final HomeService _homeService;

  HomeRepository(this._homeService);

  Future<HomeDataModel> getHomeData() async {
    log('HomeRepository: trying landing page first...', name: 'HOME');
    try {
      final response = await _homeService.getLandingPage();
      log('HomeRepository: landing page status=${response.statusCode}', name: 'HOME');
      log('HomeRepository: landing page dataType=${response.data?.runtimeType}', name: 'HOME');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = ParserUtils.parseMap(response.data);
        log('HomeRepository: landing page keys=${responseData.keys.toList()}', name: 'HOME');

        final model = HomeDataModel.fromJson(responseData);
        log('HomeRepository: parsed — banners=${model.banners.length} categories=${model.categories.length} bestSellers=${model.bestSellers.length} newArrivals=${model.newArrivals.length}',
            name: 'HOME');

        // Return data if ANY section has content
        if (model.banners.isNotEmpty ||
            model.categories.isNotEmpty ||
            model.bestSellers.isNotEmpty ||
            model.newArrivals.isNotEmpty ||
            model.features.isNotEmpty ||
            model.testimonials.isNotEmpty ||
            model.materials.isNotEmpty ||
            model.portfolioItems.isNotEmpty ||
            model.teamMembers.isNotEmpty ||
            model.orderSteps.isNotEmpty ||
            model.siteSettings != null) {
          log('HomeRepository: returning landing page data', name: 'HOME');
          return model;
        }
        log('HomeRepository: landing page returned empty data, falling back',
            name: 'HOME');
      }
    } catch (e, st) {
      log('HomeRepository: landing page failed: $e', name: 'HOME', error: e, stackTrace: st);
    }

    return _fetchIndividualEndpoints();
  }

  Future<HomeDataModel> _fetchIndividualEndpoints() async {
    log('HomeRepository: fetching individual endpoints...', name: 'HOME');

    final results = await Future.wait([
      _safeGet(() => _homeService.getCategories(), 'categories'),
      _safeGet(() => _homeService.getBestSellers(), 'bestSellers'),
      _safeGet(() => _homeService.getNewArrivals(), 'newArrivals'),
      _safeGet(() => _homeService.getSiteSettings(), 'siteSettings'),
      _safeGet(() => _homeService.getMaterials(), 'materials'),
      _safeGet(() => _homeService.getPortfolios(), 'portfolios'),
      _safeGet(() => _homeService.getTeamMembers(), 'teamMembers'),
      _safeGet(() => _homeService.getOrderSteps(), 'orderSteps'),
    ]);

    final categoriesData = results[0];
    final bestSellersData = results[1];
    final newArrivalsData = results[2];
    final siteSettingsData = results[3];
    final materialsData = results[4];
    final portfoliosData = results[5];
    final teamMembersData = results[6];
    final orderStepsData = results[7];

    SiteSettingsModel? settings;
    if (siteSettingsData != null) {
      try {
        final data = siteSettingsData is Map
            ? ParserUtils.parseMap(siteSettingsData)
            : ParserUtils.parseMap(siteSettingsData['data']);
        settings = SiteSettingsModel.fromJson(data);
      } catch (e) {
        log('HomeRepository: failed to parse siteSettings: $e', name: 'HOME');
      }
    }

    final categories = ParserUtils.parseList(
      _extractList(categoriesData),
      (e) => CategoryModel.fromJson(e),
    );
    final bestSellers = ParserUtils.parseList(
      _extractList(bestSellersData),
      (e) => ProductModel.fromJson(e),
    );
    final newArrivals = ParserUtils.parseList(
      _extractList(newArrivalsData),
      (e) => ProductModel.fromJson(e),
    );

    log('HomeRepository: fallback parsed — categories=${categories.length} bestSellers=${bestSellers.length} newArrivals=${newArrivals.length}',
        name: 'HOME');

    return HomeDataModel(
      banners: [],
      categories: categories,
      bestSellers: bestSellers,
      newArrivals: newArrivals,
      features: [],
      testimonials: [],
      materials: ParserUtils.parseList(
        _extractList(materialsData),
        (e) => MaterialModel.fromJson(e),
      ),
      portfolioItems: ParserUtils.parseList(
        _extractList(portfoliosData),
        (e) => PortfolioItemModel.fromJson(e),
      ),
      partners: [],
      printingMethods: [],
      facilities: [],
      teamMembers: ParserUtils.parseList(
        _extractList(teamMembersData),
        (e) => TeamMemberModel.fromJson(e),
      ),
      siteSettings: settings,
      productPricings: [],
      orderSteps: ParserUtils.parseList(
        _extractList(orderStepsData),
        (e) => OrderStepModel.fromJson(e),
      ),
    );
  }

  List _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) {
      final map = ParserUtils.parseMap(data);
      final list = map['data'] ?? map['items'] ?? map['records'] ?? [];
      log('HomeRepository: _extractList found ${list is List ? list.length : 0} items', name: 'HOME');
      return list;
    }
    return [];
  }

  Future<dynamic> _safeGet(
    Future<dynamic> Function() fetcher,
    String name,
  ) async {
    try {
      final response = await fetcher();
      if (response.statusCode == 200 && response.data != null) {
        log('HomeRepository: $name OK dataType=${response.data.runtimeType}', name: 'HOME');
        return response.data;
      }
      log('HomeRepository: $name bad status=${response.statusCode}', name: 'HOME');
    } catch (e) {
      log('HomeRepository: $name failed: $e', name: 'HOME');
    }
    return null;
  }
}
