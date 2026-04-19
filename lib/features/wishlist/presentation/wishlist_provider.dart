import 'package:flutter/foundation.dart';

abstract class WishlistDataSource {
  Future<List<int>> fetchWishlistIds();
  Future<void> save(int productId);
  Future<void> remove(int productId);
}

class WishlistProvider extends ChangeNotifier {
  final WishlistDataSource _source;

  WishlistProvider(this._source);

  final Set<int> _ids = {};
  bool _isLoading = false;
  String? _error;

  Set<int> get ids => _ids;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ids
        ..clear()
        ..addAll(await _source.fetchWishlistIds());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(int productId) async {
    if (_ids.contains(productId)) {
      await _source.remove(productId);
    } else {
      await _source.save(productId);
    }

    final latest = await _source.fetchWishlistIds();
    _ids
      ..clear()
      ..addAll(latest);
    notifyListeners();
  }
}
