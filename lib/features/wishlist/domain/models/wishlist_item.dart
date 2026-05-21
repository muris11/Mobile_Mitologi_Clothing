import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class WishlistItem extends Equatable {
  final int id;
  final int productId;
  final String name;
  final String slug;
  final double price;
  final double? salePrice;
  final String featuredImageUrl;
  final String? vendor;

  const WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.slug,
    required this.price,
    this.salePrice,
    required this.featuredImageUrl,
    this.vendor,
  });

  double get displayPrice => (salePrice != null && salePrice! < price) ? salePrice! : price;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final productJson = ParserUtils.parseMap(json['product'] ?? json);
    
    // In Shopify/E-Commerce APIs, the product object stores price inside a nested priceRange or directly.
    // If the top-level price is 0.0 or null, we check the nested productJson structure.
    double rawPrice = ParserUtils.parseDouble(json['price'] ?? productJson['price']);
    if (rawPrice == 0.0) {
      final priceRange = ParserUtils.parseMap(productJson['priceRange']);
      final minVariantPrice = ParserUtils.parseMap(priceRange['minVariantPrice']);
      rawPrice = ParserUtils.parseDouble(minVariantPrice['amount']);
    }

    double? rawSalePrice = ParserUtils.parseDouble(json['sale_price'] ?? productJson['sale_price'] ?? productJson['compare_at_price']);
    if (rawSalePrice == 0.0) {
      rawSalePrice = null;
    }
    
    return WishlistItem(
      id: ParserUtils.parseInt(json['id'] ?? productJson['id']),
      productId: ParserUtils.parseInt(json['product_id'] ?? productJson['id']),
      name: productJson['title'] as String? ?? productJson['name'] as String? ?? '',
      slug: productJson['handle'] as String? ?? productJson['slug'] as String? ?? '',
      price: rawPrice,
      salePrice: rawSalePrice,
      featuredImageUrl: _parseImageUrl(productJson),
      vendor: productJson['vendor'] as String?,
    );
  }


  static String _parseImageUrl(Map<dynamic, dynamic> json) {
    final image = json['featured_image'] ?? json['image'] ?? json['featuredImage'];
    if (image is String) return image;
    if (image is Map) {
      return image['url']?.toString() ?? image['src']?.toString() ?? '';
    }
    return json['featured_image_url']?.toString() ?? json['image_url']?.toString() ?? '';
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: productId,
      slug: slug,
      name: name,
      vendor: vendor,
      price: price,
      salePrice: salePrice,
      featuredImageUrl: featuredImageUrl,
      description: '', // Minimal for list views
      stock: 0,
    );
  }

  @override
  List<Object?> get props => [id, productId, name, slug, price, salePrice, featuredImageUrl, vendor];
}


