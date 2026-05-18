import 'dart:developer';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
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
      if (data is Map) {
        final parsed = ParserUtils.parseMap(data);
        final innerData = parsed['data'];
        if (innerData is Map) {
          return ChatResponse.fromJson(Map<String, dynamic>.from(innerData));
        }
        return ChatResponse.fromJson(parsed);
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
      if (data is Map) {
        final map = ParserUtils.parseMap(data);
        items = map['data'] ?? map['recommendations'] ?? [];
      } else if (data is List) {
        items = data;
      }
      
      return ParserUtils.parseList(items, AiRecommendation.fromJson);
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
