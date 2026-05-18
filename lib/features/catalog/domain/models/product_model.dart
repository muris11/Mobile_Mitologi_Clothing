import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? salePrice;
  final String featuredImageUrl;
  final bool isFeatured;
  final bool isNew;
  final bool availableForSale;
  final int stock;
  final int totalSold;
  final double? rating;
  final int reviewsCount;
  final String? vendor;

  const ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.salePrice,
    required this.featuredImageUrl,
    this.isFeatured = false,
    this.isNew = false,
    this.availableForSale = true,
    required this.stock,
    this.totalSold = 0,
    this.rating,
    this.reviewsCount = 0,
    this.vendor,
  });

  bool get onSale => salePrice != null && salePrice! < price;
  double get displayPrice => onSale ? salePrice! : price;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final featuredImage = ParserUtils.parseMap(json['featuredImage']);
    final priceRange = ParserUtils.parseMap(json['priceRange']);
    final minVariantPrice = ParserUtils.parseMap(priceRange['minVariantPrice']);

    return ProductModel(
      id: ParserUtils.parseInt(json['id']),
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? json['handle'] as String? ?? json['link'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: ParserUtils.parseDouble(
        json['price'] ?? minVariantPrice['amount'],
      ),
      salePrice: json['sale_price'] != null
          ? ParserUtils.parseDouble(json['sale_price'])
          : null,
      featuredImageUrl: json['featured_image_url'] as String? ??
          featuredImage['url'] as String? ??
          json['imageURL'] as String? ??
          '',
      isFeatured: ParserUtils.parseBool(json['is_featured']),
      isNew: ParserUtils.parseBool(json['is_new']),
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
      vendor: json['vendor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'price': price,
        'sale_price': salePrice,
        'featured_image_url': featuredImageUrl,
        'is_featured': isFeatured,
        'is_new': isNew,
        'availableForSale': availableForSale,
        'stock': stock,
        'totalSold': totalSold,
        'rating': rating,
        'reviews_count': reviewsCount,
        'vendor': vendor,
      };

  @override
  List<Object?> get props =>
      [id, name, slug, price, salePrice, featuredImageUrl, stock, vendor, availableForSale, totalSold];
}
