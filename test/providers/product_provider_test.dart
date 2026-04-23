import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/product.dart';
import 'package:mitologi_clothing_mobile/providers/product_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/product_service.dart';

class FakeProductService extends ProductService {
  FakeProductService() : super(ApiService());

  Map<String, dynamic> landingPageData = {};
  List<Product> products = [];
  List<Product> bestSellers = [];
  List<Product> newArrivals = [];
  List<Map<String, dynamic>> categories = [];

  @override
  Future<Map<String, dynamic>> getLandingPage() async => landingPageData;

  @override
  Future<List<Product>> getProducts({
    String? query,
    String? category,
    String? sortKey,
    bool? reverse,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
    String? ids,
  }) async => products;

  @override
  Future<List<Product>> getBestSellers({int limit = 10}) async => bestSellers;

  @override
  Future<List<Product>> getNewArrivals({int limit = 10}) async => newArrivals;

  @override
  Future<List<Map<String, dynamic>>> getCategories() async => categories;
}

void main() {
  group('ProductProvider', () {
    test('loadHomeData parses landing page data', () async {
      final service = FakeProductService()
        ..landingPageData = {
          'data': {
            'heroSlides': [
              {
                'id': 1,
                'title': 'Slide 1',
                'subtitle': 'Subtitle 1',
                'imageUrl': 'https://example.com/image1.jpg',
                'ctaText': 'Belanja',
                'ctaLink': '/products',
              },
            ],
            'categories': [
              {
                'id': 1,
                'name': 'Kaos',
                'slug': 'kaos',
                'description': 'Kaos custom',
                'productsCount': 10,
              },
            ],
            'bestSellers': [
              {
                'id': 1,
                'title': 'Kaos Hitam',
                'price': 150000,
                'handle': 'kaos-hitam',
              },
            ],
            'newArrivals': [
              {
                'id': 2,
                'title': 'Kaos Putih',
                'price': 160000,
                'handle': 'kaos-putih',
              },
            ],
            'testimonials': [
              {'name': 'Customer 1', 'content': 'Bagus!'},
            ],
            'materials': [
              {'name': 'Cotton', 'description': 'Premium'},
            ],
          },
        };
      final provider = ProductProvider(service);

      await provider.loadHomeData();

      expect(provider.isLoading, isFalse);
      expect(provider.heroSlides.length, 1);
      expect(provider.heroSlides.first['title'], 'Slide 1');
      expect(provider.categories.length, 1);
      expect(provider.categories.first['name'], 'Kaos');
      expect(provider.bestSellers.length, 1);
      expect(provider.bestSellers.first.title, 'Kaos Hitam');
      expect(provider.newArrivals.length, 1);
      expect(provider.newArrivals.first.title, 'Kaos Putih');
      expect(provider.testimonials.length, 1);
      expect(provider.materials.length, 1);
    });

    test('loadHomeData with snake_case keys', () async {
      final service = FakeProductService()
        ..landingPageData = {
          'data': {
            'hero_slides': [
              {'id': 1, 'title': 'Slide Snake'},
            ],
            'best_sellers': [
              {'id': 1, 'title': 'Best Seller', 'price': 100000},
            ],
            'new_arrivals': [
              {'id': 2, 'title': 'New Arrival', 'price': 120000},
            ],
          },
        };
      final provider = ProductProvider(service);

      await provider.loadHomeData();

      expect(provider.heroSlides.length, 1);
      expect(provider.heroSlides.first['title'], 'Slide Snake');
      expect(provider.bestSellers.length, 1);
      expect(provider.newArrivals.length, 1);
    });

    test('loadHomeData handles empty response', () async {
      final service = FakeProductService()
        ..landingPageData = {};
      final provider = ProductProvider(service);

      await provider.loadHomeData();

      expect(provider.heroSlides, isEmpty);
      expect(provider.categories, isEmpty);
      expect(provider.bestSellers, isEmpty);
      expect(provider.newArrivals, isEmpty);
    });

    test('loadHomeData falls back to products when best sellers empty', () async {
      final service = FakeProductService()
        ..landingPageData = {
          'data': {
            'products': [
              {'id': 1, 'title': 'Fallback Product', 'price': 99000},
            ],
          },
        };
      final provider = ProductProvider(service);

      await provider.loadHomeData();

      expect(provider.bestSellers.length, 1);
      expect(provider.bestSellers.first.title, 'Fallback Product');
    });

    test('loadProducts loads and filters products', () async {
      final service = FakeProductService()
        ..products = [
          Product(
            id: 1,
            handle: 'kaos-1',
            title: 'Kaos Custom',
            price: null,
          ),
        ];
      final provider = ProductProvider(service);

      await provider.loadProducts(query: 'kaos');

      expect(provider.products.length, 1);
      expect(provider.products.first.title, 'Kaos Custom');
      expect(provider.currentQuery, 'kaos');
      expect(provider.isLoading, isFalse);
    });

    test('loadProducts with category filter', () async {
      final service = FakeProductService()
        ..products = [
          Product(id: 1, handle: 'polo-1', title: 'Polo Shirt', price: null),
        ];
      final provider = ProductProvider(service);

      await provider.loadProductsByCategory('polo');

      expect(provider.products.length, 1);
      expect(provider.currentCategory, 'polo');
    });

    test('reloadProducts reloads with current filters', () async {
      final service = FakeProductService()
        ..products = [
          Product(id: 1, handle: 'test', title: 'Test', price: null),
        ];
      final provider = ProductProvider(service);

      // Set initial filters
      await provider.loadProducts(query: 'test', category: 'kaos', sortKey: 'price');
      expect(provider.products.length, 1);

      // Reload
      await provider.reloadProducts();
      expect(provider.products.length, 1);
      expect(provider.currentQuery, 'test');
      expect(provider.currentCategory, 'kaos');
      expect(provider.currentSortKey, 'price');
    });

    test('searchProducts delegates to loadProducts', () async {
      final service = FakeProductService()
        ..products = [
          Product(id: 1, handle: 'search', title: 'Search Result', price: null),
        ];
      final provider = ProductProvider(service);

      await provider.searchProducts('query');

      expect(provider.currentQuery, 'query');
      expect(provider.products.length, 1);
    });

    test('loadBestSellers loads best sellers', () async {
      final service = FakeProductService()
        ..bestSellers = [
          Product(id: 1, handle: 'best-1', title: 'Best Seller 1', price: null),
        ];
      final provider = ProductProvider(service);

      await provider.loadBestSellers();

      expect(provider.bestSellers.length, 1);
      expect(provider.bestSellers.first.title, 'Best Seller 1');
    });

    test('loadNewArrivals loads new arrivals', () async {
      final service = FakeProductService()
        ..newArrivals = [
          Product(id: 1, handle: 'new-1', title: 'New Arrival 1', price: null),
        ];
      final provider = ProductProvider(service);

      await provider.loadNewArrivals();

      expect(provider.newArrivals.length, 1);
      expect(provider.newArrivals.first.title, 'New Arrival 1');
    });

    test('loadCategories loads categories', () async {
      final service = FakeProductService()
        ..categories = [
          {
            'id': 1,
            'name': 'Kaos',
            'slug': 'kaos',
            'image': 'https://example.com/kaos.jpg',
            'products_count': 15,
          },
        ];
      final provider = ProductProvider(service);

      await provider.loadCategories();

      expect(provider.categories.length, 1);
      expect(provider.categories.first['name'], 'Kaos');
      expect(provider.isLoading, isFalse);
    });

    test('loadCategories with Map image', () async {
      final service = FakeProductService()
        ..categories = [
          {
            'id': 1,
            'name': 'Kaos',
            'slug': 'kaos',
            'image': {'url': 'https://example.com/kaos.jpg'},
          },
        ];
      final provider = ProductProvider(service);

      await provider.loadCategories();

      expect(provider.categories.length, 1);
    });

    test('clearError clears error state', () {
      final service = FakeProductService();
      final provider = ProductProvider(service);

      expect(provider.error, isNull);
      provider.clearError();
      expect(provider.error, isNull);
    });

    test('initial state is correct', () {
      final service = FakeProductService();
      final provider = ProductProvider(service);

      expect(provider.products, isEmpty);
      expect(provider.bestSellers, isEmpty);
      expect(provider.newArrivals, isEmpty);
      expect(provider.heroSlides, isEmpty);
      expect(provider.categories, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.currentQuery, isNull);
      expect(provider.currentCategory, isNull);
    });
  });
}
