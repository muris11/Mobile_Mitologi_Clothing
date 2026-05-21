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
      productTitle: json['productTitle'] as String? ??
          json['product_title'] as String? ??
          json['name'] as String? ??
          '',
      productHandle: json['productHandle'] as String? ??
          json['product_handle'] as String?,
      productImage: json['productImage'] as String? ??
          json['product_image'] as String?,
      variantTitle: json['variantTitle'] as String? ??
          json['variant_title'] as String?,
      quantity: ParserUtils.parseInt(json['quantity']),
      price: ParserUtils.parseDouble(json['price']),
      total: ParserUtils.parseDouble(json['total'] ?? json['subtotal']),
    );
  }

  @override
  List<Object?> get props => [id, productTitle, quantity, price, total];
}

class TrackingEventModel extends Equatable {
  final int id;
  final String status;
  final String title;
  final String? description;
  final String? location;
  final bool isSystemEvent;
  final DateTime occurredAt;

  const TrackingEventModel({
    required this.id,
    required this.status,
    required this.title,
    this.description,
    this.location,
    required this.isSystemEvent,
    required this.occurredAt,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      id: ParserUtils.parseInt(json['id']),
      status: json['status'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      isSystemEvent: json['isSystemEvent'] as bool? ??
          json['is_system_event'] as bool? ??
          true,
      occurredAt: DateTime.tryParse(json['occurredAt'] as String? ??
              json['occurred_at'] as String? ??
              '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, status, title, occurredAt];
}

class OrderTrackingModel extends Equatable {
  final String orderNumber;
  final String status;
  final String statusLabel;
  final String? shippingCourier;
  final String? trackingNumber;
  final Map<String, dynamic>? currentStatus;
  final Map<String, dynamic>? shippingAddress;
  final List<TrackingEventModel> events;

  const OrderTrackingModel({
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    this.shippingCourier,
    this.trackingNumber,
    this.currentStatus,
    this.shippingAddress,
    required this.events,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      orderNumber: json['orderNumber'] as String? ??
          json['order_number'] as String? ??
          '',
      status: json['status'] as String? ?? '',
      statusLabel: json['statusLabel'] as String? ??
          json['status_label'] as String? ??
          '',
      shippingCourier: json['shippingCourier'] as String? ??
          json['shipping_courier'] as String?,
      trackingNumber: json['trackingNumber'] as String? ??
          json['tracking_number'] as String?,
      currentStatus: json['currentStatus'] as Map<String, dynamic>? ??
          json['current_status'] as Map<String, dynamic>?,
      shippingAddress: json['shippingAddress'] as Map<String, dynamic>? ??
          json['shipping_address'] as Map<String, dynamic>?,
      events: ParserUtils.parseList(
        json['events'],
        TrackingEventModel.fromJson,
      ),
    );
  }

  @override
  List<Object?> get props => [orderNumber, status, events];
}

class OrderModel extends Equatable {
  final int id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final double subtotal;
  final double shippingCost;
  final int itemsCount;
  final String? paymentUrl;
  final String? trackingNumber;
  final String? shippingCourier;
  final DateTime? refundRequestedAt;
  final String? refundReason;
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
    this.itemsCount = 0,
    this.paymentUrl,
    this.trackingNumber,
    this.shippingCourier,
    this.refundRequestedAt,
    this.refundReason,
    required this.items,
    this.shippingAddress,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: ParserUtils.parseInt(json['id']),
      orderNumber: json['orderNumber'] as String? ??
          json['order_number'] as String? ??
          '',
      status: json['status'] as String? ?? '',
      totalAmount: ParserUtils.parseDouble(
        json['total'] ?? json['total_amount'],
      ),
      subtotal: ParserUtils.parseDouble(
        json['subtotal'] ?? json['subtotal_amount'],
      ),
      shippingCost: ParserUtils.parseDouble(
        json['shippingCost'] ?? json['shipping_cost'] ?? json['shipping_amount'],
      ),
      itemsCount: ParserUtils.parseInt(
        json['itemsCount'] ?? json['items_count'],
      ),
      paymentUrl: json['paymentUrl'] as String? ??
          json['payment_url'] as String?,
      trackingNumber: json['trackingNumber'] as String? ??
          json['tracking_number'] as String?,
      shippingCourier: json['shippingCourier'] as String? ??
          json['shipping_courier'] as String?,
      refundRequestedAt: json['refundRequestedAt'] != null
          ? DateTime.tryParse(json['refundRequestedAt'].toString())
          : json['refund_requested_at'] != null
              ? DateTime.tryParse(json['refund_requested_at'].toString())
              : null,
      refundReason: json['refundReason'] as String? ??
          json['refund_reason'] as String?,
      items: ParserUtils.parseList(
        json['items'] ?? json['order_items'],
        OrderItemModel.fromJson,
      ),
      shippingAddress: json['shippingAddress'] != null
          ? AddressModel.fromJson(
              ParserUtils.parseMap(json['shippingAddress']))
          : json['shipping_address'] != null
              ? AddressModel.fromJson(
                  ParserUtils.parseMap(json['shipping_address']))
              : null,
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';

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
        shippingCourier,
        items,
        shippingAddress,
        createdAt,
      ];
}
