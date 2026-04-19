import '../../../models/product.dart';

class PaginatedProducts {
  final List<Product> products;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const PaginatedProducts({
    required this.products,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedProducts.empty() {
    return const PaginatedProducts(
      products: [],
      total: 0,
      perPage: 0,
      currentPage: 1,
      lastPage: 1,
    );
  }
}
