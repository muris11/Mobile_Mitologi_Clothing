import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_button.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/catalog_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProductDetailView extends StatefulWidget {
  final String slug;

  const ProductDetailView({super.key, required this.slug});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _quantity = 1;
  int? _selectedVariantId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogViewModel>().getProductDetail(widget.slug);
    });
  }

  void _handleAddToCart() async {
    final product = context.read<CatalogViewModel>().selectedProduct;
    if (product != null) {
      final cartViewModel = context.read<CartViewModel>();
      await context.read<CartViewModel>().addToCart(
            productId: product.id,
            quantity: _quantity,
            variantId: _selectedVariantId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cartViewModel.error ?? 'Added to cart',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatalogViewModel>();
    final product = viewModel.selectedProduct;

    return Scaffold(
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Product not found'))
              : _buildContent(context, product),
      bottomNavigationBar:
          product != null ? _buildBottomBar(context, product) : null,
    );
  }

  Widget _buildContent(BuildContext context, ProductDetailModel product) {
    final gallery = product.images.isNotEmpty
        ? product.images
        : [product.featuredImageUrl].where((e) => e.isNotEmpty).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          expandedHeight: 420,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(PhosphorIconsRegular.shareNetwork),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  imageUrl: ApiConfig.buildImageUrl(product.featuredImageUrl),
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'NEW DROP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      const Gap(12),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.08,
                            ),
                      ),
                      const Gap(8),
                      Text(
                        _formatPrice(product.displayPrice),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Text(
                          'Beranda',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const Icon(PhosphorIconsRegular.caretRight, size: 12),
                      GestureDetector(
                        onTap: () => context.go('/products'),
                        child: Text(
                          'Katalog',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const Icon(PhosphorIconsRegular.caretRight, size: 12),
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [AppShadows.cardSoft],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProductMeta(
                          label: 'Stock',
                          value: '${product.stock}',
                          icon: PhosphorIconsRegular.package,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _ProductMeta(
                          label: 'Reviews',
                          value: '${product.reviewsCount}',
                          icon: PhosphorIconsRegular.star,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _ProductMeta(
                          label: 'Rating',
                          value: product.rating?.toStringAsFixed(1) ?? '-',
                          icon: PhosphorIconsRegular.chartBar,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spesifikasi Produk',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Gap(16),
                      _SpecRow(label: 'Kategori', value: 'Produk Mitologi'),
                      _SpecRow(
                          label: 'Stok',
                          value: 'Tersedia ${product.stock} buah'),
                      _SpecRow(
                          label: 'Pengiriman', value: 'Cirebon, Jawa Barat'),
                      _SpecRow(
                        label: 'SKU',
                        value: product.variants.isNotEmpty
                            ? product.variants.first.name
                            : '-',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Gap(10),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                ),
                if (gallery.length > 1) ...[
                  const Gap(24),
                  Text(
                    'Gallery',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(12),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (context, index) => const Gap(12),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            width: 84,
                            child: AppImage(
                              imageUrl: ApiConfig.buildImageUrl(gallery[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const Gap(32),
                if (product.variants.isNotEmpty) ...[
                  Text(
                    'Variants',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: product.variants.map((variant) {
                      final isSelected = _selectedVariantId == variant.id;
                      return ChoiceChip(
                        label: Text(variant.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedVariantId =
                              selected ? variant.id : null);
                        },
                      );
                    }).toList(),
                  ),
                ],
                const Gap(28),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _TrustBadge(
                          icon: PhosphorIconsRegular.shieldCheck,
                          label: 'Garansi\nMitologi',
                        ),
                      ),
                      Expanded(
                        child: _TrustBadge(
                          icon: PhosphorIconsRegular.truck,
                          label: 'Garansi\nOngkir',
                        ),
                      ),
                      Expanded(
                        child: _TrustBadge(
                          icon: PhosphorIconsRegular.chatCircleDots,
                          label: 'Chat\nPenjual',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, dynamic product) {
    final cartViewModel = context.watch<CartViewModel>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surfaceContainerLow,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.minus, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'KERANJANG',
                      variant: AppButtonVariant.outline,
                      isLoading: cartViewModel.isLoading,
                      onPressed: _handleAddToCart,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: AppButton(
                      text: 'BELI',
                      isLoading: cartViewModel.isLoading,
                      onPressed: () {
                        _handleAddToCart();
                        if (context.mounted) {
                          context.push('/checkout');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final whole = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp $buffer';
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _SpecRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: 2),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const Gap(6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(icon, size: 20),
        ),
        const Gap(8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _ProductMeta extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProductMeta({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const Gap(8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const Gap(2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
