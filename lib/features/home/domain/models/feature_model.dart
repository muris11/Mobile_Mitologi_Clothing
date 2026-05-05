import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class FeatureModel {
  final int id;
  final String title;
  final String description;
  final String icon;
  final bool isActive;
  final int sortOrder;

  FeatureModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isActive,
    required this.sortOrder,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: ParserUtils.parseInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: ParserUtils.parseBool(json['isActive'] ?? json['is_active']),
      sortOrder: ParserUtils.parseInt(json['sortOrder'] ?? json['sort_order']),
    );
  }
}
