import 'package:dio/dio.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/constants/api_endpoints.dart';

class AiService {
  final ApiClient _apiClient;

  AiService(this._apiClient);

  Future<Response> sendMessage({
    required String message,
    List<Map<String, String>>? history,
  }) async {
    final body = {
      'message': message,
      if (history != null) 'history': history,
    };

    return await _apiClient.dio.post(
      ApiEndpoints.chatbot,
      data: body,
    );
  }

  Future<Response> getRecommendations() async {
    return await _apiClient.dio.get(ApiEndpoints.aiRecommendations);
  }

  Future<Response> trackInteraction({
    required int productId,
    required String action,
  }) async {
    return await _apiClient.dio.post(
      ApiEndpoints.interactionsBatch,
      data: {
        'interactions': [
          {
            'product_id': productId,
            'action': action,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]
      },
    );
  }
}
