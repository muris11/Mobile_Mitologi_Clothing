class CheckoutPayload {
  final String cartId;
  final int addressId;
  final double shippingCost;
  final String paymentMethod;
  final String? notes;

  const CheckoutPayload({
    required this.cartId,
    required this.addressId,
    required this.shippingCost,
    required this.paymentMethod,
    this.notes,
  });
}
