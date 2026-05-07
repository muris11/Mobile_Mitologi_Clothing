import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_client.dart';
import 'package:mitologi_clothing_mobile/core/storage/cart_storage.dart';
import 'package:mitologi_clothing_mobile/core/storage/token_storage.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_service.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/addresses_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AddressesScreen renders address list without exceptions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<CheckoutRepository>(
          create: (_) => _FakeCheckoutRepository(),
          child: const AddressesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Rumah'), findsOneWidget);
    expect(find.textContaining('Rifqy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AddressesScreen shows friendly error state on failure',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<CheckoutRepository>(
          create: (_) => _ThrowingCheckoutRepository(),
          child: const AddressesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Gagal memuat alamat pengiriman. Silakan coba lagi.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeCheckoutRepository extends CheckoutRepository {
  _FakeCheckoutRepository()
      : super(
          CheckoutService(ApiClient(TokenStorage(), CartStorage())),
        );

  @override
  Future<List<AddressModel>> getAddresses() async => _addresses;
}

class _ThrowingCheckoutRepository extends CheckoutRepository {
  _ThrowingCheckoutRepository()
      : super(
          CheckoutService(ApiClient(TokenStorage(), CartStorage())),
        );

  @override
  Future<List<AddressModel>> getAddresses() async {
    throw Exception('Gagal memuat alamat pengiriman. Silakan coba lagi.');
  }
}

const _addresses = [
  AddressModel(
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
];
