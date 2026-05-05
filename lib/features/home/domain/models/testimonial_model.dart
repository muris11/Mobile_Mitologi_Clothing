import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class TestimonialModel {
  final int id;
  final String name;
  final String role;
  final String content;
  final double rating;
  final String? avatarUrl;

  TestimonialModel({
    required this.id,
    required this.name,
    required this.role,
    required this.content,
    required this.rating,
    this.avatarUrl,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      role: (json['role'] as String?) ?? (json['position'] as String?) ?? '',
      content: json['content'] as String? ?? '',
      rating: ParserUtils.parseDouble(json['rating']),
      avatarUrl: (json['avatarUrl'] as String?) ??
          (json['avatar_url'] as String?) ??
          (json['imageUrl'] as String?) ??
          (json['imageURL'] as String?),
    );
  }
}
