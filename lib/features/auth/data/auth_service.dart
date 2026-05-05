import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Response> login(String email, String password) async {
    return await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return await _apiClient.dio.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        if (phone != null) 'phone': phone,
      },
    );
  }

  Future<Response> logout() async {
    return await _apiClient.dio.post(ApiEndpoints.logout);
  }

  Future<Response> getUser() async {
    return await _apiClient.dio.get(ApiEndpoints.user);
  }

  Future<Response> forgotPassword(String email) async {
    return await _apiClient.dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<Response> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    return await _apiClient.dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
  }
}
