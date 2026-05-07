import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_model.dart';
import 'package:mitologi_clothing_mobile/features/wishlist/presentation/wishlist_provider.dart';
import 'package:mitologi_clothing_mobile/widgets/product/product_card.dart';
import 'package:provider/provider.dart';

class HomeProductGrid extends StatelessWidget {
  final List<ProductModel> products;

  const HomeProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 278,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final wishlistProvider = context.watch<WishlistProvider>();
            return SizedBox(
              width: 182,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ProductCard(
                  product: product,
                  width: 182,
                  isInWishlist: wishlistProvider.isInWishlist(product.id),
                  onWishlistToggle: () {
                    wishlistProvider.toggleWishlist(product.id);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
