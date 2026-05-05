import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class HomeService {
  final ApiClient _apiClient;

  HomeService(this._apiClient);

  Future<Response> getLandingPage() async {
    return await _apiClient.dio.get(ApiEndpoints.landingPage);
  }
}
