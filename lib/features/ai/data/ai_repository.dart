import 'dart:developer';
import 'package:mitologi_clothing_mobile/features/ai/domain/models/ai_models.dart';
import 'ai_service.dart';

class AiRepository {
  final AiService _aiService;

  AiRepository(this._aiService);

  Future<ChatResponse?> sendMessage(String message, [List<ChatMessage>? history]) async {
    try {
      final historyJson = history?.map((e) => e.toApiJson()).toList();
      final response = await _aiService.sendMessage(
        message: message,
        history: historyJson,
      );
      
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      log('Error in AI sendMessage: $e');
      return null;
    }
  }

  Future<List<AiRecommendation>> getRecommendations() async {
    try {
      final response = await _aiService.getRecommendations();
      final data = response.data;
      
      List items = [];
      if (data is Map<String, dynamic>) {
        items = data['data'] ?? data['recommendations'] ?? [];
      } else if (data is List) {
        items = data;
      }
      
      return items
          .whereType<Map<String, dynamic>>()
          .map((e) => AiRecommendation.fromJson(e))
          .toList();
    } catch (e) {
      log('Error getting AI recommendations: $e');
      return [];
    }
  }

  Future<void> trackProductView(int productId) async {
    try {
      await _aiService.trackInteraction(productId: productId, action: 'view');
    } catch (_) {}
  }
}
