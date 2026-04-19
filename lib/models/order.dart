import 'money.dart';
import 'address.dart';

/// Order model
class Order {
  final String id;
  final String orderNumber;
  final String? status;
  final String? financialStatus;
  final String? fulfillmentStatus;
  final DateTime? processedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Money? total;
  final Money? subtotal;
  final Money? shipping;
  final Money? tax;
  final List<OrderItem>? items;
  final Address? shippingAddress;
  final String? customerEmail;
  final String? customerName;
  final String? phone;
  final String? note;
  final String? paymentMethod;
  final String? trackingNumber;
  final String? trackingUrl;

  Order({
    required this.id,
    required this.orderNumber,
    this.status,
    this.financialStatus,
    this.fulfillmentStatus,
    this.processedAt,
    this.createdAt,
    this.updatedAt,
    this.total,
    this.subtotal,
    this.shipping,
    this.tax,
    this.items,
    this.shippingAddress,
    this.customerEmail,
    this.customerName,
    this.phone,
    this.note,
    this.paymentMethod,
    this.trackingNumber,
    this.trackingUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final orderData = json['order'] ?? json;

    return Order(
      id: orderData['id']?.toString() ?? '',
      orderNumber: orderData['order_number'] ??
          orderData['orderNumber'] ??
          orderData['name'] as String? ??
          '',
      status: orderData['status'] as String?,
      financialStatus: orderData['financial_status'] as String?,
      fulfillmentStatus: orderData['fulfillment_status'] as String?,
      processedAt: orderData['processed_at'] != null
          ? DateTime.tryParse(orderData['processed_at'] as String)
          : null,
      createdAt: orderData['created_at'] != null
          ? DateTime.tryParse(orderData['created_at'] as String)
          : null,
      updatedAt: orderData['updated_at'] != null
          ? DateTime.tryParse(orderData['updated_at'] as String)
          : null,
      total: orderData['total'] != null
          ? Money.fromJson(orderData['total'])
          : null,
      subtotal: orderData['subtotal'] != null
          ? Money.fromJson(orderData['subtotal'])
          : null,
      shipping: orderData['shipping'] != null
          ? Money.fromJson(orderData['shipping'])
          : orderData['shipping_cost'] != null
              ? Money.fromJson(orderData['shipping_cost'])
              : null,
      tax: orderData['tax'] != null ? Money.fromJson(orderData['tax']) : null,
      items: orderData['items'] != null
          ? (orderData['items'] as List)
              .map((i) => OrderItem.fromJson(i))
              .toList()
          : null,
      shippingAddress: orderData['shipping_address'] != null
          ? Address.fromJson(orderData['shipping_address'])
          : null,
      customerEmail: orderData['customer_email'] as String?,
      customerName: orderData['customer_name'] as String?,
      phone: orderData['phone'] as String?,
      note: orderData['note'] ?? orderData['notes'] as String?,
      paymentMethod: orderData['payment_method'] as String?,
      trackingNumber: orderData['tracking_number'] as String?,
      trackingUrl: orderData['tracking_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'total': total?.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get display status
  String get displayStatus {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Diproses';
      case 'paid':
        return 'Dibayar';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Sampai Tujuan';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return status ?? 'Unknown';
    }
  }

  /// Check if order can be cancelled
  bool get canCancel =>
      status?.toLowerCase() == 'pending' ||
      status?.toLowerCase() == 'processing';

  /// Check if order can be tracked
  bool get canTrack =>
      status?.toLowerCase() == 'shipped' ||
      status?.toLowerCase() == 'delivered';
}

/// Order item model
class OrderItem {
  final String id;
  final String title;
  final int quantity;
  final Money? price;
  final Money? total;
  final String? imageUrl;
  final String? variantTitle;
  final String? sku;

  OrderItem({
    required this.id,
    required this.title,
    required this.quantity,
    this.price,
    this.total,
    this.imageUrl,
    this.variantTitle,
    this.sku,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] as String? ?? 'Product',
      quantity: json['quantity'] as int,
      price: json['price'] != null ? Money.fromJson(json['price']) : null,
      total: json['total'] != null ? Money.fromJson(json['total']) : null,
      imageUrl: json['image_url'] ?? json['image']?['url'] as String?,
      variantTitle: json['variant_title'] as String?,
      sku: json['sku'] as String?,
    );
  }
}
