import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class PortfolioItemModel {
  final int id;
  final String title;
  final String slug;
  final String category;
  final String description;
  final String imageUrl;

  PortfolioItemModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.description,
    required this.imageUrl,
  });

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      id: ParserUtils.parseInt(json['id']),
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? (json['image_url'] as String?) ?? (json['imageURL'] as String?) ?? (json['image'] as String?) ?? '',
    );
  }
}
