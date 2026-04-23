import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/cart.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/animated_snackbar.dart';
import '../../widgets/common/animated_stepper.dart';
import '../../widgets/common/custom_pull_to_refresh.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/shimmer_image.dart';
import '../../widgets/common/skeleton_loading.dart';
import '../../widgets/common/staggered_entrance.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().ensureInitialized();
    });
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(item);
      return;
    }

    final cartProvider = context.read<CartProvider>();
    await cartProvider.updateItem(
      item.id,
      merchandiseId: item.merchandiseId ?? item.variant?.id ?? '',
      quantity: newQuantity,
    );
  }

  Future<void> _removeItem(CartItem item) async {
    // Capture provider before async operation
    final cartProvider = context.read<CartProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Item',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Yakin ingin menghapus ${item.title} dari keranjang?',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cartProvider.removeItem(item.id);
      if (!mounted) return;
    }
  }

  Future<void> _removeItemWithUndo(CartItem item) async {
    final cartProvider = context.read<CartProvider>();
    final merchandiseId = item.merchandiseId ?? item.variant?.id ?? '';
    final quantity = item.quantity;

    await cartProvider.removeItem(item.id);

    if (mounted) {
      AnimatedSnackbar.show(
        context,
        message: '${item.title} dihapus dari keranjang',
        actionLabel: 'Batal',
        onAction: () async {
          if (merchandiseId.isNotEmpty) {
            await cartProvider.addItem(
              merchandiseId: merchandiseId,
              quantity: quantity,
            );
          }
        },
        type: SnackbarType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading && cartProvider.items.isEmpty) {
            return const Scaffold(
              body: CartListSkeleton(),
            );
          }

          final cart = cartProvider.cart;
          final items = cartProvider.items;

          if (items.isEmpty) {
            return _buildEmptyCart();
          }

          return Stack(
            children: [
              CustomPullToRefresh(
                onRefresh: () => cartProvider.loadCart(),
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: AppColors.surface.withValues(alpha: 0.95),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    title: Text(
                      'Keranjang',
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showCartMenu(context),
                      ),
                    ],
                  ),

                  // Editorial Header
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),

                  // Cart Items with staggered entrance
                  SliverStaggeredEntrance(
                    itemCount: items.length,
                    delayMillis: 50,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildDismissibleCartItem(item);
                    },
                  ),

                  // Summary Section
                  SliverToBoxAdapter(
                    child: _buildSummary(cart),
                  ),

                  // Voucher Field
                  SliverToBoxAdapter(
                    child: _buildVoucherField(),
                  ),

                  // Bottom padding for CTA
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ),
              ),

              // Sticky Checkout Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCheckoutCTA(cart?.cost?.formatted ?? 'Rp 0'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return AnimatedEmptyState(
      icon: Icons.shopping_basket_outlined,
      title: 'Keranjang Kosong',
      subtitle: 'Yuk, mulai belanja dan temukan produk favorit Anda!',
      actionLabel: 'Mulai Belanja',
      onAction: () => context.push('/products'),
    );
  }

  Widget _buildHeader() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Get collection name from first item's product or use default
        final collectionName = cartProvider.items.isNotEmpty &&
                cartProvider.items.first.product?.collection != null
            ? cartProvider.items.first.product!.collection!.title
            : 'Koleksi Pilihan';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collectionName.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan Anda',
                style: GoogleFonts.notoSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 2,
                color: AppColors.secondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDismissibleCartItem(CartItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFE53935)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => _removeItemWithUndo(item),
      child: _buildCartItem(item),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final imageUrl = item.imageUrl ?? '';
    final variantInfo = item.variant?.title ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withAlpha(15),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ShimmerImage(
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                width: 96,
                height: 128,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.notoSerif(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (variantInfo.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                variantInfo,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () => _removeItemWithUndo(item),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.cost?.formatted ?? 'Rp 0',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                      // Animated Quantity Stepper
                      AnimatedStepper(
                        quantity: item.quantity,
                        onChanged: (newQuantity) => _updateQuantity(
                          item,
                          newQuantity,
                        ),
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
  }

  Widget _buildSummary(Cart? cart) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ringkasan Belanja',
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSummaryRow(
              'Subtotal (${cart?.totalQuantity ?? 0} Produk)',
              cart?.subtotal?.formatted ?? 'Rp 0',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Biaya Pengiriman',
              (cart?.shipping?.amount ?? 0) > 0
                  ? 'Rp ${cart!.shipping!.amount!.toStringAsFixed(0)}'
                  : 'Gratis Ongkir',
            ),
            if ((cart?.insurance?.amount ?? 0) > 0) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Asuransi Pengiriman',
                'Rp ${cart!.insurance!.amount!.toStringAsFixed(0)}',
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran',
                  style: GoogleFonts.notoSerif(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  cart?.cost?.formatted ?? 'Rp 0',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _showVoucherDialog(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gunakan Kode Promo',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.outline,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutCTA(String total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0),
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => context.push('/checkout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Checkout',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCartMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined,
                  color: AppColors.primary),
              title: Text('Gunakan Kode Promo',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showVoucherDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Kosongkan Keranjang',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showClearCartDialog(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kosongkan Keranjang?',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
        content: Text('Semua item akan dihapus dari keranjang.',
            style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.manrope()),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            child: Text('Kosongkan',
                style: GoogleFonts.manrope(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showVoucherDialog(BuildContext context) {
    final voucherController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Kode Promo',
                style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: voucherController,
              decoration: InputDecoration(
                hintText: 'Masukkan kode promo',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final code = voucherController.text.trim();
                  if (code.isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Kode promo "$code" diterapkan',
                              style: GoogleFonts.manrope())),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Terapkan',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
