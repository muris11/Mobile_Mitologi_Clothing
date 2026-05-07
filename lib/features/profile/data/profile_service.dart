import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<Response> getProfile() async {
    return await _apiClient.dio.get(ApiEndpoints.user);
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _apiClient.dio.put(ApiEndpoints.profile, data: data);
  }

  Future<Response> updateAvatar(String imagePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imagePath),
    });
    return await _apiClient.dio.post(ApiEndpoints.profile, data: formData);
  }

  Future<Response> getOrders() async {
    return await _apiClient.dio.get(ApiEndpoints.orders);
  }

  Future<Response> getOrderDetail(String orderNumber) async {
    return await _apiClient.dio.get(ApiEndpoints.orderDetail(orderNumber));
  }
}
