import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class ContentService {
  final ApiClient _apiClient;

  ContentService(this._apiClient);

  Future<Response> getPage(String handle) async {
    return await _apiClient.dio.get(ApiEndpoints.pageDetail(handle));
  }

  Future<Response> getPortfolios() async {
    return await _apiClient.dio.get(ApiEndpoints.portfolios);
  }

  Future<Response> getPortfolioDetail(String slug) async {
    return await _apiClient.dio.get(ApiEndpoints.portfolioDetail(slug));
  }

  Future<Response> getCollections() async {
    return await _apiClient.dio.get(ApiEndpoints.collections);
  }

  Future<Response> getCollectionProducts(String handle) async {
    return await _apiClient.dio.get(ApiEndpoints.collectionProducts(handle));
  }
}
