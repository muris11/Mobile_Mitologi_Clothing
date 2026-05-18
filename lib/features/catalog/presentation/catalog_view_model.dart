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

  List<ProductModel> _recommendations = [];
  List<ProductModel> get recommendations => _recommendations;
  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  String? _sortKey;
  String? get sortKey => _sortKey;
  bool _sortReverse = false;
  bool get sortReverse => _sortReverse;

  double? _minPrice;
  double? get minPrice => _minPrice;
  double? _maxPrice;
  double? get maxPrice => _maxPrice;

  void setSort(String? key, {bool reverse = false}) {
    _sortKey = key;
    _sortReverse = reverse;
    searchProducts(sortKey: key, reverse: reverse);
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    searchProducts(minPrice: min, maxPrice: max);
  }

  void clearFilters() {
    _sortKey = null;
    _sortReverse = false;
    _minPrice = null;
    _maxPrice = null;
    searchProducts();
  }

  bool get hasActiveFilters =>
      _sortKey != null || _minPrice != null || _maxPrice != null;

  Future<void> searchProducts({
    String? query,
    String? categoryHandle,
    String? sortKey,
    bool reverse = false,
    double? minPrice,
    double? maxPrice,
    bool refresh = true,
  }) async {
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
        categoryHandle: categoryHandle,
        sortKey: sortKey ?? _sortKey,
        reverse: reverse,
        minPrice: minPrice ?? _minPrice,
        maxPrice: maxPrice ?? _maxPrice,
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

  Future<void> getRecommendations({int limit = 10}) async {
    _isLoadingRecommendations = true;
    notifyListeners();

    try {
      _recommendations = await _catalogRepository.getRecommendations(limit: limit);
    } catch (_) {
      _recommendations = [];
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  Future<void> getProductDetail(String slug) async {
    _isLoading = true;
    _error = null;
    _selectedProduct = null;
    _clearReviews();
    _clearRelated();
    notifyListeners();

    try {
      _selectedProduct = await _catalogRepository.getProductDetail(slug);
      notifyListeners();

      if (_selectedProduct != null) {
        _fetchReviews(slug);
        _fetchRelated(_selectedProduct!.id);
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductReview> _reviews = [];
  List<ProductReview> get reviews => _reviews;

  ReviewSummary? _reviewSummary;
  ReviewSummary? get reviewSummary => _reviewSummary;

  bool _isLoadingReviews = false;
  bool get isLoadingReviews => _isLoadingReviews;

  bool _hasMoreReviews = true;
  bool get hasMoreReviews => _hasMoreReviews;

  int _reviewPage = 1;

  void _clearReviews() {
    _reviews = [];
    _reviewSummary = null;
    _reviewPage = 1;
    _hasMoreReviews = true;
  }

  Future<void> _fetchReviews(String slug, {bool loadMore = false}) async {
    if (_isLoadingReviews) return;
    if (loadMore && !_hasMoreReviews) return;

    _isLoadingReviews = true;
    notifyListeners();

    try {
      if (!loadMore) _reviewPage = 1;

      final result = await _catalogRepository.getProductReviews(
        slug,
        page: _reviewPage,
      );

      final newReviews = result['reviews'] as List<ProductReview>;

      if (loadMore) {
        _reviews.addAll(newReviews);
      } else {
        _reviews = newReviews;
        _reviewSummary = result['summary'] as ReviewSummary?;
      }

      _hasMoreReviews = newReviews.length >= 10;
      if (newReviews.isNotEmpty) _reviewPage++;
    } catch (_) {
      if (!loadMore) {
        _reviews = [];
        _reviewSummary = null;
      }
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  void loadMoreReviews() {
    final slug = _selectedProduct?.slug;
    if (slug != null) _fetchReviews(slug, loadMore: true);
  }

  List<ProductModel> _relatedProducts = [];
  List<ProductModel> get relatedProducts => _relatedProducts;

  bool _isLoadingRelated = false;
  bool get isLoadingRelated => _isLoadingRelated;

  void _clearRelated() {
    _relatedProducts = [];
  }

  Future<void> _fetchRelated(int productId) async {
    _isLoadingRelated = true;
    notifyListeners();

    try {
      _relatedProducts = await _catalogRepository.getProductRecommendations(productId);
    } catch (_) {
      _relatedProducts = [];
    } finally {
      _isLoadingRelated = false;
      notifyListeners();
    }
  }
}
