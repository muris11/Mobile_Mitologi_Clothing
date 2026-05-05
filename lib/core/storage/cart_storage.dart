import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CartStorage {
  static const String _cartIdKey = 'cart_id';

  Future<String?> getCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cartIdKey);
  }

  Future<void> saveCartId(String cartId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartIdKey, cartId);
  }

  Future<String> getOrCreateCartId() async {
    String? cartId = await getCartId();
    if (cartId == null) {
      cartId = const Uuid().v4();
      await saveCartId(cartId);
    }
    return cartId;
  }

  Future<void> deleteCartId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartIdKey);
  }
}
