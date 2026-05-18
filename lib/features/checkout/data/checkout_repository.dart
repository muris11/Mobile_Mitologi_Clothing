import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
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

  Future<Map<String, dynamic>> placeOrder({
    required Map<String, dynamic> shippingAddress,
  }) async {
    final response = await _checkoutService.placeOrder(shippingAddress);
    final data = ParserUtils.parseMap(response.data['data']);
    return data;
  }

  Future<Map<String, dynamic>> payOrder(String orderNumber) async {
    final response = await _checkoutService.payOrder(orderNumber);
    final data = ParserUtils.parseMap(response.data['data']);
    return data;
  }

  Future<void> requestRefund(String orderNumber, String reason) async {
    await _checkoutService.requestRefund(orderNumber, reason);
  }

  Future<OrderModel> getOrderDetail(String orderNumber) async {
    final response = await _checkoutService.getOrderDetail(orderNumber);
    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(ParserUtils.parseMap(data));
  }

  Future<OrderModel?> confirmPayment(String orderNumber) async {
    final response = await _checkoutService.confirmPayment(orderNumber);
    final data = response.data['data'];
    if (data is Map && data['order'] != null) {
      return OrderModel.fromJson(ParserUtils.parseMap(data['order']));
    }
    return null;
  }

  Future<void> addAddress(AddressModel address) async {
    await _checkoutService.addAddress(address.toJson());
  }

  Future<void> updateAddress(AddressModel address) async {
    await _checkoutService.updateAddress(address.id, address.toJson());
  }

  Future<void> deleteAddress(int id) async {
    await _checkoutService.deleteAddress(id);
  }
}
