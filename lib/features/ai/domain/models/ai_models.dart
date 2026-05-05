import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

enum MessageRole { user, assistant }

class ChatMessage extends Equatable {
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String content) =>
      ChatMessage(content: content, role: MessageRole.user);

  factory ChatMessage.assistant(String content) =>
      ChatMessage(content: content, role: MessageRole.assistant);

  Map<String, String> toApiJson() => {
        'role': role == MessageRole.user ? 'user' : 'assistant',
        'content': content,
      };

  @override
  List<Object?> get props => [content, role, timestamp];
}

class ChatResponse extends Equatable {
  final String reply;
  final List<AiRecommendation>? recommendations;

  const ChatResponse({
    required this.reply,
    this.recommendations,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final recommendationsJson = json['products'] ?? json['recommendations'];

    return ChatResponse(
      reply: json['reply'] as String? ?? json['message'] as String? ?? '',
      recommendations: recommendationsJson != null
          ? ParserUtils.parseList(
              recommendationsJson, AiRecommendation.fromJson)
          : null,
    );
  }

  @override
  List<Object?> get props => [reply, recommendations];
}

class AiRecommendation extends Equatable {
  final int productId;
  final String name;
  final String? handle;
  final String? imageUrl;
  final double? price;

  const AiRecommendation({
    required this.productId,
    required this.name,
    this.handle,
    this.imageUrl,
    this.price,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      productId: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      handle: json['handle'] as String? ?? json['slug'] as String?,
      imageUrl:
          json['image_url'] as String? ?? json['featured_image'] as String?,
      price: ParserUtils.parseDouble(json['price']),
    );
  }

  @override
  List<Object?> get props => [productId, name, handle, imageUrl, price];
}
