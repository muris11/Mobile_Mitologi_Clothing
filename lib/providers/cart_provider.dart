import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService;
  Cart? _cart;
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  CartProvider(this._cartService);

  Future<void> ensureInitialized() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    await loadCart();
  }

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasItems => _cart != null && _cart!.items.isNotEmpty;
  int get itemCount => _cart?.totalQuantity ?? 0;
  double get total => _cart?.total ?? 0.0;
  List<CartItem> get items => _cart?.items ?? [];

  Future<void> loadCart() async {
    _setLoading(true);
    try {
      _cart = await _cartService.getCart();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addItem(
      {required String merchandiseId, required int quantity}) async {
    _setLoading(true);
    try {
      _cart = await _cartService.addItem(
          merchandiseId: merchandiseId, quantity: quantity);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateItem(String itemId,
      {required String merchandiseId, required int quantity}) async {
    _setLoading(true);
    try {
      _cart = await _cartService.updateItem(itemId,
          merchandiseId: merchandiseId, quantity: quantity);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeItem(String itemId) async {
    _setLoading(true);
    try {
      _cart = await _cartService.removeItem(itemId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> clearCart() async {
    _setLoading(true);
    try {
      _cart = await _cartService.clearCart();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
