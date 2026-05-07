import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/order_model.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_repository.dart';
import 'package:mitologi_clothing_mobile/features/profile/data/profile_service.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/views/orders_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('OrdersListScreen renders orders without exceptions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ProfileRepository>(
          create: (_) => _FakeProfileRepository(),
          child: const OrdersListScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pesanan Saya'), findsOneWidget);
    expect(find.textContaining('#INV-001'), findsOneWidget);
    expect(find.textContaining('Total Pembayaran'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersListScreen shows friendly error state on failure',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ProfileRepository>(
          create: (_) => _ThrowingProfileRepository(),
          child: const OrdersListScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Gagal memuat daftar pesanan. Silakan coba lagi.'),
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
  Future<List<OrderModel>> getOrders() async => _orders;
}

class _ThrowingProfileRepository extends ProfileRepository {
  _ThrowingProfileRepository()
      : super(
          ProfileService(ApiClient(TokenStorage(), CartStorage())),
        );

  @override
  Future<List<OrderModel>> getOrders() async {
    throw Exception('Gagal memuat daftar pesanan. Silakan coba lagi.');
  }
}

final _orders = [
  OrderModel(
    id: 1,
    orderNumber: 'INV-001',
    status: 'pending',
    totalAmount: 154000,
    subtotal: 129000,
    shippingCost: 25000,
    items: const [
      OrderItemModel(
        id: 1,
        productTitle: 'Kala Makara Snapback Cap',
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
  ),
];
