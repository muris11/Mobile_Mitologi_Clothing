import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class CategoryModel extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? iconUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: ParserUtils.parseInt(json['id']),
      name: (json['name'] as String?) ?? (json['categoryName'] as String?) ?? (json['title'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? (json['handle'] as String?) ?? (json['link'] as String?) ?? '',
      iconUrl: (json['icon_url'] as String?) ?? (json['image'] as String?) ?? (json['imageURL'] as String?) ?? (json['imageUrl'] as String?),
    );
  }

  @override
  List<Object?> get props => [id, name, slug, iconUrl];
}
