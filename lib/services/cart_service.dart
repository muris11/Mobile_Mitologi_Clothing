import '../config/api_config.dart';
import '../core/session/cart_session_manager.dart';
import '../models/cart.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class CartService {
  final ApiService _apiService;
  final CartSessionManager _sessionManager;

  CartService(this._apiService, {CartSessionManager? sessionManager})
      : _sessionManager = sessionManager ?? CartSessionManager();

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }

  Future<String> createCart() async {
    final existingSessionId = await _sessionManager.loadCartSessionId();
    final sessionId = existingSessionId ?? await SecureStorageService.getOrCreateCartSessionId();
    final response =
        await _apiService.post(ApiEndpoints.cart, cartSessionId: sessionId);
    final data = _unwrapResponse(response);
    if (data.isNotEmpty && (data['cart_id'] != null || data['id'] != null)) {
      final cartId = (data['cart_id'] ?? data['id']).toString();
      await _sessionManager.saveCartSessionId(cartId);
      return cartId;
    }
    if (data.isNotEmpty && data['cartId'] != null) {
      final cartId = data['cartId'].toString();
      await _sessionManager.saveCartSessionId(cartId);
      return cartId;
    }
    await _sessionManager.saveCartSessionId(sessionId);
    return sessionId;
  }

  Future<Cart?> getCart() async {
    final sessionId = await _sessionManager.loadCartSessionId();
    if (sessionId == null) return null;
    try {
      final response =
          await _apiService.get(ApiEndpoints.cart, cartSessionId: sessionId);
      final data = _unwrapResponse(response);
      final cartData = data['cart'] is Map<String, dynamic>
          ? data['cart'] as Map<String, dynamic>
          : data;
      return cartData.isEmpty ? null : Cart.fromJson(cartData);
    } catch (e) {
      return null;
    }
  }

  Future<Cart> addItem(
      {required String merchandiseId, required int quantity}) async {
    final sessionId = await _sessionManager.loadCartSessionId() ??
        await SecureStorageService.getOrCreateCartSessionId();
    await _sessionManager.saveCartSessionId(sessionId);
    final response = await _apiService.post(ApiEndpoints.cartItems,
        body: {
          'merchandise_id': merchandiseId,
          'quantity': quantity,
        },
        cartSessionId: sessionId);
    final data = _unwrapResponse(response);
    final cartData = data['cart'] is Map<String, dynamic>
        ? data['cart'] as Map<String, dynamic>
        : data;
    return Cart.fromJson(cartData);
  }

  Future<Cart> updateItem(String itemId,
      {required String merchandiseId, required int quantity}) async {
    final sessionId = await _sessionManager.loadCartSessionId();
    if (sessionId == null) throw Exception('Cart session not found');
    final response = await _apiService.put(ApiEndpoints.cartItem(itemId),
        body: {
          'merchandise_id': merchandiseId,
          'quantity': quantity,
        },
        cartSessionId: sessionId);
    final data = _unwrapResponse(response);
    final cartData = data['cart'] is Map<String, dynamic>
        ? data['cart'] as Map<String, dynamic>
        : data;
    return Cart.fromJson(cartData);
  }

  Future<Cart> removeItem(String itemId) async {
    final sessionId = await _sessionManager.loadCartSessionId();
    if (sessionId == null) throw Exception('Cart session not found');
    final response = await _apiService.delete(ApiEndpoints.cartItem(itemId),
        cartSessionId: sessionId);
    final data = _unwrapResponse(response);
    final cartData = data['cart'] is Map<String, dynamic>
        ? data['cart'] as Map<String, dynamic>
        : data;
    return Cart.fromJson(cartData);
  }

  Future<Cart> clearCart() async {
    final sessionId = await _sessionManager.loadCartSessionId();
    if (sessionId == null) throw Exception('Cart session not found');
    final response = await _apiService.delete(ApiEndpoints.cartClear,
        cartSessionId: sessionId);
    final data = _unwrapResponse(response);
    final cartData = data['cart'] is Map<String, dynamic>
        ? data['cart'] as Map<String, dynamic>
        : data;
    return Cart.fromJson(cartData);
  }

  /// Merge guest cart with authenticated user cart
  /// Note: Backend handles cart merge automatically during login
  /// This function just clears the guest session after auth
  Future<void> mergeGuestCart(String authToken) async {
    final sessionId = await _sessionManager.loadCartSessionId();
    if (sessionId == null) return;

    // Clear guest session - backend auto-merges during login
    await _sessionManager.clearCartSessionId();
  }

  /// Check if guest cart exists
  Future<bool> hasGuestCart() async {
    final sessionId = await _sessionManager.loadCartSessionId();
    if (sessionId == null) return false;

    try {
      final cart = await getCart();
      return cart != null && cart.items.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
