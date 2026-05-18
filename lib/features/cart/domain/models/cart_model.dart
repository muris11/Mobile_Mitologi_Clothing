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
    final cost = ParserUtils.parseMap(json['cost']);
    final totalAmount = ParserUtils.parseMap(cost['totalAmount']);
    return CartModel(
      id: json['id']?.toString() ?? '',
      items: ParserUtils.parseList(json['lines'], CartItemModel.fromJson),
      totalPrice: ParserUtils.parseDouble(totalAmount['amount']),
      totalItems: ParserUtils.parseInt(json['totalQuantity']),
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
    final merchandise = ParserUtils.parseMap(json['merchandise']);
    final product = ParserUtils.parseMap(merchandise['product']);
    final cost = ParserUtils.parseMap(json['cost']);
    final totalAmount = ParserUtils.parseMap(cost['totalAmount']);
    final featuredImage = ParserUtils.parseMap(product['featuredImage']);
    return CartItemModel(
      id: ParserUtils.parseInt(json['id']),
      productId: ParserUtils.parseInt(product['id']),
      name: product['title'] as String? ?? '',
      price: ParserUtils.parseDouble(totalAmount['amount']),
      quantity: ParserUtils.parseInt(json['quantity'], defaultValue: 1),
      variantId: ParserUtils.parseInt(merchandise['id']),
      featuredImageUrl: featuredImage['url'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, productId, name, price, quantity, variantId, featuredImageUrl];
}
