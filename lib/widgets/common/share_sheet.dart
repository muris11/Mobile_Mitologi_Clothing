import 'package:flutter/material.dart';
import '../../models/product.dart';

class ShareSheet {
  static Future<void> show(BuildContext context, Product product) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bagikan: ${product.title}')),
    );
  }
}
