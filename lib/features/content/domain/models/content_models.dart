import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class CmsPage extends Equatable {
  final String handle;
  final String title;
  final String body;
  final String? excerpt;
  final String? imageUrl;
  final DateTime? updatedAt;

  const CmsPage({
    required this.handle,
    required this.title,
    required this.body,
    this.excerpt,
    this.imageUrl,
    this.updatedAt,
  });

  factory CmsPage.fromJson(Map<String, dynamic> json) {
    return CmsPage(
      handle: json['handle'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['content'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      imageUrl: json['image_url'] as String? ?? json['featured_image'] as String?,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [handle, title, body, excerpt, imageUrl, updatedAt];
}

class PortfolioItem extends Equatable {
  final String slug;
  final String title;
  final String? description;
  final String? category;
  final String? imageUrl;
  final List<String>? gallery;
  final String? client;
  final String? year;

  const PortfolioItem({
    required this.slug,
    required this.title,
    this.description,
    this.category,
    this.imageUrl,
    this.gallery,
    this.client,
    this.year,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      gallery: json['gallery'] != null ? List<String>.from(json['gallery']) : null,
      client: json['client'] as String?,
      year: json['year']?.toString(),
    );
  }

  @override
  List<Object?> get props => [slug, title, description, category, imageUrl, gallery, client, year];
}

class CollectionDetail extends Equatable {
  final int id;
  final String handle;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<ProductModel>? products;

  const CollectionDetail({
    required this.id,
    required this.handle,
    required this.title,
    this.description,
    this.imageUrl,
    this.products,
  });

  factory CollectionDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return CollectionDetail(
      id: ParserUtils.parseInt(data['id']),
      handle: data['handle'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      imageUrl: data['image_url'] as String?,
      products: data['products'] != null 
          ? (data['products'] as List).whereType<Map<String, dynamic>>().map((e) => ProductModel.fromJson(e)).toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [id, handle, title, description, imageUrl, products];
}

