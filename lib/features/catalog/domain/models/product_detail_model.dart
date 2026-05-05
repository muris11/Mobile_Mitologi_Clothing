import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class ProductDetailModel extends ProductModel {
  final List<String> images;
  final List<ProductVariant> variants;
  final List<ProductReview> reviews;
  final List<ProductModel> relatedProducts;

  const ProductDetailModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.description,
    required super.price,
    super.salePrice,
    required super.featuredImageUrl,
    super.isFeatured,
    super.isNew,
    required super.stock,
    super.rating,
    super.reviewsCount,
    required this.images,
    required this.variants,
    required this.reviews,
    required this.relatedProducts,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final featuredImage = json['featuredImage'] as Map<String, dynamic>?;
    final priceRange = json['priceRange'] as Map<String, dynamic>?;
    final minVariantPrice =
        priceRange?['minVariantPrice'] as Map<String, dynamic>?;
    final images = (json['images'] as List?) ?? const [];

    return ProductDetailModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? json['handle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: ParserUtils.parseDouble(
        json['price'] ?? minVariantPrice?['amount'],
      ),
      salePrice: json['sale_price'] != null
          ? ParserUtils.parseDouble(json['sale_price'])
          : null,
      featuredImageUrl: json['featured_image_url'] as String? ??
          featuredImage?['url'] as String? ??
          '',
      isFeatured: ParserUtils.parseBool(json['is_featured']),
      isNew: ParserUtils.parseBool(json['is_new'] ?? json['availableForSale']),
      stock: ParserUtils.parseInt(json['stock'] ?? json['totalStock']),
      rating: json['rating'] != null
          ? ParserUtils.parseDouble(json['rating'])
          : json['averageRating'] != null
              ? ParserUtils.parseDouble(json['averageRating'])
              : null,
      reviewsCount: ParserUtils.parseInt(
        json['reviews_count'] ?? json['totalReviews'],
      ),
      images: images
          .map(
            (e) => e is Map<String, dynamic>
                ? e['url']?.toString() ?? ''
                : e.toString(),
          )
          .where((e) => e.isNotEmpty)
          .toList(),
      variants:
          ParserUtils.parseList(json['variants'], ProductVariant.fromJson),
      reviews: ParserUtils.parseList(json['reviews'], ProductReview.fromJson),
      relatedProducts: ParserUtils.parseList(
          json['related_products'], ProductModel.fromJson),
    );
  }

  @override
  List<Object?> get props =>
      [...super.props, images, variants, reviews, relatedProducts];
}

class ProductVariant extends Equatable {
  final int id;
  final String name;
  final String? value;
  final int stock;
  final double priceAdjustment;

  const ProductVariant({
    required this.id,
    required this.name,
    this.value,
    required this.stock,
    this.priceAdjustment = 0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final selectedOptions = (json['selectedOptions'] as List?) ?? const [];
    final selectedLabel = selectedOptions
        .map((e) =>
            e is Map<String, dynamic> ? e['value']?.toString() ?? '' : '')
        .where((value) => value.isNotEmpty)
        .join(' / ');

    return ProductVariant(
      id: ParserUtils.parseInt(json['id']),
      name:
          json['name'] as String? ?? json['title'] as String? ?? selectedLabel,
      value: json['value'] as String?,
      stock: ParserUtils.parseInt(json['stock']),
      priceAdjustment: ParserUtils.parseDouble(
        json['price_adjustment'] ??
            (json['price'] as Map<String, dynamic>?)?['amount'],
      ),
    );
  }

  @override
  List<Object?> get props => [id, name, value, stock, priceAdjustment];
}

class ProductReview extends Equatable {
  final int id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: ParserUtils.parseInt(json['id']),
      userName: json['user_name'] as String? ?? 'Anonymous',
      rating: ParserUtils.parseDouble(json['rating']),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userName, rating, comment, createdAt];
}
