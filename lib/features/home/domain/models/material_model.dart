import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class MaterialModel {
  final int id;
  final String name;
  final String description;
  final String colorTheme;
  final String? image;

  MaterialModel({
    required this.id,
    required this.name,
    required this.description,
    required this.colorTheme,
    this.image,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      colorTheme: json['colorTheme'] as String? ?? json['color_theme'] as String? ?? '',
      image: (json['image'] as String?) ?? (json['imageUrl'] as String?) ?? (json['imageURL'] as String?),
    );
  }
}
