import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/product_service.dart';

import '../helpers/test_binding.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_api_client.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
  });

  group('ProductService Tests', () {
    late MockApiClient mockClient;
    late ApiService apiService;
    late ProductService productService;

    setUp(() {
      mockClient = MockApiClient();
      apiService = ApiService(client: mockClient.client);
      productService = ProductService(apiService);
    });

    tearDown(() {
      mockClient.clear();
    });

    group('getLandingPage', () {
      test('returns landing page data successfully', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/landing-page',
          TestHelpers.sampleLandingPage,
        );

        // Act
        final result = await productService.getLandingPage();

        // Assert
        expect(result['hero_slides'], isA<List>());
        expect(result['categories'], isA<List>());
        expect(result['products'], isA<List>());
        expect((result['hero_slides'] as List).length, 2);
      });

      test('handles empty landing page', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/landing-page',
          {'hero_slides': [], 'categories': [], 'products': []},
        );

        // Act
        final result = await productService.getLandingPage();

        // Assert
        expect(result['hero_slides'], isEmpty);
        expect(result['categories'], isEmpty);
        expect(result['products'], isEmpty);
      });

      test('throws exception on server error', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/landing-page',
          {'message': 'Internal server error'},
          statusCode: 500,
        );

        // Act & Assert
        expect(
          () => productService.getLandingPage(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getProducts', () {
      test('returns list of products', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getProducts();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
        expect(result.first.handle, 'test-product');
        expect(result.first.title, 'Test Product');
      });

      test('sends backend-aligned query, category, sortKey, and reverse params',
          () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products?page=1&limit=20&q=kaos&category=fashion&sortKey=PRICE&reverse=false',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getProducts(
          query: 'kaos',
          category: 'fashion',
          sortKey: 'PRICE',
          reverse: false,
        );

        // Assert
        expect(result, hasLength(2));
      });

      test('filters by category', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getProducts(category: 'fashion');

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });

      test('searches by query', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getProducts(query: 'kaos');

        // Assert
        expect(result, isA<List>());
      });

      test('supports pagination', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getProducts(page: 2, limit: 10);

        // Assert
        expect(result, isA<List>());
      });

      test('handles price range filtering', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result =
            await productService.getProducts(minPrice: 50000, maxPrice: 150000);

        // Assert
        expect(result, isA<List>());
      });

      test('handles empty products list', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products',
          {'products': []},
        );

        // Act
        final result = await productService.getProducts();

        // Assert
        expect(result, isEmpty);
      });

      test('parses products from nested data payload', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products',
          {
            'data': {'products': TestHelpers.sampleProducts}
          },
        );

        // Act
        final result = await productService.getProducts();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.title, 'Test Product');
      });
    });

    group('getProductDetail', () {
      test('returns product details with variants', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/test-product',
          {'product': TestHelpers.sampleProduct},
        );

        // Act
        final result = await productService.getProductDetail('test-product');

        // Assert
        expect(result.handle, 'test-product');
        expect(result.title, 'Test Product');
        expect(result.variants, isNotEmpty);
        expect(result.options, isNotEmpty);
      });

      test('throws exception for non-existent product', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/non-existent',
          {'message': 'Product not found'},
          statusCode: 404,
        );

        // Act & Assert
        expect(
          () => productService.getProductDetail('non-existent'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getBestSellers', () {
      test('returns best selling products with limit', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/best-sellers',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getBestSellers(limit: 10);

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });

      test('handles empty best sellers', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/best-sellers',
          {'products': []},
        );

        // Act
        final result = await productService.getBestSellers();

        // Assert
        expect(result, isEmpty);
      });

      test('parses snake_case best_sellers from nested data', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/best-sellers',
          {
            'data': {'best_sellers': TestHelpers.sampleProducts}
          },
        );

        // Act
        final result = await productService.getBestSellers();

        // Assert
        expect(result, hasLength(2));
      });
    });

    group('getNewArrivals', () {
      test('returns new arrival products', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/new-arrivals',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getNewArrivals(limit: 8);

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });

      test('parses snake_case new_arrivals from nested data', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/new-arrivals',
          {
            'data': {'new_arrivals': TestHelpers.sampleProducts}
          },
        );

        // Act
        final result = await productService.getNewArrivals();

        // Assert
        expect(result, hasLength(2));
      });
    });

    group('getCategories', () {
      test('returns list of categories', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/categories',
          {
            'categories': [
              {'name': 'Fashion', 'handle': 'fashion'},
              {'name': 'Accessories', 'handle': 'accessories'},
            ]
          },
        );

        // Act
        final result = await productService.getCategories();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
        expect(result.first['name'], 'Fashion');
      });

      test('handles empty categories', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/categories',
          {'categories': []},
        );

        // Act
        final result = await productService.getCategories();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getCategoryDetail', () {
      test('returns category details with products', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/categories/fashion',
          {
            'category': {'name': 'Fashion', 'handle': 'fashion'},
            'products': TestHelpers.sampleProducts,
          },
        );

        // Act
        final result = await productService.getCategoryDetail('fashion');

        // Assert
        expect(result['category'], isA<Map>());
        expect(result['products'], isA<List>());
      });
    });

    group('getCollections', () {
      test('returns list of collections', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/collections',
          {
            'collections': [
              {'title': 'Summer', 'handle': 'summer'},
              {'title': 'Winter', 'handle': 'winter'},
            ]
          },
        );

        // Act
        final result = await productService.getCollections();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });
    });

    group('getCollectionDetail', () {
      test('returns collection details', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/collections/summer-collection',
          {
            'collection': {
              'title': 'Summer Collection',
              'handle': 'summer-collection'
            },
            'products': TestHelpers.sampleProducts,
          },
        );

        // Act
        final result =
            await productService.getCollectionDetail('summer-collection');

        // Assert
        expect(result['collection'], isA<Map>());
        expect(result['products'], isA<List>());
      });
    });

    group('getCollectionProducts', () {
      test('returns products in collection', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/collections/summer/products',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result = await productService.getCollectionProducts('summer');

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });
    });

    group('getProductReviews', () {
      test('returns product reviews with metadata', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/test-product/reviews',
          TestHelpers.sampleReviewsResponse,
        );

        // Act
        final result = await productService.getProductReviews('test-product');

        // Assert
        expect(result['reviews'], isA<List>());
        expect(result['average_rating'], 4.5);
        expect(result['total_reviews'], 24);
      });
    });

    group('getProductRecommendations', () {
      test('returns AI recommendations', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/products/1/recommendations',
          {'products': TestHelpers.sampleProducts},
        );

        // Act
        final result =
            await productService.getProductRecommendations(1, limit: 5);

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });
    });

    group('getOrderSteps', () {
      test('returns order process steps', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/order-steps',
          {
            'steps': [
              {'step': 1, 'title': 'Pilih Produk'},
              {'step': 2, 'title': 'Checkout'},
            ]
          },
        );

        // Act
        final result = await productService.getOrderSteps();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });

      test('supports type and grouped filters', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/order-steps',
          {'steps': []},
        );

        // Act
        final result =
            await productService.getOrderSteps(type: 'whatsapp', grouped: true);

        // Assert
        expect(result, isA<List>());
      });
    });

    group('getMaterials', () {
      test('returns materials list', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/materials',
          {
            'materials': [
              {'name': 'Cotton', 'handle': 'cotton'},
              {'name': 'Polyester', 'handle': 'polyester'},
            ]
          },
        );

        // Act
        final result = await productService.getMaterials();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });
    });

    group('getPage', () {
      test('returns CMS page content', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/pages/about-us',
          TestHelpers.samplePage,
        );

        // Act
        final result = await productService.getPage('about-us');

        // Assert
        expect(result['title'], 'About Us');
        expect(result['handle'], 'about-us');
        expect(result['content'], isNotNull);
      });

      test('parses CMS page from nested data.page payload', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/pages/about-us',
          {
            'data': {
              'page': TestHelpers.samplePage,
            }
          },
        );

        // Act
        final result = await productService.getPage('about-us');

        // Assert
        expect(result['title'], 'About Us');
        expect(result['handle'], 'about-us');
      });

      test('parses CMS page from nested data.content payload', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/pages/about-us',
          {
            'data': {
              'content': TestHelpers.samplePage,
            }
          },
        );

        // Act
        final result = await productService.getPage('about-us');

        // Assert
        expect(result['title'], 'About Us');
        expect(result['handle'], 'about-us');
      });
    });

    group('getPortfolios', () {
      test('returns portfolio items', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/portfolios',
          {
            'portfolios': [
              {'title': 'Project 1', 'slug': 'project-1'},
              {'title': 'Project 2', 'slug': 'project-2'},
            ]
          },
        );

        // Act
        final result = await productService.getPortfolios();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
      });
    });

    group('getPortfolioDetail', () {
      test('returns portfolio details', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/portfolios/project-1',
          {
            'portfolio': {'title': 'Project 1', 'slug': 'project-1'},
          },
        );

        // Act
        final result = await productService.getPortfolioDetail('project-1');

        // Assert
        expect(result['portfolio'], isA<Map>());
      });
    });

    group('getMenu', () {
      test('returns navigation menu', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/menus/main-menu',
          TestHelpers.sampleMenu,
        );

        // Act
        final result = await productService.getMenu('main-menu');

        // Assert
        expect(result['title'], 'Main Menu');
        expect(result['items'], isA<List>());
        expect((result['items'] as List).length, 3);
      });
    });
  });
}
