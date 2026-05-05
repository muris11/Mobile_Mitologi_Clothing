import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class PartnerModel {
  final int id;
  final String name;
  final String logo;
  final String? websiteUrl;
  final String description;

  PartnerModel({
    required this.id,
    required this.name,
    required this.logo,
    this.websiteUrl,
    required this.description,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      logo: (json['logo'] as String?) ?? (json['imageUrl'] as String?) ?? (json['imageURL'] as String?) ?? (json['image'] as String?) ?? '',
      websiteUrl: json['websiteUrl'] as String? ?? json['website_url'] as String?,
      description: json['description'] as String? ?? '',
    );
  }
}
