import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/models/order.dart';
import 'package:mitologi_clothing_mobile/providers/order_provider.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/order_service.dart';

class FakeOrderService extends OrderService {
  FakeOrderService() : super(ApiService());

  List<Order> orders = [];
  Order? detail;

  @override
  Future<Order> getOrderDetail(String orderNumber) async => detail!;

  @override
  Future<List<Order>> getOrders() async => orders;
}

void main() {
  group('OrderProvider', () {
    test('loads orders list', () async {
      final service = FakeOrderService()
        ..orders = [
          Order.fromJson({
            'id': 1,
            'order_number': 'ORD-001',
            'status': 'pending',
            'total': 170000,
            'items': [],
          })
        ];
      final provider = OrderProvider(service);

      await provider.loadOrders();

      expect(provider.orders.length, 1);
      expect(provider.error, isNull);
    });

    test('loads order detail', () async {
      final service = FakeOrderService()
        ..detail = Order.fromJson({
          'id': 1,
          'order_number': 'ORD-001',
          'status': 'pending',
          'total': 170000,
          'items': [],
        });
      final provider = OrderProvider(service);

      await provider.loadOrderDetail('ORD-001');

      expect(provider.selectedOrder?.orderNumber, 'ORD-001');
      expect(provider.error, isNull);
    });
  });
}
