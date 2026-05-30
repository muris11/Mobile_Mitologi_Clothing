import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class BannerModel extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String? description;
  final String imageUrl;
  final String? link;
  final String? ctaText;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description,
    required this.imageUrl,
    this.link,
    this.ctaText,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: ParserUtils.parseInt(json['id']),
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? (json['sub_title'] as String?) ?? '',
      description: (json['description'] as String?) ?? (json['content'] as String?),
      imageUrl: (json['imageUrl'] as String?) ?? 
                (json['image_url'] as String?) ?? 
                (json['imageURL'] as String?) ?? 
                (json['image'] as String?) ?? '',
      link: (json['link'] as String?) ?? (json['ctaLink'] as String?) ?? (json['cta_link'] as String?),
      ctaText: (json['ctaText'] as String?) ?? (json['cta_text'] as String?) ?? (json['ctaLabel'] as String?),
    );
  }

  @override
  List<Object?> get props => [id, title, subtitle, description, imageUrl, link, ctaText];
}
