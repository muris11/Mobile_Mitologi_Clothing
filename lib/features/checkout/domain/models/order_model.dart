import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';
import 'package:mitologi_clothing_mobile/features/checkout/domain/models/address_model.dart';

class OrderItemModel extends Equatable {
  final int id;
  final String productTitle;
  final String? productHandle;
  final String? productImage;
  final String? variantTitle;
  final int quantity;
  final double price;
  final double total;

  const OrderItemModel({
    required this.id,
    required this.productTitle,
    this.productHandle,
    this.productImage,
    this.variantTitle,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: ParserUtils.parseInt(json['id']),
      productTitle:
          json['product_title'] as String? ?? json['name'] as String? ?? '',
      productHandle: json['product_handle'] as String?,
      productImage: json['product_image'] as String?,
      variantTitle: json['variant_title'] as String?,
      quantity: ParserUtils.parseInt(json['quantity']),
      price: ParserUtils.parseDouble(json['price']),
      total: ParserUtils.parseDouble(json['total'] ?? json['subtotal']),
    );
  }

  @override
  List<Object?> get props => [id, productTitle, quantity, price, total];
}

class OrderModel extends Equatable {
  final int id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final double subtotal;
  final double shippingCost;
  final String? paymentUrl;
  final String? trackingNumber;
  final DateTime? refundRequestedAt;
  final List<OrderItemModel> items;
  final AddressModel? shippingAddress;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    this.subtotal = 0,
    this.shippingCost = 0,
    this.paymentUrl,
    this.trackingNumber,
    this.refundRequestedAt,
    required this.items,
    this.shippingAddress,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: ParserUtils.parseInt(json['id']),
      orderNumber: json['order_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalAmount:
          ParserUtils.parseDouble(json['total_amount'] ?? json['total']),
      subtotal:
          ParserUtils.parseDouble(json['subtotal'] ?? json['subtotal_amount']),
      shippingCost: ParserUtils.parseDouble(
          json['shipping_cost'] ?? json['shipping_amount']),
      paymentUrl: json['payment_url'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      refundRequestedAt: json['refund_requested_at'] != null
          ? DateTime.tryParse(json['refund_requested_at'].toString())
          : null,
      items: ParserUtils.parseList(
        json['items'] ?? json['order_items'],
        OrderItemModel.fromJson,
      ),
      shippingAddress: json['shipping_address'] != null
          ? AddressModel.fromJson(
              ParserUtils.parseMap(json['shipping_address']))
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        totalAmount,
        subtotal,
        shippingCost,
        paymentUrl,
        trackingNumber,
        items,
        shippingAddress,
        createdAt,
      ];
}
