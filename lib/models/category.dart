import 'product.dart';

/// Category model
class Category {
  final int id;
  final String handle;
  final String title;
  final String? description;
  final String? imageUrl;
  final int? productCount;
  final List<Product>? products;

  Category({
    required this.id,
    required this.handle,
    required this.title,
    this.description,
    this.imageUrl,
    this.productCount,
    this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'] ?? json;

    return Category(
      id: categoryData['id'] as int,
      handle: categoryData['handle'] as String,
      title: categoryData['title'] ?? categoryData['name'] as String,
      description: categoryData['description'] as String?,
      imageUrl:
          categoryData['image_url'] ?? categoryData['image']?['url'] as String?,
      productCount:
          categoryData['product_count'] ??
          categoryData['products_count'] as int?,
      products: categoryData['products'] != null
          ? (categoryData['products'] as List)
                .map((p) => Product.fromJson(p))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'handle': handle,
      'title': title,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

/// Material model (for filtering)
class Material {
  final int id;
  final String name;
  final String? description;

  Material({required this.id, required this.name, this.description});

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
