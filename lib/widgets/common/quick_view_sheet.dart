import 'package:flutter/material.dart';
import '../../models/product.dart';

class QuickViewBottomSheet {
  static Future<void> show(BuildContext context, Product product) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product.description ?? ''),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
