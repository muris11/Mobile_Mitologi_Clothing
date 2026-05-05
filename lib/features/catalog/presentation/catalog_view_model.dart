import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/catalog/data/catalog_repository.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';

class CatalogViewModel extends ChangeNotifier {
  final CatalogRepository _catalogRepository;

  CatalogViewModel(this._catalogRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  ProductDetailModel? _selectedProduct;
  ProductDetailModel? get selectedProduct => _selectedProduct;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> searchProducts({String? query, int? categoryId, String? sort, bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProducts = await _catalogRepository.searchProducts(
        query: query,
        categoryId: categoryId,
        sort: sort,
        page: _currentPage,
      );

      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newProducts);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProductDetail(String slug) async {
    _isLoading = true;
    _error = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      _selectedProduct = await _catalogRepository.getProductDetail(slug);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
