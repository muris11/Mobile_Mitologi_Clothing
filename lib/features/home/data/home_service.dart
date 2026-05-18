import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class HomeService {
  final ApiClient _apiClient;

  HomeService(this._apiClient);

  Future<Response> getLandingPage() async {
    return await _apiClient.dio.get(ApiEndpoints.landingPage);
  }

  Future<Response> getBanners() async {
    return await _apiClient.dio.get(ApiEndpoints.landingPage);
  }

  Future<Response> getCategories() async {
    return await _apiClient.dio.get(ApiEndpoints.categories);
  }

  Future<Response> getBestSellers() async {
    return await _apiClient.dio.get(ApiEndpoints.bestSellers);
  }

  Future<Response> getNewArrivals() async {
    return await _apiClient.dio.get(ApiEndpoints.newArrivals);
  }

  Future<Response> getSiteSettings() async {
    return await _apiClient.dio.get(ApiEndpoints.siteSettings);
  }

  Future<Response> getTestimonials() async {
    return await _apiClient.dio.get(ApiEndpoints.landingPage);
  }

  Future<Response> getMaterials() async {
    return await _apiClient.dio.get(ApiEndpoints.materials);
  }

  Future<Response> getPortfolios() async {
    return await _apiClient.dio.get(ApiEndpoints.portfolios);
  }

  Future<Response> getTeamMembers() async {
    return await _apiClient.dio.get(ApiEndpoints.teamMembers);
  }

  Future<Response> getOrderSteps() async {
    return await _apiClient.dio.get(ApiEndpoints.orderSteps);
  }
}
