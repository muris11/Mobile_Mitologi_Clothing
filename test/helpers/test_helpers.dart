import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Test helper for creating mock HTTP responses and sample data
class TestHelpers {
  /// Create a mock HTTP client that returns predefined responses
  static http.Client createMockClient({
    Map<String, dynamic>? responseData,
    int statusCode = 200,
    String? errorMessage,
  }) {
    return MockClient((request) async {
      if (errorMessage != null) {
        return http.Response(
          jsonEncode({'message': errorMessage}),
          statusCode >= 400 ? statusCode : 500,
        );
      }

      return http.Response(
        jsonEncode(responseData ?? {}),
        statusCode,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  // ==================== PRODUCT DATA ====================

  /// Sample product data for testing
  static Map<String, dynamic> get sampleProduct => {
        'id': 1,
        'handle': 'test-product',
        'title': 'Test Product',
        'description': 'Test description for the product',
        'price': {'amount': 100000, 'currencyCode': 'IDR'},
        'compareAtPrice': {'amount': 120000, 'currencyCode': 'IDR'},
        'featured_image': {'url': 'https://example.com/image.jpg'},
        'images': [
          {'url': 'https://example.com/image1.jpg'},
          {'url': 'https://example.com/image2.jpg'},
        ],
        'available_for_sale': true,
        'variants': [
          {
            'id': 'variant_1',
            'title': 'Size M',
            'price': {'amount': 100000, 'currencyCode': 'IDR'},
            'available_for_sale': true,
          }
        ],
        'options': [
          {
            'name': 'Size',
            'values': ['S', 'M', 'L'],
          }
        ],
        'tags': ['fashion', 'new'],
        'vendor': 'Test Vendor',
        'seo': {
          'title': 'SEO Title',
          'description': 'SEO Description',
        },
      };

  /// Sample products list for testing
  static List<Map<String, dynamic>> get sampleProducts => [
        sampleProduct,
        {
          'id': 2,
          'handle': 'second-product',
          'title': 'Second Product',
          'description': 'Another test product',
          'price': {'amount': 200000, 'currencyCode': 'IDR'},
          'featured_image': {'url': 'https://example.com/image2.jpg'},
          'available_for_sale': true,
        },
      ];

  /// Sample category data
  static Map<String, dynamic> get sampleCategory => {
        'name': 'Fashion',
        'handle': 'fashion',
        'description': 'Fashion category',
        'image': {'url': 'https://example.com/category.jpg'},
      };

  /// Sample collection data
  static Map<String, dynamic> get sampleCollection => {
        'title': 'Summer Collection',
        'handle': 'summer-collection',
        'description': 'Summer items',
        'image': {'url': 'https://example.com/collection.jpg'},
      };

  // ==================== CART DATA ====================

  /// Sample cart data for testing
  static Map<String, dynamic> get sampleCart => {
        'id': 'cart_123',
        'items': [
          {
            'id': 'item_1',
            'merchandiseId': 'variant_1',
            'title': 'Test Product',
            'quantity': 2,
            'price': 100000,
            'image': {'url': 'https://example.com/image.jpg'},
          }
        ],
        'cost': {'amount': 200000, 'currencyCode': 'IDR'},
        'subtotal': {'amount': 200000, 'currencyCode': 'IDR'},
        'total_tax': {'amount': 0, 'currencyCode': 'IDR'},
        'checkout_url': 'https://example.com/checkout',
      };

  /// Sample cart item for testing
  static Map<String, dynamic> get sampleCartItem => {
        'id': 'item_new',
        'merchandiseId': 'variant_2',
        'title': 'New Product',
        'quantity': 1,
        'price': 150000,
      };

  // ==================== USER & AUTH DATA ====================

  /// Sample user data for testing
  static Map<String, dynamic> get sampleUser => {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '08123456789',
        'avatar': 'https://example.com/avatar.jpg',
        'role': 'customer',
        'email_verified_at': '2024-01-01T00:00:00Z',
      };

  /// Sample auth response
  static Map<String, dynamic> get sampleAuthResponse => {
        'user': sampleUser,
        'token': 'test_auth_token_12345',
        'message': 'Login successful',
      };

  // ==================== ORDER DATA ====================

  /// Sample order data for testing
  static Map<String, dynamic> get sampleOrder => {
        'order_number': 'ORD-2024-001',
        'status': 'pending',
        'items': [
          {
            'id': 1,
            'title': 'Test Product',
            'quantity': 2,
            'price': {'amount': 100000, 'currencyCode': 'IDR'},
            'image': {'url': 'https://example.com/image.jpg'},
          }
        ],
        'total': {'amount': 200000, 'currencyCode': 'IDR'},
        'subtotal': {'amount': 200000, 'currencyCode': 'IDR'},
        'shipping_cost': 15000,
        'tax': {'amount': 0, 'currencyCode': 'IDR'},
        'created_at': '2024-01-01T00:00:00Z',
        'shipping_address': sampleAddress,
        'payment_method': 'bank_transfer',
        'payment_status': 'pending',
      };

  /// Sample checkout result
  static Map<String, dynamic> get sampleCheckoutResult => {
        'order': sampleOrder,
        'payment_url': 'https://payment.example.com/pay/123',
        'snap_token': 'snap_token_12345',
      };

  /// Sample payment info
  static Map<String, dynamic> get samplePaymentInfo => {
        'snapToken': 'snap_token_67890',
        'redirectUrl': 'https://payment.example.com/redirect',
        'payment_url': 'https://payment.example.com/pay/456',
      };

  // ==================== ADDRESS DATA ====================

  /// Sample address data
  static Map<String, dynamic> get sampleAddress => {
        'id': 1,
        'label': 'Home',
        'recipient_name': 'Test User',
        'phone': '08123456789',
        'address_line_1': 'Jl. Test No. 123',
        'city': 'Jakarta',
        'province': 'DKI Jakarta',
        'postal_code': '12345',
        'is_primary': true,
      };

  /// Sample address list
  static List<Map<String, dynamic>> get sampleAddresses => [
        sampleAddress,
        {
          'id': 2,
          'label': 'Office',
          'recipient_name': 'Test User',
          'phone': '08123456788',
          'address_line_1': 'Jl. Office No. 456',
          'city': 'Jakarta',
          'province': 'DKI Jakarta',
          'postal_code': '12346',
          'is_primary': false,
        },
      ];

  // ==================== CMS DATA ====================

  /// Sample landing page data
  static Map<String, dynamic> get sampleLandingPage => {
        'hero_slides': [
          {
            'title': 'Slide 1',
            'subtitle': 'Subtitle 1',
            'image_url': 'https://example.com/slide1.jpg',
            'button_text': 'Shop Now',
            'button_link': '/products',
          },
          {
            'title': 'Slide 2',
            'subtitle': 'Subtitle 2',
            'image_url': 'https://example.com/slide2.jpg',
          }
        ],
        'categories': [
          sampleCategory,
          {
            'name': 'Accessories',
            'handle': 'accessories',
          }
        ],
        'products': sampleProducts,
        'testimonials': [
          {
            'name': 'Customer 1',
            'text': 'Great product!',
            'rating': 5,
          }
        ],
      };

  /// Sample page content
  static Map<String, dynamic> get samplePage => {
        'title': 'About Us',
        'handle': 'about-us',
        'content': '<p>This is about us page</p>',
        'meta_title': 'About Us - Mitologi Clothing',
        'meta_description': 'Learn about our story',
      };

  /// Sample menu
  static Map<String, dynamic> get sampleMenu => {
        'title': 'Main Menu',
        'handle': 'main-menu',
        'items': [
          {'title': 'Home', 'url': '/'},
          {'title': 'Products', 'url': '/products'},
          {'title': 'About', 'url': '/about'},
        ],
      };

  /// Sample order steps
  static Map<String, dynamic> get sampleOrderSteps => {
        'steps': [
          {
            'step': 1,
            'title': 'Pilih Produk',
            'description': 'Pilih produk yang Anda inginkan',
          },
          {
            'step': 2,
            'title': 'Checkout',
            'description': 'Masukkan alamat pengiriman',
          },
          {
            'step': 3,
            'title': 'Pembayaran',
            'description': 'Lakukan pembayaran',
          },
        ],
      };

  /// Sample review data
  static Map<String, dynamic> get sampleReview => {
        'id': 1,
        'rating': 5,
        'title': 'Great product!',
        'content': 'Really love this product',
        'author': 'Customer Name',
        'created_at': '2024-01-01T00:00:00Z',
      };

  /// Sample reviews list response
  static Map<String, dynamic> get sampleReviewsResponse => {
        'reviews': [sampleReview],
        'average_rating': 4.5,
        'total_reviews': 24,
      };

  // ==================== UTILITY METHODS ====================

  /// Create mock response wrapper
  static Map<String, dynamic> wrapResponse(dynamic data,
      {bool success = true}) {
    return {
      'success': success,
      'data': data,
    };
  }

  /// Create error response
  static Map<String, dynamic> errorResponse(String message, {int code = 400}) {
    return {
      'success': false,
      'message': message,
      'code': code,
    };
  }
}
