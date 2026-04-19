import '../domain/product_detail_model.dart';

class ProductDetailMapper {
  ProductDetailMapper._();

  static ProductDetailModel map(Map<String, dynamic> json) {
    final directPrice = _readDirectPrice(json['price']);
    final rangedPrice = _readPriceRange(json['priceRange']);
    final image = _readPrimaryImage(json);

    return ProductDetailModel(
      id: (json['id'] as num).toInt(),
      handle: json['handle']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      priceAmount: directPrice ?? rangedPrice,
      primaryImageUrl: image,
    );
  }

  static double? _readDirectPrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is Map<String, dynamic>) {
      final amount = value['amount'] ?? value['value'];
      if (amount is num) return amount.toDouble();
      if (amount is String) return double.tryParse(amount);
    }
    return null;
  }

  static double? _readPriceRange(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    final minPrice = value['minVariantPrice'] ?? value['minPrice'];
    return _readDirectPrice(minPrice);
  }

  static String? _readPrimaryImage(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List && images.isNotEmpty && images.first is Map<String, dynamic>) {
      final first = images.first as Map<String, dynamic>;
      return first['url']?.toString() ??
          first['src']?.toString() ??
          first['imageUrl']?.toString() ??
          first['image_url']?.toString();
    }

    final featuredImage = json['featuredImage'] ?? json['featured_image'];
    if (featuredImage is Map<String, dynamic>) {
      return featuredImage['url']?.toString() ??
          featuredImage['src']?.toString() ??
          featuredImage['imageUrl']?.toString() ??
          featuredImage['image_url']?.toString();
    }

    return null;
  }
}
