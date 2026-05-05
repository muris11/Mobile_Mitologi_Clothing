import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LayananScreen extends StatelessWidget {
  const LayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Layanan Produksi',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(context, vm),
                const Gap(24),
                if (vm.productPricings.isNotEmpty) ...[
                  _buildSectionTitle('Harga Produk'),
                  const Gap(12),
                  _buildPricingList(vm),
                  const Gap(24),
                ],
                if (vm.printingMethods.isNotEmpty) ...[
                  _buildSectionTitle('Metode Cetak'),
                  const Gap(12),
                  _buildPrintingList(vm),
                  const Gap(24),
                ],
                _buildCta(context),
                const Gap(32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, HomeViewModel vm) {
    final tagline = vm.siteSettings?.siteTagline ??
        'Solusi lengkap untuk kebutuhan produksi pakaian Anda dengan kualitas terbaik.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Program Kerja',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          const Gap(12),
          Text(
            'Layanan Produksi',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const Gap(8),
          Text(
            tagline,
            style: const TextStyle(
                color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
    );
  }

  Widget _buildPricingList(HomeViewModel vm) {
    return Column(
      children: vm.productPricings.map((pricing) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(PhosphorIconsRegular.tShirt,
                    size: 20, color: AppColors.primary),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pricing.categoryName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    if (pricing.minOrder?.isNotEmpty ?? false)
                      Text('Min. order: ${pricing.minOrder}',
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant, fontSize: 12)),
                    if (pricing.notes?.isNotEmpty ?? false)
                      Text(pricing.notes!,
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
              ),
              if (pricing.items.isNotEmpty)
                Text(
                  pricing.items.first.priceRange,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.primary),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrintingList(HomeViewModel vm) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: vm.printingMethods.length,
      itemBuilder: (context, i) {
        final method = vm.printingMethods[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (method.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(
                    imageUrl: ApiConfig.buildImageUrl(method.image),
                    height: 48,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Icon(PhosphorIconsRegular.paintBrush,
                    size: 32, color: AppColors.primary),
              const Gap(8),
              Text(method.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (method.description.isNotEmpty)
                Text(method.description,
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Text('Tertarik dengan layanan kami?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              textAlign: TextAlign.center),
          const Gap(8),
          const Text('Hubungi kami untuk konsultasi lebih lanjut.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://wa.me/6281322170902');
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(PhosphorIconsRegular.whatsappLogo, size: 18),
              label: const Text('Konsultasi via WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
