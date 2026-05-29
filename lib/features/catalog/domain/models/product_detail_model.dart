import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class ProductDetailModel extends ProductModel {
  final List<String> images;
  final List<ProductVariant> variants;
  final List<ProductReview> reviews;
  final List<ProductModel> relatedProducts;
  final List<ProductOption> options;
  final List<String> tags;
  final String? descriptionHtml;

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
    super.availableForSale,
    required super.stock,
    super.totalSold,
    super.rating,
    super.reviewsCount,
    required this.images,
    required this.variants,
    required this.reviews,
    required this.relatedProducts,
    this.options = const [],
    this.tags = const [],
    this.descriptionHtml,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final featuredImage = ParserUtils.parseMap(json['featuredImage']);
    final priceRange = ParserUtils.parseMap(json['priceRange']);
    final minVariantPrice = ParserUtils.parseMap(priceRange['minVariantPrice']);
    final images = (json['images'] as List?) ?? const [];

    return ProductDetailModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? json['handle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionHtml: json['descriptionHtml'] as String? ??
          json['description_html'] as String?,
      price: ParserUtils.parseDouble(
        json['price'] ?? minVariantPrice['amount'],
      ),
      salePrice: json['sale_price'] != null
          ? ParserUtils.parseDouble(json['sale_price'])
          : null,
      featuredImageUrl: json['featured_image_url'] as String? ??
          featuredImage['url'] as String? ??
          '',
      isFeatured: ParserUtils.parseBool(json['is_featured']),
      isNew: ParserUtils.parseBool(json['is_new'] ?? json['availableForSale']),
      availableForSale: ParserUtils.parseBool(json['availableForSale'] ?? true),
      stock: ParserUtils.parseInt(json['stock'] ?? json['totalStock']),
      totalSold: ParserUtils.parseInt(json['totalSold']),
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
            (e) => e is Map ? e['url']?.toString() ?? '' : e.toString(),
          )
          .where((e) => e.isNotEmpty)
          .toList(),
      variants:
          ParserUtils.parseList(json['variants'], ProductVariant.fromJson),
      reviews: ParserUtils.parseList(json['reviews'], ProductReview.fromJson),
      relatedProducts: ParserUtils.parseList(
          json['related_products'], ProductModel.fromJson),
      options: ParserUtils.parseList(json['options'], ProductOption.fromJson),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        images,
        variants,
        reviews,
        relatedProducts,
        options,
        tags,
        descriptionHtml
      ];
}

class ProductOption extends Equatable {
  final int id;
  final String name;
  final List<String> values;

  const ProductOption({
    required this.id,
    required this.name,
    this.values = const [],
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? '',
      values:
          (json['values'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, name, values];
}

class ProductVariant extends Equatable {
  final int id;
  final String name;
  final String? value;
  final int stock;
  final bool availableForSale;
  final double priceAdjustment;
  final String? sku;
  final List<ProductSelectedOption> selectedOptions;

  const ProductVariant({
    required this.id,
    required this.name,
    this.value,
    required this.stock,
    this.availableForSale = true,
    this.priceAdjustment = 0,
    this.sku,
    this.selectedOptions = const [],
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final selectedOptions = (json['selectedOptions'] as List?) ?? const [];
    final selectedLabel = selectedOptions
        .map((e) => e is Map ? e['value']?.toString() ?? '' : '')
        .where((value) => value.isNotEmpty)
        .join(' / ');

    return ProductVariant(
      id: ParserUtils.parseInt(json['id']),
      name:
          json['name'] as String? ?? json['title'] as String? ?? selectedLabel,
      value: json['value'] as String?,
      stock: ParserUtils.parseInt(json['stock']),
      availableForSale: ParserUtils.parseBool(json['availableForSale'] ?? true),
      priceAdjustment: ParserUtils.parseDouble(
        json['price_adjustment'] ??
            ParserUtils.parseMap(json['price'])['amount'],
      ),
      sku: json['sku'] as String?,
      selectedOptions: selectedOptions
          .map((e) => ProductSelectedOption(
                name: (e as Map)['name']?.toString() ?? '',
                value: e['value']?.toString() ?? '',
              ))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        value,
        stock,
        availableForSale,
        priceAdjustment,
        sku,
        selectedOptions
      ];
}

class ProductSelectedOption extends Equatable {
  final String name;
  final String value;

  const ProductSelectedOption({required this.name, required this.value});

  @override
  List<Object?> get props => [name, value];
}

class ReviewSummary extends Equatable {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;

  const ReviewSummary({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.ratingBreakdown = const {},
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    final breakdownRaw = json['ratingBreakdown'] as Map? ?? {};
    final breakdown = <int, int>{};
    for (final entry in breakdownRaw.entries) {
      final key = int.tryParse(entry.key.toString());
      if (key != null) {
        breakdown[key] = ParserUtils.parseInt(entry.value);
      }
    }

    return ReviewSummary(
      averageRating: ParserUtils.parseDouble(
          json['averageRating'] ?? json['average_rating']),
      totalReviews:
          ParserUtils.parseInt(json['totalReviews'] ?? json['total_reviews']),
      ratingBreakdown: breakdown,
    );
  }

  @override
  List<Object?> get props => [averageRating, totalReviews, ratingBreakdown];
}

class ProductReview extends Equatable {
  final int id;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final String? adminReply;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.adminReply,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    final user = ParserUtils.parseMap(json['user']);
    final userName = json['user_name'] as String? ??
        json['userName'] as String? ??
        user['name'] as String? ??
        'Anonymous';
    final userAvatar = json['user_avatar'] as String? ??
        json['userAvatar'] as String? ??
        user['avatar_url'] as String? ??
        user['avatarUrl'] as String? ??
        user['avatar'] as String?;

    return ProductReview(
      id: ParserUtils.parseInt(json['id']),
      userName: userName,
      userAvatar: userAvatar,
      rating: ParserUtils.parseDouble(json['rating']),
      comment: json['comment'] as String? ?? '',
      adminReply:
          json['admin_reply'] as String? ?? json['adminReply'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ??
              json['createdAt']?.toString() ??
              '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, userName, userAvatar, rating, comment, adminReply, createdAt];
}
