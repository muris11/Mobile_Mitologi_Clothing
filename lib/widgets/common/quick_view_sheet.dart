import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class QuickViewBottomSheet {
  static Future<void> show(BuildContext context, ProductModel product) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

