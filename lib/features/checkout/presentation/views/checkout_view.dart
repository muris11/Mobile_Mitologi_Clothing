import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/utils/currency_formatter.dart';
import 'package:mitologi_clothing_mobile/core/widgets/animated_snackbar.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/data/checkout_repository.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/checkout_view_model.dart';
import 'package:mitologi_clothing_mobile/features/checkout/presentation/views/midtrans_payment_screen.dart';
import 'package:mitologi_clothing_mobile/features/profile/presentation/profile_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  bool _verificationCancelled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutViewModel>().fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CheckoutViewModel>();
    final cartVM = context.watch<CartViewModel>();

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
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCheckoutContent(viewModel, cartVM),
      bottomNavigationBar: _buildBottomBar(context, viewModel),
    );
  }

  Widget _buildCheckoutContent(
      CheckoutViewModel viewModel, CartViewModel cartVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Alamat Pengiriman', PhosphorIconsRegular.mapPin),
          const Gap(12),
          if (viewModel.addresses.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppBorderRadius.lgRadius,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.warningCircle,
                      color: AppColors.onSurfaceVariant),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      'Belum ada alamat. Silakan tambahkan.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            )
          else
            ...viewModel.addresses.map((address) {
              final isSelected = viewModel.selectedAddress == address;
              return GestureDetector(
                onTap: () => viewModel.selectAddress(address),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainerLowest,
                    borderRadius: AppBorderRadius.lgRadius,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [AppShadows.card] : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? PhosphorIconsFill.checkCircle
                            : PhosphorIconsRegular.circle,
                        color: isSelected
                            ? AppColors.secondaryContainer
                            : AppColors.outlineVariant,
                        size: 22,
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.onSurface,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              address.fullAddress,
                              style: AppTextStyles.bodySmall.copyWith(
                                height: 1.4,
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const Gap(28),
          _buildSectionTitle('Metode Pengiriman', PhosphorIconsRegular.truck),
          const Gap(12),
          _buildShippingToggle(viewModel),
          const Gap(12),
          if (viewModel.shippingMethod == ShippingMethod.delivery) ...[
            if (viewModel.isLoading)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppBorderRadius.lgRadius,
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (viewModel.error != null && viewModel.error!.contains('Gagal menghitung'))
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.lgRadius,
                ),
                child: Text(
                  viewModel.error!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else if (viewModel.shippingOptions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppBorderRadius.lgRadius,
                ),
                child: Text(
                  viewModel.selectedAddress != null
                      ? 'Opsi pengiriman tidak tersedia'
                      : 'Pilih alamat terlebih dahulu untuk melihat opsi pengiriman',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...viewModel.shippingOptions.map((option) {
                final isSelected = viewModel.selectedShippingOption == option;
                return GestureDetector(
                  onTap: () => viewModel.selectShippingOption(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerLowest,
                      borderRadius: AppBorderRadius.lgRadius,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? PhosphorIconsFill.checkCircle
                              : PhosphorIconsRegular.circle,
                          color: isSelected
                              ? AppColors.secondaryContainer
                              : AppColors.outlineVariant,
                          size: 22,
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${option.courier.toUpperCase()} - ${option.service}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.onSurface,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                '${option.description}${option.etd.isNotEmpty ? ' (${option.etd} hari)' : ''}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? Colors.white70
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          option.formattedCost,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.secondaryContainer
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
          const Gap(28),
          _buildSectionTitle('Ringkasan Pesanan', PhosphorIconsRegular.receipt),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppBorderRadius.lgRadius,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Subtotal',
                  cartVM.cart != null
                      ? CurrencyFormatter.formatIDR(cartVM.cart!.totalPrice)
                      : 'Memuat...',
                ),
                const Gap(8),
                _buildSummaryRow(
                  'Ongkos Kirim',
                  viewModel.shippingMethod == ShippingMethod.pickup
                      ? 'Gratis'
                      : (viewModel.selectedShippingOption != null
                          ? viewModel.selectedShippingOption!.formattedCost
                          : '-'),
                ),
                const Divider(height: 24),
                Builder(builder: (context) {
                  final subtotal = cartVM.cart?.totalPrice ?? 0;
                  final shipping = viewModel.shippingMethod == ShippingMethod.pickup
                      ? 0.0
                      : viewModel.shippingCost.toDouble();
                  final total = subtotal + shipping;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        cartVM.cart != null
                            ? CurrencyFormatter.formatIDR(total)
                            : 'Menghitung...',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const Gap(100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppBorderRadius.smRadius,
          ),
          child: Icon(icon, color: AppColors.secondaryContainer, size: 18),
        ),
        const Gap(10),
        Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingToggle(CheckoutViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppBorderRadius.lgRadius,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setShippingMethod(ShippingMethod.pickup),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: viewModel.shippingMethod == ShippingMethod.pickup
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsRegular.storefront,
                      color: viewModel.shippingMethod == ShippingMethod.pickup
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const Gap(8),
                    Flexible(
                      child: Text(
                        'Ambil di Toko',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: viewModel.shippingMethod == ShippingMethod.pickup
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.outlineVariant,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setShippingMethod(ShippingMethod.delivery),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: viewModel.shippingMethod == ShippingMethod.delivery
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsRegular.truck,
                      color: viewModel.shippingMethod == ShippingMethod.delivery
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const Gap(8),
                    Flexible(
                      child: Text(
                        'Kirim ke Alamat',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: viewModel.shippingMethod == ShippingMethod.delivery
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant)),
        Text(value,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _handlePlaceOrder(
      BuildContext context, CheckoutViewModel viewModel) async {
    final result = await viewModel.placeOrder();
    if (!context.mounted) return;

    switch (result) {
      case PlaceOrderResult.mockSuccess:
        context.read<ProfileViewModel>().fetchProfileData();
        final orderNum = viewModel.lastOrderNumber;
        context.go('/checkout/success${orderNum != null ? '?order=$orderNum&mock=true' : ''}');
      case PlaceOrderResult.success:
        final orderNum = viewModel.lastOrderNumber;
        context.go('/checkout/success${orderNum != null ? '?order=$orderNum' : ''}');
      case PlaceOrderResult.paymentRequired:
        final paymentUrl = viewModel.paymentUrl;
        final orderNum = viewModel.lastOrderNumber ?? '';

        if (paymentUrl.isEmpty) {
          AnimatedSnackbar.error(
            context,
            'Gagal mendapatkan token pembayaran dari gerbang Midtrans.',
            title: 'Pembayaran Gagal',
          );
          return;
        }

        await Navigator.of(context).push<MidtransPaymentResult>(
          MaterialPageRoute(
            builder: (_) => MidtransPaymentScreen(
              paymentUrl: paymentUrl,
              orderNumber: orderNum,
            ),
          ),
        );

        if (!context.mounted) return;
        await _verifyPaymentAndNavigate(context, orderNum);
      case PlaceOrderResult.error:
        if (viewModel.error != null) {
          AnimatedSnackbar.error(
            context,
            viewModel.error!,
            title: 'Pesanan Gagal',
          );
        }
    }
  }

  Future<void> _verifyPaymentAndNavigate(
      BuildContext context, String orderNum) async {
    _verificationCancelled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) _verificationCancelled = true;
        },
        child: AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(height: 20),
              Text(
                'Memverifikasi\nPembayaran',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Mohon tunggu sebentar\nyaa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final repo = context.read<CheckoutRepository>();
    const paidStatuses = ['processing', 'paid', 'completed'];

    try {
      final paid = await repo.confirmPayment(orderNum);
      if (!context.mounted || _verificationCancelled) return;
      if (paid != null && paidStatuses.contains(paid.status)) {
        if (context.mounted) {
          Navigator.of(context).pop();
          context.go('/checkout/success?order=$orderNum');
        }
        return;
      }
    } catch (_) {}

    try {
      for (var i = 0; i < 5; i++) {
        if (_verificationCancelled) return;
        await Future.delayed(const Duration(seconds: 2));
        if (!context.mounted || _verificationCancelled) return;
        final order = await repo.getOrderDetail(orderNum);
        if (paidStatuses.contains(order.status)) {
          if (context.mounted) {
            Navigator.of(context).pop();
            context.go('/checkout/success?order=$orderNum');
          }
          return;
        }
      }
    } catch (_) {}

    if (!context.mounted || _verificationCancelled) return;
    Navigator.of(context).pop();
    context.go('/orders/$orderNum');
  }

  Widget _buildBottomBar(BuildContext context, CheckoutViewModel viewModel) {
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => _handlePlaceOrder(context, viewModel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.lgRadius,
                  ),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'BUAT PESANAN',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontSize: 15,
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
