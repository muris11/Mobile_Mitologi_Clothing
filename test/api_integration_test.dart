import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/config/api_config.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';

/// Test to verify API integration is working
void main() {
  group('API Integration Verification', () {
    test('API base URL is correct', () {
      expect(ApiConfig.baseUrl, 'https://adminmitologiclothing.center.biz.id/api/v1');
    });

    test('All required endpoints are defined', () {
      // Public endpoints
      expect(ApiEndpoints.landingPage, '/landing-page');
      expect(ApiEndpoints.siteSettings, '/site-settings');
      expect(ApiEndpoints.products, '/products');
      expect(ApiEndpoints.productsBestSellers, '/products/best-sellers');
      expect(ApiEndpoints.productsNewArrivals, '/products/new-arrivals');
      expect(ApiEndpoints.categories, '/categories');
      expect(ApiEndpoints.materials, '/materials');
      expect(ApiEndpoints.collections, '/collections');
      expect(ApiEndpoints.pages, '/pages');
      expect(ApiEndpoints.portfolios, '/portfolios');
      expect(ApiEndpoints.menus, '/menus');
      expect(ApiEndpoints.orderSteps, '/order-steps');

      // Auth endpoints
      expect(ApiEndpoints.authLogin, '/auth/login');
      expect(ApiEndpoints.authRegister, '/auth/register');
      expect(ApiEndpoints.authLogout, '/auth/logout');
      expect(ApiEndpoints.authUser, '/auth/user');
      expect(ApiEndpoints.authForgotPassword, '/auth/forgot-password');
      expect(ApiEndpoints.authResetPassword, '/auth/reset-password');

      // Cart endpoints
      expect(ApiEndpoints.cart, '/cart');
      expect(ApiEndpoints.cartItems, '/cart/items');
      expect(ApiEndpoints.cartClear, '/cart/clear');

      // Order endpoints
      expect(ApiEndpoints.orders, '/orders');
      expect(ApiEndpoints.checkout, '/checkout');
      expect(ApiEndpoints.checkoutNotification, '/checkout/notification');

      // Profile endpoints
      expect(ApiEndpoints.profile, '/profile');
      expect(ApiEndpoints.profilePassword, '/profile/password');
      expect(ApiEndpoints.profileAvatar, '/profile/avatar');
      expect(ApiEndpoints.addresses, '/profile/addresses');

      // Wishlist endpoints
      expect(ApiEndpoints.wishlist, '/wishlist');

      // Chatbot & Recommendations
      expect(ApiEndpoints.chatbot, '/chatbot');
      expect(ApiEndpoints.recommendations, '/recommendations');
      expect(ApiEndpoints.interactionsBatch, '/interactions/batch');
    });

    test('ApiService can be instantiated', () {
      final apiService = ApiService();
      expect(apiService, isNotNull);
    });

    test('ApiHeaders are correct', () {
      expect(ApiHeaders.cartId, 'X-Cart-Id');
      expect(ApiHeaders.sessionId, 'X-Session-Id');
      expect(ApiHeaders.authorization, 'Authorization');
      expect(ApiHeaders.bearerToken('test'), 'Bearer test');
    });

    test('Dynamic endpoint builders generate expected paths', () {
      expect(ApiEndpoints.productDetail('hoodie-abc'), '/products/hoodie-abc');
      expect(ApiEndpoints.categoryDetail('jaket'), '/categories/jaket');
      expect(ApiEndpoints.collectionProducts('new-arrival'),
          '/collections/new-arrival/products');
      expect(ApiEndpoints.pageDetail('about'), '/pages/about');
      expect(ApiEndpoints.menuDetail('main-menu'), '/menus/main-menu');
      expect(ApiEndpoints.orderDetail('INV-001'), '/orders/INV-001');
      expect(ApiEndpoints.wishlistCheck(12), '/wishlist/check/12');
    });

    test('ApiConfig.buildUri merges endpoint and query params', () {
      final uri = ApiConfig.buildUri(
        '/products?featured=true',
        queryParams: {'limit': '10', 'sort': 'latest'},
      );

      expect(uri.toString(),
          'https://adminmitologiclothing.center.biz.id/api/v1/products?featured=true&limit=10&sort=latest');
    });

    test('ApiConfig.buildImageUrl handles absolute and relative paths', () {
      expect(
        ApiConfig.buildImageUrl('https://cdn.example.com/a.jpg'),
        'https://cdn.example.com/a.jpg',
      );

      expect(
        ApiConfig.buildImageUrl('products/image.jpg'),
        'https://adminmitologiclothing.center.biz.id/storage/products/image.jpg',
      );

      expect(
        ApiConfig.buildImageUrl('/products/image.jpg'),
        'https://adminmitologiclothing.center.biz.id/storage/products/image.jpg',
      );
    });
  });
}
