import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/cart/data/cart_repository.dart';
import 'package:mitologi_clothing_mobile/features/cart/domain/models/cart_model.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartViewModel(this._cartRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CartModel? _cart;
  CartModel? get cart => _cart;

  String? _error;
  String? get error => _error;

  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _cartRepository.getCart();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({
    required int productId,
    required int quantity,
    int? variantId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _cartRepository.addToCart(
        productId: productId,
        quantity: quantity,
        variantId: variantId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    try {
      _cart = await _cartRepository.updateQuantity(itemId, quantity);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int itemId) async {
    try {
      _cart = await _cartRepository.removeFromCart(itemId);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    try {
      await _cartRepository.clearCart();
      _cart = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
