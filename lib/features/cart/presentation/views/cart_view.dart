import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/utils/currency_formatter.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/cart/domain/models/cart_model.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CartViewModel>();
    final cart = viewModel.cart;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          if (cart != null && cart.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${cart.items.length} item',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: viewModel.isLoading && cart == null
          ? const Center(child: CircularProgressIndicator())
          : cart == null || cart.items.isEmpty
              ? _buildEmptyState()
              : _buildCartList(viewModel),
      bottomNavigationBar: cart != null && cart.items.isNotEmpty
          ? _buildCheckoutBar(context, cart)
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.shoppingCartSimple,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Gap(24),
            Text(
              'Keranjang Kosong',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(8),
            Text(
              'Belum ada produk. Yuk mulai belanja!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.lgRadius,
                  ),
                ),
                child: Text(
                  'MULAI BELANJA',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(CartViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: viewModel.cart!.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.cart!.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppBorderRadius.xxlRadius,
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [AppShadows.cardSoft],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppBorderRadius.lgRadius,
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: AppImage(
                      imageUrl:
                          ApiConfig.buildImageUrl(item.featuredImageUrl ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        CurrencyFormatter.formatIDR(item.price),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppBorderRadius.smRadius,
                            ),
                            child: Row(
                              children: [
                                _QtyButton(
                                  icon: PhosphorIconsRegular.minus,
                                  enabled: item.quantity > 1,
                                  onTap: () => viewModel.updateQuantity(
                                      item.id, item.quantity - 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    '${item.quantity}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                _QtyButton(
                                  icon: PhosphorIconsRegular.plus,
                                  enabled: true,
                                  onTap: () => viewModel.updateQuantity(
                                      item.id, item.quantity + 1),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(PhosphorIconsRegular.trash,
                                size: 20),
                            color: AppColors.error,
                            onPressed: () => viewModel.removeFromCart(item.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartModel cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [AppShadows.bottomNav],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${cart.items.length} item)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatIDR(cart.totalPrice),
                  style: AppTextStyles.headingMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Gap(14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/checkout'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.lgRadius,
                  ),
                ),
                child: Text(
                  'CHECKOUT',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
