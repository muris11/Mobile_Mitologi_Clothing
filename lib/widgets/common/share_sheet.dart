import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/widgets/animated_snackbar.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';

class ShareSheet {
  static Future<void> show(BuildContext context, ProductModel product) async {
    AnimatedSnackbar.success(
      context,
      'Bagikan: ${product.name}',
      title: 'Bagikan',
    );
  }
}

