import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';
import 'checkout_service.dart';

class CheckoutRepository {
  final CheckoutService _checkoutService;

  CheckoutRepository(this._checkoutService);

  Future<List<AddressModel>> getAddresses() async {
    final response = await _checkoutService.getAddresses();
    final List data = response.data['data'] ?? [];
    return data.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<OrderModel> placeOrder({
    required int addressId,
    required String shippingMethod,
    String? note,
  }) async {
    final response = await _checkoutService.placeOrder(
      addressId: addressId,
      shippingMethod: shippingMethod,
      note: note,
    );
    return OrderModel.fromJson(response.data['data']);
  }

  Future<void> addAddress(AddressModel address) async {
    await _checkoutService.addAddress(address.toJson());
  }

  Future<void> updateAddress(AddressModel address) async {
    await _checkoutService.updateAddress(address.id, address.toJson());
  }
}
