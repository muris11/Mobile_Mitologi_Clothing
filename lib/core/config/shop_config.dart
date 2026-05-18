class ShopConfig {
  ShopConfig._();

  static const double flatShippingCost = 50000;
  static const String defaultPaymentMethod = 'midtrans';

  static const String midtransSnapBaseUrl =
      'https://app.sandbox.midtrans.com/snap/v2/vtweb';

  static String buildMidtransSnapUrl(String snapToken) =>
      '$midtransSnapBaseUrl/$snapToken';
}
