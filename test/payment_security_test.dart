import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/midtrans_payment_screen.dart';

void main() {
  testWidgets('MidtransPaymentScreen rejects non-Midtrans payment URLs',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MidtransPaymentScreen(
          paymentUrl: 'http://evil.example/payment',
          orderNumber: 'ORD-001',
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Gagal Memuat Halaman'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Android release manifest disallows cleartext traffic', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(manifest, isNot(contains('android:usesCleartextTraffic="true"')));
  });
}
