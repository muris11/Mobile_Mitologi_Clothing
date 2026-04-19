import 'money.dart';
import 'product.dart';

/// Cart model
class Cart {
  final String id;
  final String? checkoutUrl;
  final int? totalQuantity;
  final Money? cost;
  final Money? subtotal;
  final Money? totalTax;
  final List<CartItem> items;

  Cart({
    required this.id,
    this.checkoutUrl,
    this.totalQuantity,
    this.cost,
    this.subtotal,
    this.totalTax,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final cartData = json['cart'] ?? json;

    return Cart(
      id: cartData['id']?.toString() ?? cartData['cart_id']?.toString() ?? '',
      checkoutUrl: cartData['checkout_url'] as String?,
      totalQuantity:
          cartData['total_quantity'] as int? ?? cartData['item_count'] as int?,
      cost: cartData['cost'] != null
          ? Money.fromJson(cartData['cost'])
          : cartData['total'] != null
          ? Money(amount: (cartData['total'] as num).toDouble())
          : null,
      subtotal: cartData['subtotal'] != null
          ? Money.fromJson(cartData['subtotal'])
          : null,
      totalTax: cartData['total_tax'] != null
          ? Money.fromJson(cartData['total_tax'])
          : null,
      items: cartData['items'] != null
          ? (cartData['items'] as List)
                .map((i) => CartItem.fromJson(i))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkout_url': checkoutUrl,
      'total_quantity': totalQuantity,
      'cost': cost?.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  /// Get total amount
  double get total => cost?.amount ?? 0.0;

  /// Get item count
  int get itemCount => items.length;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;
}

/// Cart item model
class CartItem {
  final String id;
  final int quantity;
  final Product? product;
  final ProductVariant? variant;
  final Money? cost;
  final String? merchandiseId;

  CartItem({
    required this.id,
    required this.quantity,
    this.product,
    this.variant,
    this.cost,
    this.merchandiseId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? json['line_id']?.toString() ?? '',
      quantity: json['quantity'] as int,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      variant: json['variant'] != null
          ? ProductVariant.fromJson(json['variant'])
          : json['merchandise'] != null
          ? ProductVariant.fromJson(json['merchandise'])
          : null,
      cost: json['cost'] != null
          ? Money.fromJson(json['cost'])
          : json['price'] != null
          ? Money(
              amount:
                  (json['price'] as num).toDouble() * (json['quantity'] as int),
            )
          : null,
      merchandiseId:
          json['merchandise_id']?.toString() ?? json['variant_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'quantity': quantity, 'merchandise_id': merchandiseId};
  }

  /// Get item total
  double get total => cost?.amount ?? 0.0;

  /// Get item title
  String get title => product?.title ?? variant?.title ?? 'Product';

  /// Get item image
  String? get imageUrl => product?.featuredImage?.url;
}
