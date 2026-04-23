import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/order_service.dart';

import '../helpers/test_binding.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_api_client.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
  });

  group('OrderService Tests', () {
    late MockApiClient mockClient;
    late ApiService apiService;
    late OrderService orderService;

    setUp(() {
      // Reset storage to authenticated state
      resetMockStorageToDefaultAuthenticatedState();
      mockClient = MockApiClient();
      apiService = ApiService(client: mockClient.client);
      orderService = OrderService(apiService);
    });

    tearDown(() {
      mockClient.clear();
    });

    group('checkout', () {
      test('creates order successfully', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/checkout',
          TestHelpers.sampleCheckoutResult,
        );

        // Act
        final result = await orderService.checkout(
          cartId: 'cart_123',
          addressId: 1,
          shippingCost: 15000,
          paymentMethod: 'bank_transfer',
          notes: 'Please handle with care',
        );

        // Assert
        expect(result.orderNumber, 'ORD-2024-001');
        expect(result.snapToken, isNotNull);
        expect(result.useMidtrans, true);
      });

      test('throws exception when user not authenticated', () async {
        // Arrange - simulating no auth token
        resetMockStorageToEmptyState();

        // Act & Assert
        expect(
          () => orderService.checkout(
            cartId: 'cart_123',
            addressId: 1,
            shippingCost: 15000,
            paymentMethod: 'bank_transfer',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception on invalid cart', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/checkout',
          {'message': 'Cart is empty'},
          statusCode: 400,
        );

        // Act & Assert
        expect(
          () => orderService.checkout(
            cartId: 'empty_cart',
            addressId: 1,
            shippingCost: 15000,
            paymentMethod: 'bank_transfer',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('sends snake_case checkout payload with required fields', () async {
        // Arrange
        late http.Request capturedRequest;
        final recordingClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode(TestHelpers.sampleCheckoutResult),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final recordingService =
            OrderService(ApiService(client: recordingClient));

        // Act
        await recordingService.checkout(
          cartId: 'cart_abc',
          addressId: 42,
          shippingCost: 15000,
          paymentMethod: 'bank_transfer',
          shippingName: 'Rifqy',
          shippingPhone: '08123456789',
          shippingAddress: 'Jl. Merdeka 1',
          shippingCity: 'Bandung',
          shippingProvince: 'Jawa Barat',
          shippingPostalCode: '40123',
        );

        // Assert
        final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
        expect(body['cart_id'], 'cart_abc');
        expect(body['address_id'], 42);
        expect(body['shipping_cost'], 15000);
        expect(body['payment_method'], 'bank_transfer');
        expect(body['shipping_name'], 'Rifqy');
        expect(body['shipping_postal_code'], '40123');
      });
    });

    group('getOrders', () {
      test('returns user orders list', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders',
          {
            'orders': [
              TestHelpers.sampleOrder,
              {
                ...TestHelpers.sampleOrder,
                'order_number': 'ORD-2024-002',
                'status': 'completed',
              },
            ]
          },
        );

        // Act
        final result = await orderService.getOrders();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
        expect(result.first.orderNumber, 'ORD-2024-001');
        expect(result[1].status, 'completed');
      });

      test('returns empty list when no orders', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders',
          {'orders': []},
        );

        // Act
        final result = await orderService.getOrders();

        // Assert
        expect(result, isEmpty);
      });

      test('throws exception when not authenticated', () async {
        // Arrange
        resetMockStorageToEmptyState();

        // Act & Assert
        expect(
          () => orderService.getOrders(),
          throwsA(isA<Exception>()),
        );
      });

      test('parses orders from nested data payload', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders',
          {
            'data': {
              'orders': [TestHelpers.sampleOrder]
            }
          },
        );

        // Act
        final result = await orderService.getOrders();

        // Assert
        expect(result.length, 1);
        expect(result.first.orderNumber, 'ORD-2024-001');
      });
    });

    group('getOrderDetail', () {
      test('returns order details', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/ORD-2024-001',
          {'order': TestHelpers.sampleOrder},
        );

        // Act
        final result = await orderService.getOrderDetail('ORD-2024-001');

        // Assert
        expect(result.orderNumber, 'ORD-2024-001');
        expect(result.status, 'pending');
        expect(result.items, isNotEmpty);
        expect(result.total, isNotNull);
      });

      test('throws exception for non-existent order', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/NONEXISTENT',
          {'message': 'Order not found'},
          statusCode: 404,
        );

        // Act & Assert
        expect(
          () => orderService.getOrderDetail('NONEXISTENT'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('payOrder', () {
      test('returns payment info with snap token', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/ORD-2024-001/pay',
          TestHelpers.samplePaymentInfo,
        );

        // Act
        final result = await orderService.payOrder('ORD-2024-001');

        // Assert
        expect(result.snapToken, 'snap_token_67890');
        expect(result.redirectUrl, 'https://payment.example.com/redirect');
      });

      test('throws exception for paid order', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/ORD-2024-001/pay',
          {'message': 'Order already paid'},
          statusCode: 400,
        );

        // Act & Assert
        expect(
          () => orderService.payOrder('ORD-2024-001'),
          throwsA(isA<ApiException>()),
        );
      });

      test('parses snake_case payment fields', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/ORD-2024-001/pay',
          {
            'data': {
              'snap_token': 'snap_token_snake',
              'redirect_url': 'https://payment.example.com/snake',
            }
          },
        );

        // Act
        final result = await orderService.payOrder('ORD-2024-001');

        // Assert
        expect(result.snapToken, 'snap_token_snake');
        expect(result.redirectUrl, 'https://payment.example.com/snake');
      });
    });

    group('confirmPayment', () {
      test('uploads payment proof successfully', () async {
        // Skip: Multipart uploads bypass the injected mock client in ApiService.
      },
          skip:
              'Multipart uploads bypass the injected mock client in ApiService.');

      test('throws exception on upload failure', () async {
        // Skip: Multipart uploads bypass the injected mock client in ApiService.
      },
          skip:
              'Multipart uploads bypass the injected mock client in ApiService.');
    });

    group('requestRefund', () {
      test('requests refund successfully', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/ORD-2024-001/request-refund',
          {'message': 'Refund requested'},
        );

        // Act & Assert - should not throw
        await expectLater(
          orderService.requestRefund(
            orderNumber: 'ORD-2024-001',
            reason: 'Product damaged',
          ),
          completes,
        );
      });

      test('throws exception for ineligible order', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/ORD-2024-001/request-refund',
          {'message': 'Order not eligible for refund'},
          statusCode: 400,
        );

        // Act & Assert
        expect(
          () => orderService.requestRefund(
            orderNumber: 'ORD-2024-001',
            reason: 'Changed mind',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('trackOrder', () {
      test('returns order status', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/orders/ORD-2024-001',
          {
            'order': {
              ...TestHelpers.sampleOrder,
              'status': 'shipped',
            }
          },
        );

        // Act
        final result = await orderService.trackOrder('ORD-2024-001');

        // Assert
        expect(result, 'shipped');
      });
    });

    group('OrderStatus', () {
      test('has correct display names', () {
        expect(OrderStatus.pending.displayName, 'Menunggu Pembayaran');
        expect(OrderStatus.processing.displayName, 'Diproses');
        expect(OrderStatus.paid.displayName, 'Dibayar');
        expect(OrderStatus.shipped.displayName, 'Dikirim');
        expect(OrderStatus.delivered.displayName, 'Sampai Tujuan');
        expect(OrderStatus.completed.displayName, 'Selesai');
        expect(OrderStatus.cancelled.displayName, 'Dibatalkan');
        expect(OrderStatus.refunded.displayName, 'Dikembalikan');
      });

      test('has color codes', () {
        expect(OrderStatus.pending.color, isNotEmpty);
        expect(OrderStatus.completed.color, isNotEmpty);
        expect(OrderStatus.cancelled.color, isNotEmpty);
      });
    });
  });
}
