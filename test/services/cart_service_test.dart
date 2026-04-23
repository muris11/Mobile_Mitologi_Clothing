import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/cart_service.dart';

import '../helpers/test_binding.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_api_client.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
  });

  group('CartService Tests', () {
    late MockApiClient mockClient;
    late ApiService apiService;
    late CartService cartService;

    setUp(() {
      // Reset storage to authenticated state with cart session
      resetToAuthenticatedState();
      mockClient = MockApiClient();
      apiService = ApiService(client: mockClient.client);
      cartService = CartService(apiService);
    });

    tearDown(() {
      mockClient.clear();
    });

    group('createCart', () {
      test('creates new cart successfully', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/cart',
          {'cart_id': 'new_cart_123'},
        );

        // Act
        final result = await cartService.createCart();

        // Assert
        expect(result, isA<String>());
        expect(result, 'new_cart_123');
      });
    });

    group('getCart', () {
      test('returns cart with items', () async {
        // Arrange - setup mock
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/cart',
          {'cart': TestHelpers.sampleCart},
        );

        // Act
        final result = await cartService.getCart();
        // Debug logging disabled for cleaner test output
        // print('DEBUG: result = $result');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'cart_123');
        expect(result?.items, isNotEmpty);
        expect(result?.items.first.quantity, 2);
      });

      test('returns null when no cart session', () async {
        // Arrange - clear cart session
        resetToUnauthenticatedState();

        // Act
        final result = await cartService.getCart();

        // Assert
        expect(result, isNull);
      });
    });

    group('addItem', () {
      test('adds item to cart successfully', () async {
        // Arrange
        final updatedCart = {
          ...TestHelpers.sampleCart,
          'items': [
            ...TestHelpers.sampleCart['items'] as List,
            TestHelpers.sampleCartItem,
          ],
        };
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/cart/items',
          {'cart': updatedCart},
        );

        // Act
        final result = await cartService.addItem(
          merchandiseId: 'variant_2',
          quantity: 1,
        );

        // Assert
        expect(result.items.length, 2);
      });
    });

    group('updateItem', () {
      test('updates item quantity', () async {
        // Arrange
        final updatedCart = {
          ...TestHelpers.sampleCart,
          'items': [
            {
              ...TestHelpers.sampleCart['items'][0],
              'quantity': 5,
            }
          ],
        };
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/cart/items/item_1',
          {'cart': updatedCart},
        );

        // Act
        final result = await cartService.updateItem(
          'item_1',
          merchandiseId: 'variant_1',
          quantity: 5,
        );

        // Assert
        expect(result.items.first.quantity, 5);
      });

      test('sends PUT request to /cart/items/{id} with quantity payload',
          () async {
        // Arrange
        late http.Request capturedRequest;
        final recordingClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'cart': TestHelpers.sampleCart}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final recordingService =
            CartService(ApiService(client: recordingClient));

        // Act
        await recordingService.updateItem(
          'item_1',
          merchandiseId: 'variant_1',
          quantity: 3,
        );

        // Assert
        expect(capturedRequest.method, 'PUT');
        expect(
          capturedRequest.url.toString(),
          'https://adminmitologiclothing.center.biz.id/api/v1/cart/items/item_1',
        );
        expect(
          capturedRequest.headers['X-Cart-Id'],
          'test_cart_session_67890',
        );
        expect(
          capturedRequest.headers['X-Session-Id'],
          'test_cart_session_67890',
        );
        expect(
          jsonDecode(capturedRequest.body),
          {
            'merchandise_id': 'variant_1',
            'quantity': 3,
          },
        );
      });

      test('throws exception when cart session not found', () async {
        // Arrange - clear session to simulate no cart
        resetToUnauthenticatedState();

        // Act & Assert
        expect(
          () => cartService.updateItem(
            'item_1',
            merchandiseId: 'variant_1',
            quantity: 3,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('removeItem', () {
      test('removes item from cart', () async {
        // Arrange
        final emptyCart = {
          ...TestHelpers.sampleCart,
          'items': [],
        };
        mockClient.setResponse(
          'DELETE',
          'https://adminmitologiclothing.center.biz.id/api/v1/cart/items/item_1',
          {'cart': emptyCart},
        );

        // Act
        final result = await cartService.removeItem('item_1');

        // Assert
        expect(result.items, isEmpty);
      });

      test('sends DELETE request to /cart/items/{id}', () async {
        // Arrange
        late http.Request capturedRequest;
        final recordingClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'cart': TestHelpers.sampleCart}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final recordingService =
            CartService(ApiService(client: recordingClient));

        // Act
        await recordingService.removeItem('item_1');

        // Assert
        expect(capturedRequest.method, 'DELETE');
        expect(
          capturedRequest.url.toString(),
          'https://adminmitologiclothing.center.biz.id/api/v1/cart/items/item_1',
        );
        expect(
          capturedRequest.headers['X-Cart-Id'],
          'test_cart_session_67890',
        );
        expect(
          capturedRequest.headers['X-Session-Id'],
          'test_cart_session_67890',
        );
      });
    });

    group('clearCart', () {
      test('clears all items from cart', () async {
        // Arrange
        final emptyCart = {
          'id': 'cart_123',
          'items': [],
          'cost': {'amount': 0, 'currencyCode': 'IDR'},
          'subtotal': {'amount': 0, 'currencyCode': 'IDR'},
        };
        mockClient.setResponse(
          'DELETE',
          'https://adminmitologiclothing.center.biz.id/api/v1/cart/clear',
          {'cart': emptyCart},
        );

        // Act
        final result = await cartService.clearCart();

        // Assert
        expect(result.items, isEmpty);
        expect(result.total, 0.0);
      });

      test('sends DELETE request to /cart/clear', () async {
        // Arrange
        late http.Request capturedRequest;
        final recordingClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'cart': TestHelpers.sampleCart}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final recordingService =
            CartService(ApiService(client: recordingClient));

        // Act
        await recordingService.clearCart();

        // Assert
        expect(capturedRequest.method, 'DELETE');
        expect(
          capturedRequest.url.toString(),
          'https://adminmitologiclothing.center.biz.id/api/v1/cart/clear',
        );
        expect(
          capturedRequest.headers['X-Cart-Id'],
          'test_cart_session_67890',
        );
        expect(
          capturedRequest.headers['X-Session-Id'],
          'test_cart_session_67890',
        );
      });

      test('throws exception when cart not found', () async {
        // Arrange
        resetToUnauthenticatedState();

        // Act & Assert
        expect(
          () => cartService.clearCart(),
          throwsA(isA<Exception>()),
        );
      });

      test('parses cart from nested data payload', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/cart',
          {
            'data': {'cart': TestHelpers.sampleCart}
          },
        );

        // Act
        final result = await cartService.getCart();

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'cart_123');
      });
    });
  });
}
