import '../config/api_config.dart';
import 'api_service.dart';

/// Service for AI chatbot operations
class ChatbotService {
  final ApiService _apiService;

  ChatbotService(this._apiService);

  Map<String, dynamic> _unwrapResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }

  /// Send message to AI chatbot (Groq/Llama)
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    List<Map<String, String>>? history,
  }) async {
    final body = <String, dynamic>{
      'message': message,
    };

    if (history != null && history.isNotEmpty) {
      body['history'] = history;
    }

    final response = await _apiService.post(
      ApiEndpoints.chatbot,
      body: body,
      requiresAuth: false,
    );

    return _unwrapResponse(response);
  }

  /// Get chatbot text response only
  Future<String> getChatResponse(String message) async {
    final response = await sendMessage(message: message);
    return response['reply'] ??
        response['message'] ??
        'Maaf, saya tidak mengerti.';
  }

  /// Get recommended products from chatbot response
  Future<List<Map<String, dynamic>>?> getRecommendedProducts(
      String message) async {
    final response = await sendMessage(message: message);
    final products = response['products'] ??
        response['recommendedProducts'] ??
        response['recommended_products'];
    if (products == null) return null;
    if (products is! List) return null;
    return products.whereType<Map<String, dynamic>>().toList();
  }
}
