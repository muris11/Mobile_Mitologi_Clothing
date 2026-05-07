import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_repository.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_service.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/views/order_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('OrderDetailScreen renders order detail without exceptions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ProfileRepository>(
          create: (_) => _FakeProfileRepository(),
          child: const OrderDetailScreen(orderNumber: 'INV-001'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Order #INV-001'), findsOneWidget);
    expect(find.text('Ringkasan Pembayaran'), findsOneWidget);
    expect(find.textContaining('Kala Makara Snapback Cap'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderDetailScreen shows friendly error state on failure',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ProfileRepository>(
          create: (_) => _ThrowingOrderDetailRepository(),
          child: const OrderDetailScreen(orderNumber: 'INV-001'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Gagal memuat detail pesanan. Silakan coba lagi.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository()
      : super(
          ProfileService(ApiClient(TokenStorage(), CartStorage())),
        );

  @override
  Future<OrderModel> getOrderDetail(String orderNumber) async => _order;
}

class _ThrowingOrderDetailRepository extends ProfileRepository {
  _ThrowingOrderDetailRepository()
      : super(
          ProfileService(ApiClient(TokenStorage(), CartStorage())),
        );

  @override
  Future<OrderModel> getOrderDetail(String orderNumber) async {
    throw Exception('Gagal memuat detail pesanan. Silakan coba lagi.');
  }
}

final _order = OrderModel(
  id: 1,
  orderNumber: 'INV-001',
  status: 'pending',
  totalAmount: 154000,
  subtotal: 129000,
  shippingCost: 25000,
  paymentUrl: 'https://example.com/pay',
  items: const [
    OrderItemModel(
      id: 1,
      productTitle: 'Kala Makara Snapback Cap',
      productImage: 'https://example.com/image.jpg',
      quantity: 1,
      price: 129000,
      total: 129000,
    ),
  ],
  shippingAddress: const AddressModel(
    id: 1,
    label: 'Rumah',
    recipientName: 'Rifqy',
    phone: '081234567890',
    address: 'Jl. Mitologi No. 1',
    city: 'Cirebon',
    province: 'Jawa Barat',
    postalCode: '45111',
    isDefault: true,
  ),
  createdAt: DateTime(2026, 5, 5),
);
