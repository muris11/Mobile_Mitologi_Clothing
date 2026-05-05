import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class PrintingMethodModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String image;
  final List<String> pros;
  final String priceRange;

  PrintingMethodModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.image,
    required this.pros,
    required this.priceRange,
  });

  factory PrintingMethodModel.fromJson(Map<String, dynamic> json) {
    return PrintingMethodModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      pros: (json['pros'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      priceRange: json['priceRange'] as String? ?? json['price_range'] as String? ?? '',
    );
  }
}
