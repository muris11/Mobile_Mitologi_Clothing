import 'package:equatable/equatable.dart';
import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class CartModel extends Equatable {
  final String id;
  final List<CartItemModel> items;
  final double totalPrice;
  final int totalItems;

  const CartModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.totalItems,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id']?.toString() ?? '',
      items: ParserUtils.parseList(json['items'], CartItemModel.fromJson),
      totalPrice: ParserUtils.parseDouble(json['total_price']),
      totalItems: ParserUtils.parseInt(json['total_items']),
    );
  }

  @override
  List<Object?> get props => [id, items, totalPrice, totalItems];
}

class CartItemModel extends Equatable {
  final int id;
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final int? variantId;
  final String? featuredImageUrl;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.variantId,
    this.featuredImageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: ParserUtils.parseInt(json['id']),
      productId: ParserUtils.parseInt(json['product_id']),
      name: json['name'] as String? ?? '',
      price: ParserUtils.parseDouble(json['price']),
      quantity: ParserUtils.parseInt(json['quantity'], defaultValue: 1),
      variantId: json['variant_id'] != null
          ? ParserUtils.parseInt(json['variant_id'])
          : null,
      featuredImageUrl: json['featured_image_url'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, productId, name, price, quantity, variantId, featuredImageUrl];
}
