class ProductDetailModel {
  final int id;
  final String handle;
  final String title;
  final double? priceAmount;
  final String? primaryImageUrl;

  const ProductDetailModel({
    required this.id,
    required this.handle,
    required this.title,
    required this.priceAmount,
    required this.primaryImageUrl,
  });
}
