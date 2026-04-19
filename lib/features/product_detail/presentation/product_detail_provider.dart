import 'package:flutter/foundation.dart';

import '../domain/product_detail_model.dart';

abstract class ProductDetailDataSource {
  Future<ProductDetailModel> fetchDetail(String handle);
  Future<List<Map<String, dynamic>>> fetchReviews(String handle);
  Future<List<Map<String, dynamic>>> fetchRelated(int productId);
}

class ProductDetailProvider extends ChangeNotifier {
  final ProductDetailDataSource _source;

  ProductDetailProvider(this._source);

  ProductDetailModel? _detail;
  List<Map<String, dynamic>> _reviews = const [];
  List<Map<String, dynamic>> _related = const [];
  bool _isLoading = false;
  String? _error;

  ProductDetailModel? get detail => _detail;
  List<Map<String, dynamic>> get reviews => _reviews;
  List<Map<String, dynamic>> get related => _related;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String handle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detail = await _source.fetchDetail(handle);
      final reviews = await _source.fetchReviews(handle);
      final related = await _source.fetchRelated(detail.id);

      _detail = detail;
      _reviews = reviews;
      _related = related;
    } catch (e) {
      _error = e.toString();
      _detail = null;
      _reviews = const [];
      _related = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
