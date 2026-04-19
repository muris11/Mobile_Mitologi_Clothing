import 'package:flutter/foundation.dart';

import '../data/landing_service.dart';
import '../domain/landing_page_data.dart';

class LandingProvider extends ChangeNotifier {
  final LandingService _service;

  LandingProvider(this._service);

  LandingPageData? _data;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<HeroSlide> get heroSlides => _data?.heroSlides ?? const [];
  List<LandingCategory> get categories => _data?.categories ?? const [];
  int get bestSellersCount => _data?.bestSellersCount ?? 0;
  int get newArrivalsCount => _data?.newArrivalsCount ?? 0;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _service.fetchLandingPage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
