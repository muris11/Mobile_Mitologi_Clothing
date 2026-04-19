import 'image_model.dart';
import 'money.dart';

/// Product model
class Product {
  final int id;
  final String handle;
  final String title;
  final String? description;
  final String? descriptionHtml;
  final Money? price;
  final Money? compareAtPrice;
  final PriceRange? priceRange;
  final List<ImageModel>? images;
  final ImageModel? featuredImage;
  final List<ProductVariant>? variants;
  final List<ProductOption>? options;
  final String? vendor;
  final String? productType;
  final List<String>? tags;
  final bool? availableForSale;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final int? quantity;
  final int? totalInventory;
  final int? totalStock;
  final CategoryInfo? category;
  final CollectionInfo? collection;
  final double? averageRating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.handle,
    required this.title,
    this.description,
    this.descriptionHtml,
    this.price,
    this.compareAtPrice,
    this.priceRange,
    this.images,
    this.featuredImage,
    this.variants,
    this.options,
    this.vendor,
    this.productType,
    this.tags,
    this.availableForSale,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.quantity,
    this.totalInventory,
    this.totalStock,
    this.category,
    this.collection,
    this.averageRating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle price from various possible formats
    Money? parsePrice(dynamic priceData) {
      if (priceData == null) return null;
      if (priceData is num) return Money(amount: priceData.toDouble());
      if (priceData is String) {
        final parsed = double.tryParse(priceData);
        if (parsed != null) return Money(amount: parsed);
      }
      if (priceData is Map<String, dynamic>) {
        try {
          return Money.fromJson(priceData);
        } catch (e) {
          // Try extract amount directly
          final amount = priceData['amount'] ?? priceData['value'];
          if (amount is num) {
            return Money(amount: amount.toDouble());
          } else if (amount is String) {
            final parsed = double.tryParse(amount);
            if (parsed != null) return Money(amount: parsed);
          }
        }
      }
      return null;
    }

    // Parse ID (handle both int and string)
    final id = int.tryParse(
        json['id']?.toString() ?? json['itemId']?.toString() ?? '') ??
      (json['id'] as int? ?? json['itemId'] as int? ?? 0);

    // Handle handle (fallback to id if not present)
    final handle = json['handle'] as String? ??
      json['slug'] as String? ??
      json['product_handle'] as String? ??
      json['item_handle'] as String? ??
      id.toString();

    final title = (json['title'] ??
        json['name'] ??
        json['itemName'] ??
        json['product_name'] ??
        json['productName'] ??
        json['label'] ??
        'Untitled Product')
      .toString();

    // Parse price - try multiple sources
    Money? price = parsePrice(json['price']);

    // If no price, try from priceRange
    if (price == null) {
      final priceRange = json['priceRange'];
      if (priceRange is Map<String, dynamic>) {
        final minPrice =
            priceRange['minVariantPrice'] ?? priceRange['minPrice'];
        price = parsePrice(minPrice);
      }
    }

    // If still no price, try from first variant
    if (price == null) {
      final variants = json['variants'];
      if (variants is List && variants.isNotEmpty) {
        final firstVariant = variants.first as Map<String, dynamic>;
        price = parsePrice(firstVariant['price']);
      }
    }

    ImageModel? featuredImage;
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final firstImage = images.first;
      if (firstImage is Map<String, dynamic>) {
        featuredImage = ImageModel(
          url: firstImage['url']?.toString() ??
              firstImage['src']?.toString() ??
              firstImage['imageUrl']?.toString() ??
              firstImage['image_url']?.toString() ??
              '',
          altText: firstImage['altText']?.toString() ?? title,
        );
      } else if (firstImage is String && firstImage.isNotEmpty) {
        featuredImage = ImageModel(url: firstImage, altText: title);
      }
    }

    ImageModel? parseImage(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return ImageModel(url: value, altText: title);
      }
      if (value is Map<String, dynamic>) {
        final url = value['url']?.toString() ??
            value['src']?.toString() ??
            value['imageUrl']?.toString() ??
            value['image_url']?.toString() ??
            '';
        if (url.isEmpty) return null;
        return ImageModel(url: url, altText: value['altText']?.toString() ?? title);
      }
      return null;
    }

    featuredImage ??= parseImage(json['featured_image']) ??
        parseImage(json['featuredImage']) ??
        parseImage(json['image']) ??
        parseImage(json['imageUrl']) ??
        parseImage(json['image_url']);

    return Product(
      id: id,
      handle: handle,
      title: title,
      description: json['description'] as String?,
      descriptionHtml: json['description_html'] as String?,
      price: price,
      compareAtPrice: parsePrice(json['compare_at_price']),
      priceRange: json['priceRange'] != null
          ? PriceRange.fromJson(json['priceRange'])
          : null,
        images: json['images'] != null && json['images'] is List
          ? (json['images'] as List)
            .whereType<Map<String, dynamic>>()
            .map((i) => ImageModel.fromJson(i))
            .toList()
          : null,
        featuredImage: featuredImage,
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((v) => ProductVariant.fromJson(v))
              .toList()
          : null,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((o) => ProductOption.fromJson(o))
              .toList()
          : null,
      vendor: json['vendor'] as String?,
        productType: json['product_type'] ??
          json['productType'] ??
          json['category'] as String?,
      tags: json['tags'] != null
          ? (json['tags'] as List).map((t) => t.toString()).toList()
          : null,
      availableForSale: json['available_for_sale'] ??
          json['inStock'] ??
          json['in_stock'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      quantity: _parseInt(json['quantity']),
      totalInventory: _parseInt(json['total_inventory']),
      totalStock: _parseInt(json['total_stock']),
      category:
          json['category'] != null && json['category'] is Map<String, dynamic>
              ? CategoryInfo.fromJson(json['category'])
              : null,
      collection: json['collection'] != null &&
              json['collection'] is Map<String, dynamic>
          ? CollectionInfo.fromJson(json['collection'])
          : null,
      averageRating: _parseDouble(json['averageRating']) ??
          _parseDouble(json['average_rating']),
      reviewCount: _parseInt(json['totalReviews'] ?? json['review_count']),
    );
  }

  /// Parse int safely from various types
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse double safely from various types
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'handle': handle,
      'title': title,
      'description': description,
      'price': price?.toJson(),
      'featured_image': featuredImage?.toJson(),
    };
  }

  /// Get first variant or default
  ProductVariant? get firstVariant =>
      variants != null && variants!.isNotEmpty ? variants!.first : null;

  /// Get minimum price
  Money? get minPrice => priceRange?.minPrice ?? price;

  /// Check if product is on sale
  bool get isOnSale =>
      compareAtPrice != null &&
      price != null &&
      compareAtPrice!.amount > price!.amount;

  /// Get discount percentage
  int? get discountPercentage {
    if (!isOnSale) return null;
    final discount = compareAtPrice!.amount - price!.amount;
    return ((discount / compareAtPrice!.amount) * 100).round();
  }
}

/// Price range for product
class PriceRange {
  final Money? minPrice;
  final Money? maxPrice;

  PriceRange({this.minPrice, this.maxPrice});

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      minPrice:
          json['minPrice'] != null && json['minPrice'] is Map<String, dynamic>
              ? Money.fromJson(json['minPrice'])
              : null,
      maxPrice:
          json['maxPrice'] != null && json['maxPrice'] is Map<String, dynamic>
              ? Money.fromJson(json['maxPrice'])
              : null,
    );
  }
}

/// Product variant
class ProductVariant {
  final String id;
  final String title;
  final Money? price;
  final Money? compareAtPrice;
  final int? quantityAvailable;
  final bool? availableForSale;
  final List<SelectedOption>? selectedOptions;
  final String? sku;
  final String? barcode;
  final int? stock;

  ProductVariant({
    required this.id,
    required this.title,
    this.price,
    this.compareAtPrice,
    this.quantityAvailable,
    this.availableForSale,
    this.selectedOptions,
    this.sku,
    this.barcode,
    this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString() ?? '0',
      title: json['title']?.toString() ?? 'Default',
      price: json['price'] != null && json['price'] is Map<String, dynamic>
          ? Money.fromJson(json['price'])
          : null,
      compareAtPrice: json['compare_at_price'] != null &&
              json['compare_at_price'] is Map<String, dynamic>
          ? Money.fromJson(json['compare_at_price'])
          : null,
      quantityAvailable: Product._parseInt(json['quantity_available']),
      availableForSale: json['available_for_sale'] is bool
          ? json['available_for_sale']
          : json['available_for_sale']?.toString() == 'true',
      selectedOptions: json['selectedOptions'] != null &&
              json['selectedOptions'] is List
          ? (json['selectedOptions'] as List)
              .map((o) => SelectedOption.fromJson(o as Map<String, dynamic>))
              .toList()
          : null,
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      stock: Product._parseInt(json['stock']),
    );
  }
}

/// Selected option for variant (size, color, etc.)
class SelectedOption {
  final String name;
  final String value;

  SelectedOption({required this.name, required this.value});

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

/// Product option (size, color, etc.)
class ProductOption {
  final String id;
  final String name;
  final List<String> values;

  ProductOption({required this.id, required this.name, required this.values});

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      values: json['values'] is List
          ? (json['values'] as List).map((v) => v.toString()).toList()
          : [],
    );
  }
}

/// Category info for product
class CategoryInfo {
  final int id;
  final String handle;
  final String title;

  CategoryInfo({required this.id, required this.handle, required this.title});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: Product._parseInt(json['id']) ?? 0,
      handle: json['handle']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}

/// Collection info for product
class CollectionInfo {
  final int id;
  final String handle;
  final String title;

  CollectionInfo({required this.id, required this.handle, required this.title});

  factory CollectionInfo.fromJson(Map<String, dynamic> json) {
    return CollectionInfo(
      id: Product._parseInt(json['id']) ?? 0,
      handle: json['handle']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}
