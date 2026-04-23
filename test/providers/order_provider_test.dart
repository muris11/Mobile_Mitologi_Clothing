import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/order.dart';
import 'package:mitologi_clothing_mobile/providers/order_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/order_service.dart';

class FakeOrderService extends OrderService {
  FakeOrderService() : super(ApiService());

  List<Order> orders = [];
  Order? orderDetail;
  PaymentInfo? paymentInfo;
  bool confirmPaymentCalled = false;
  bool requestRefundCalled = false;
  bool shouldThrow = false;

  @override
  Future<List<Order>> getOrders() async {
    if (shouldThrow) throw Exception('Get orders failed');
    return orders;
  }

  @override
  Future<Order> getOrderDetail(String orderNumber) async {
    if (shouldThrow) throw Exception('Get detail failed');
    return orderDetail ?? Order.fromJson({
      'id': 1,
      'order_number': orderNumber,
      'status': 'pending',
      'total': 170000,
      'items': [],
    });
  }

  @override
  Future<PaymentInfo> payOrder(String orderNumber) async {
    if (shouldThrow) throw Exception('Pay failed');
    return paymentInfo ?? PaymentInfo(
      paymentUrl: 'https://payment.example.com',
    );
  }

  @override
  Future<void> confirmPayment({
    required String orderNumber,
    required String paymentProofPath,
  }) async {
    if (shouldThrow) throw Exception('Confirm failed');
    confirmPaymentCalled = true;
  }

  @override
  Future<void> requestRefund({
    required String orderNumber,
    required String reason,
  }) async {
    if (shouldThrow) throw Exception('Refund failed');
    requestRefundCalled = true;
  }
}

void main() {
  group('OrderProvider', () {
    test('loadOrders loads orders successfully', () async {
      final service = FakeOrderService()
        ..orders = [
          Order.fromJson({
            'id': 1,
            'order_number': 'ORD-001',
            'status': 'pending',
            'total': 150000,
            'items': [],
          }),
        ];
      final provider = OrderProvider(service);

      await provider.loadOrders();

      expect(provider.orders.length, 1);
      expect(provider.orders.first.orderNumber, 'ORD-001');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('loadOrders handles error', () async {
      final service = FakeOrderService()..shouldThrow = true;
      final provider = OrderProvider(service);

      await provider.loadOrders();

      expect(provider.orders, isEmpty);
      expect(provider.error, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('loadOrderDetail loads order detail', () async {
      final service = FakeOrderService()
        ..orderDetail = Order.fromJson({
          'id': 1,
          'order_number': 'ORD-002',
          'status': 'paid',
          'total': 200000,
          'items': [],
        });
      final provider = OrderProvider(service);

      await provider.loadOrderDetail('ORD-002');

      expect(provider.selectedOrder, isNotNull);
      expect(provider.selectedOrder!.orderNumber, 'ORD-002');
      expect(provider.selectedOrder!.status, 'paid');
      expect(provider.isLoading, isFalse);
    });

    test('loadOrderDetail handles error', () async {
      final service = FakeOrderService()..shouldThrow = true;
      final provider = OrderProvider(service);

      await provider.loadOrderDetail('ORD-002');

      expect(provider.selectedOrder, isNull);
      expect(provider.error, isNotNull);
    });

    test('payOrder returns payment info', () async {
      final service = FakeOrderService()
        ..paymentInfo = PaymentInfo(
          paymentUrl: 'https://midtrans.example.com/pay',
        );
      final provider = OrderProvider(service);

      final result = await provider.payOrder('ORD-003');

      expect(result, isNotNull);
      expect(result!.paymentUrl, 'https://midtrans.example.com/pay');
      expect(provider.isLoading, isFalse);
    });

    test('payOrder handles error', () async {
      final service = FakeOrderService()..shouldThrow = true;
      final provider = OrderProvider(service);

      final result = await provider.payOrder('ORD-003');

      expect(result, isNull);
      expect(provider.error, isNotNull);
    });

    test('confirmPayment succeeds and reloads order', () async {
      final service = FakeOrderService()
        ..orderDetail = Order.fromJson({
          'id': 1,
          'order_number': 'ORD-004',
          'status': 'paid',
          'total': 150000,
          'items': [],
        });
      final provider = OrderProvider(service);

      final result = await provider.confirmPayment(
        orderNumber: 'ORD-004',
        paymentProofPath: '/path/to/proof.jpg',
      );

      expect(result, isTrue);
      expect(service.confirmPaymentCalled, isTrue);
      expect(provider.selectedOrder, isNotNull);
      expect(provider.selectedOrder!.orderNumber, 'ORD-004');
    });

    test('confirmPayment handles error', () async {
      final service = FakeOrderService()
        ..shouldThrow = true;
      final provider = OrderProvider(service);

      final result = await provider.confirmPayment(
        orderNumber: 'ORD-005',
        paymentProofPath: '/path/to/proof.jpg',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('requestRefund succeeds and reloads order', () async {
      final service = FakeOrderService()
        ..orderDetail = Order.fromJson({
          'id': 1,
          'order_number': 'ORD-006',
          'status': 'refund_requested',
          'total': 150000,
          'items': [],
        });
      final provider = OrderProvider(service);

      final result = await provider.requestRefund(
        orderNumber: 'ORD-006',
        reason: 'Barang rusak',
      );

      expect(result, isTrue);
      expect(service.requestRefundCalled, isTrue);
    });

    test('requestRefund handles error', () async {
      final service = FakeOrderService()..shouldThrow = true;
      final provider = OrderProvider(service);

      final result = await provider.requestRefund(
        orderNumber: 'ORD-006',
        reason: 'Barang rusak',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('clearSelectedOrder clears selected order', () async {
      final service = FakeOrderService()
        ..orderDetail = Order.fromJson({
          'id': 1,
          'order_number': 'ORD-007',
          'status': 'pending',
          'total': 100000,
          'items': [],
        });
      final provider = OrderProvider(service);

      await provider.loadOrderDetail('ORD-007');
      expect(provider.selectedOrder, isNotNull);

      provider.clearSelectedOrder();
      expect(provider.selectedOrder, isNull);
    });

    test('clearError clears error state', () async {
      final service = FakeOrderService()..shouldThrow = true;
      final provider = OrderProvider(service);

      await provider.loadOrders();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });

    test('initial state is correct', () {
      final service = FakeOrderService();
      final provider = OrderProvider(service);

      expect(provider.orders, isEmpty);
      expect(provider.selectedOrder, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });
  });
}
