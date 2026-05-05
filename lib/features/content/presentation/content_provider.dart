import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/content/data/content_repository.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';

class ContentProvider extends ChangeNotifier {
  final ContentRepository _repository;

  ContentProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  
  List<PortfolioItem> _portfolios = [];
  List<CollectionDetail> _collections = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PortfolioItem> get portfolios => _portfolios;
  List<CollectionDetail> get collections => _collections;

  Future<void> loadPortfolios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _portfolios = await _repository.getPortfolios();
    } catch (e) {
      _error = 'Gagal memuat portfolio.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCollections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collections = await _repository.getCollections();
    } catch (e) {
      _error = 'Gagal memuat koleksi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CmsPage?> getPage(String handle) async {
    return await _repository.getPage(handle);
  }

  Future<PortfolioItem?> getPortfolioDetail(String slug) async {
    return await _repository.getPortfolioDetail(slug);
  }

  Future<CollectionDetail?> getCollectionWithProducts(String handle) async {
    return await _repository.getCollectionWithProducts(handle);
  }
}
