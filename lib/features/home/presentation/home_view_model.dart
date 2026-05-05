import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/home/data/home_repository.dart';
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

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeViewModel(this._homeRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetching = false;

  HomeDataModel _homeData = HomeDataModel.empty();
  HomeDataModel get homeData => _homeData;

  String? _error;
  String? get error => _error;

  Future<void> fetchHomeData() async {
    if (_isFetching) return;
    _isFetching = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('Fetching unified home data...');
      _homeData = await _homeRepository.getHomeData();

      log('Home data fetched successfully: '
          '${_homeData.banners.length} banners, '
          '${_homeData.categories.length} categories, '
          '${_homeData.features.length} features, '
          '${_homeData.testimonials.length} testimonials');
    } catch (e, stack) {
      log('Error fetching home data', error: e, stackTrace: stack);
      _error = "Failed to load dashboard. Please try again.";
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  List<BannerModel> get banners => _homeData.banners;
  List<CategoryModel> get categories => _homeData.categories;
  List<ProductModel> get bestSellers => _homeData.bestSellers;
  List<ProductModel> get featuredProducts =>
      _homeData.bestSellers; // Alias for UI
  List<ProductModel> get newArrivals => _homeData.newArrivals;
  List<FeatureModel> get features => _homeData.features;
  List<TestimonialModel> get testimonials => _homeData.testimonials;
  List<MaterialModel> get materials => _homeData.materials;
  List<PortfolioItemModel> get portfolioItems => _homeData.portfolioItems;
  List<PartnerModel> get partners => _homeData.partners;
  List<PrintingMethodModel> get printingMethods => _homeData.printingMethods;
  List<FacilityModel> get facilities => _homeData.facilities;
  List<TeamMemberModel> get teamMembers => _homeData.teamMembers;
  SiteSettingsModel? get siteSettings => _homeData.siteSettings;
  List<ProductPricingModel> get productPricings => _homeData.productPricings;
  List<OrderStepModel> get orderSteps => _homeData.orderSteps;
}
