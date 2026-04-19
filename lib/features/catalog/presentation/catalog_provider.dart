import 'package:flutter/foundation.dart';

import '../domain/catalog_query.dart';
import '../domain/paginated_products.dart';

abstract class CatalogDataSource {
  Future<PaginatedProducts> fetchProducts(CatalogQuery query);
}

class CatalogProvider extends ChangeNotifier {
  final CatalogDataSource _dataSource;

  CatalogProvider(this._dataSource);

  PaginatedProducts _state = PaginatedProducts.empty();
  bool _isLoading = false;
  final bool _isLoadingMore = false;
  String? _error;

  List get products => _state.products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  Future<void> load(CatalogQuery query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _state = await _dataSource.fetchProducts(query);
    } catch (e) {
      _error = e.toString();
      _state = PaginatedProducts.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
