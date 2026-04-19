import 'package:flutter/foundation.dart';

import '../data/content_service.dart';
import '../domain/cms_page.dart';
import '../domain/portfolio_item.dart';

class ContentProvider extends ChangeNotifier {
  final ContentService _service;

  ContentProvider(this._service);

  CmsPage? _page;
  PortfolioItem? _portfolio;
  bool _isLoading = false;
  String? _error;

  CmsPage? get page => _page;
  PortfolioItem? get portfolio => _portfolio;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPage(String handle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _page = await _service.fetchPage(handle);
    } catch (e) {
      _error = e.toString();
      _page = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPortfolio(String slug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _portfolio = await _service.fetchPortfolio(slug);
    } catch (e) {
      _error = e.toString();
      _portfolio = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
