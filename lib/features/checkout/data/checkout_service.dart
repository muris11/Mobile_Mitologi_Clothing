import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class CheckoutService {
  final ApiClient _apiClient;

  CheckoutService(this._apiClient);

  Future<Response> getAddresses() async {
    return await _apiClient.dio.get(ApiEndpoints.addresses);
  }

  Future<Response> addAddress(Map<String, dynamic> data) async {
    return await _apiClient.dio.post(ApiEndpoints.addresses, data: data);
  }

  Future<Response> updateAddress(int id, Map<String, dynamic> data) async {
    return await _apiClient.dio.put('${ApiEndpoints.addresses}/$id', data: data);
  }

  Future<Response> placeOrder(Map<String, dynamic> shippingAddress) async {
    return await _apiClient.dio.post(
      ApiEndpoints.checkout,
      data: shippingAddress,
    );
  }

  Future<Response> payOrder(String orderNumber) async {
    return await _apiClient.dio.post(ApiEndpoints.orderPay(orderNumber));
  }

  Future<Response> requestRefund(String orderNumber, String reason) async {
    return await _apiClient.dio.post(
      ApiEndpoints.requestRefund(orderNumber),
      data: {'reason': reason},
    );
  }

  Future<Response> getOrderDetail(String orderNumber) async {
    return await _apiClient.dio.get(ApiEndpoints.orderDetail(orderNumber));
  }
}
