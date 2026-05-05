import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  final String? orderNumber;

  const CheckoutSuccessScreen({super.key, this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(32),
              _buildSuccessIcon(),
              const Gap(32),
              _buildTitle(context),
              const Gap(16),
              _buildSubtitle(context),
              if (orderNumber != null) ...[
                const Gap(16),
                _buildOrderNumber(context),
              ],
              const Gap(48),
              _buildActions(context),
              const Gap(24),
              _buildEmailNote(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFBBF7D0), width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        PhosphorIconsFill.checkCircle,
        color: Color(0xFF10B981),
        size: 48,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Pesanan Berhasil!',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Terima kasih telah berbelanja di Mitologi Clothing.\nPesanan Anda sedang diproses.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
    );
  }

  Widget _buildOrderNumber(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Text(
        'Order #$orderNumber',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              if (orderNumber != null) {
                context.go('/orders/$orderNumber');
              } else {
                context.go('/profile');
              }
            },
            icon: const Icon(PhosphorIconsRegular.package),
            label: const Text(
              'Lihat Pesanan Saya',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const Gap(12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/products'),
            icon: const Icon(PhosphorIconsRegular.shoppingBag),
            label: const Text(
              'Lanjut Belanja',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailNote(BuildContext context) {
    return Text(
      'Konfirmasi pesanan telah dikirim ke email Anda.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
    );
  }
}
