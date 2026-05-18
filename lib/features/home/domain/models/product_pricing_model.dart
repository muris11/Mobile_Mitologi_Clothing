import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class ProductPricingModel {
  final int id;
  final String categoryName;
  final List<PricingItem> items;
  final String? minOrder;
  final String? notes;
  final bool isActive;
  final int sortOrder;

  const ProductPricingModel({
    required this.id,
    required this.categoryName,
    required this.items,
    this.minOrder,
    this.notes,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ProductPricingModel.fromJson(Map<String, dynamic> json) {
    return ProductPricingModel(
      id: ParserUtils.parseInt(json['id']),
      categoryName: (json['categoryName'] as String?) ??
          (json['category_name'] as String?) ?? '',
      items: ParserUtils.parseList<PricingItem>(
        json['items'],
        (e) => PricingItem.fromJson(e),
      ),
      minOrder: (json['minOrder'] as String?) ?? (json['min_order'] as String?),
      notes: json['notes'] as String?,
      isActive: ParserUtils.parseBool(json['isActive'] ?? json['is_active'] ?? true),
      sortOrder: ParserUtils.parseInt(json['sortOrder'] ?? json['sort_order']),
    );
  }
}

class PricingItem {
  final String name;
  final String priceRange;

  const PricingItem({required this.name, required this.priceRange});

  factory PricingItem.fromJson(Map<String, dynamic> json) {
    return PricingItem(
      name: json['name'] as String? ?? '',
      priceRange: (json['priceRange'] as String?) ??
          (json['price_range'] as String?) ?? '',
    );
  }
}
