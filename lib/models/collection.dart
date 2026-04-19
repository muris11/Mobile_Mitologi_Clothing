import 'product.dart';

/// Collection model
class Collection {
  final int id;
  final String handle;
  final String title;
  final String? description;
  final String? descriptionHtml;
  final String? imageUrl;
  final int? productCount;
  final List<Product>? products;

  Collection({
    required this.id,
    required this.handle,
    required this.title,
    this.description,
    this.descriptionHtml,
    this.imageUrl,
    this.productCount,
    this.products,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    final collectionData = json['collection'] ?? json;

    return Collection(
      id: collectionData['id'] as int,
      handle: collectionData['handle'] as String,
      title: collectionData['title'] ?? collectionData['name'] as String,
      description: collectionData['description'] as String?,
      descriptionHtml: collectionData['description_html'] as String?,
      imageUrl:
          collectionData['image_url'] ??
          collectionData['image']?['url'] as String?,
      productCount:
          collectionData['product_count'] ??
          collectionData['products_count'] as int?,
      products: collectionData['products'] != null
          ? (collectionData['products'] as List)
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
