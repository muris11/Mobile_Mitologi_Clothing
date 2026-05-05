import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class AddToCartBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required ProductModel product,
    dynamic selectedVariant,
    required int quantity,
    VoidCallback? onContinueShopping,
    VoidCallback? onViewCart,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produk ditambahkan ke keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product.name),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContinueShopping,
                    child: const Text('Lanjut Belanja'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewCart,
                    child: const Text('Lihat Keranjang'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

