import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class ShareSheet {
  static Future<void> show(BuildContext context, ProductModel product) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bagikan: ${product.name}')),
    );
  }
}

