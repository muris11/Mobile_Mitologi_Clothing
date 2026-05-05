import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class FacilityModel {
  final int id;
  final String name;
  final String description;
  final String image;

  FacilityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}
