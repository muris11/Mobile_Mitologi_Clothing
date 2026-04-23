import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Enhanced Mock API Client for testing
///
/// Usage:
/// ```dart
/// final mockClient = MockApiClient();
/// mockClient.setResponse('GET', '/api/v1/products', {'products': []});
/// final apiService = ApiService(client: mockClient.client);
/// ```
class MockApiClient {
  late http.Client _client;
  final Map<String, dynamic> _responses = {};
  final Map<String, int> _statusCodes = {};

  MockApiClient() {
    _setupMockClient();
  }

  void _setupMockClient() {
    _client = MockClient((request) async {
      final url = request.url.toString();
      final method = request.method;
      final key = '$method:$url';

      // Debug logging disabled for cleaner test output
      // print('MOCK: Request $method $url');
      // print('MOCK: Looking for key: $key');
      // print('MOCK: Registered endpoints: ${_responses.keys}');

      // Check if we have a predefined response
      if (_responses.containsKey(key)) {
        final responseData = _responses[key]!;
        final statusCode = _statusCodes[key] ?? 200;
        // Debug logging disabled for cleaner test output
        // print('MOCK: Found response for $key');

        // If responseData has 'error' field, treat as error response
        if (responseData is Map<String, dynamic> &&
            (responseData.containsKey('error') || statusCode >= 400)) {
          return http.Response(
            jsonEncode(responseData),
            statusCode,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          jsonEncode(responseData),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      }

      // Check for pattern-based matching (without query params)
      final uri = Uri.parse(url);
      final baseUrl = '${uri.scheme}://${uri.host}${uri.path}';
      final patternKey = '$method:$baseUrl';

      if (_responses.containsKey(patternKey)) {
        final statusCode = _statusCodes[patternKey] ?? 200;
        // Debug logging disabled for cleaner test output
        // print('MOCK: Found pattern match for $patternKey');
        return http.Response(
          jsonEncode(_responses[patternKey]),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      }

      // Debug logging disabled for cleaner test output
      // print('MOCK: No match found, returning empty response');
      // Default success response
      return http.Response(
        jsonEncode({}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  /// Set response for a specific endpoint
  void setResponse(String method, String url, dynamic data,
      {int statusCode = 200}) {
    final key = '$method:$url';
    _responses[key] = data;
    _statusCodes[key] = statusCode;
  }

  /// Set error response for a specific endpoint
  void setError(String method, String url, String errorMessage,
      {int statusCode = 400}) {
    final key = '$method:$url';
    _responses[key] = {
      'message': errorMessage,
      'error': {'message': errorMessage},
    };
    _statusCodes[key] = statusCode;
  }

  /// Get the mock client
  http.Client get client => _client;

  /// Clear all responses
  void clear() {
    _responses.clear();
    _statusCodes.clear();
  }

  /// Setup common API responses for standard operations
  void setupCommonResponses({
    Map<String, dynamic>? landingPage,
    List<Map<String, dynamic>>? products,
    Map<String, dynamic>? authResponse,
    Map<String, dynamic>? cart,
    List<Map<String, dynamic>>? orders,
    Map<String, dynamic>? user,
  }) {
    // Landing page
    setResponse('GET', 'https://adminmitologiclothing.center.biz.id/api/v1/landing-page',
        landingPage ?? {'hero_slides': [], 'categories': [], 'products': []});

    // Products
    setResponse('GET', 'https://adminmitologiclothing.center.biz.id/api/v1/products',
        {'products': products ?? []});

    // Auth - Register
    setResponse(
        'POST',
        'https://adminmitologiclothing.center.biz.id/api/v1/auth/register',
        authResponse ??
            {
              'token': 'test_token',
              'user': {
                'id': 1,
                'name': 'Test User',
                'email': 'test@example.com'
              },
            });

    // Auth - Login
    setResponse(
        'POST',
        'https://adminmitologiclothing.center.biz.id/api/v1/auth/login',
        authResponse ??
            {
              'token': 'test_token',
              'user': {
                'id': 1,
                'name': 'Test User',
                'email': 'test@example.com'
              },
            });

    // Auth - User
    setResponse('GET', 'https://adminmitologiclothing.center.biz.id/api/v1/auth/user', {
      'user':
          user ?? {'id': 1, 'name': 'Test User', 'email': 'test@example.com'}
    });

    // Cart
    setResponse('GET', 'https://adminmitologiclothing.center.biz.id/api/v1/cart', {
      'cart': cart ?? {'id': 'test_cart', 'items': []}
    });

    // Orders
    setResponse('GET', 'https://adminmitologiclothing.center.biz.id/api/v1/orders',
        {'orders': orders ?? []});
  }

  /// Verify that a request was made to a specific endpoint
  bool hasResponseFor(String method, String url) {
    final key = '$method:$url';
    return _responses.containsKey(key);
  }

  /// Get all registered endpoint keys
  List<String> get registeredEndpoints => _responses.keys.toList();
}
