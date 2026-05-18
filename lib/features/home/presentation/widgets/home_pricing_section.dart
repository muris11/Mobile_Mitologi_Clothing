import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/domain/models/site_settings_model.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePricingSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomePricingSection({super.key, required this.viewModel});

  static Color get _iosBg => AppColors.background;
  static Color get _iosSurface => AppColors.surfaceContainerLowest;
  static Color get _iosBorder => AppColors.outlineVariant;
  static Color get _iosText => AppColors.onSurface;
  static Color get _iosNavy => AppColors.primary;
  static Color get _iosGold => AppColors.secondary;
  static Color get _iosCream => AppColors.surfaceContainerLow;
  static Color get _iosSubtext => AppColors.onSurfaceVariant;
  static Color get _iosMuted => AppColors.surfaceContainerLow;

  @override
  Widget build(BuildContext context) {
    final settings = viewModel.siteSettings;
    if (settings == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final items = settings.plastisolPricing;
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final addons = settings.pricingAddons;

    final features = settings.pricingFeaturesData;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: _iosBg,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(width: 32, height: 2, color: _iosGold),
                  const Gap(10),
                  Text('PRICELIST',
                      style: TextStyle(
                          color: _iosGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2)),
                ]),
                const Gap(12),
                Text(
                  'Pricelist Sablon Plastisol',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _iosText,
                  ),
                ),
                const Gap(6),
                Text(
                  'Harga terbaik untuk kualitas premium. Garansi detailing & ketepatan waktu.',
                  style: TextStyle(
                    color: _iosSubtext,
                    fontSize: 13,
                  ),
                ),
                if (features.isNotEmpty) ...[
                  const Gap(16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: features
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _iosSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _iosBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _iosGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      PhosphorIconsRegular.check,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(f.text.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final pkg = items[i];
                return Container(
                  decoration: BoxDecoration(
                    color: _iosSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _iosBorder),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: pkg.image != null && pkg.image!.isNotEmpty
                              ? AppImage(
                                  imageUrl: ApiConfig.buildImageUrl(pkg.image!),
                                  fit: BoxFit.contain,
                                )
                              : const Icon(
                                  PhosphorIconsRegular.tShirt,
                                  size: 48,
                                  color: Color(0xFFCBD5E1),
                                ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _iosCream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              pkg.title.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _iosNavy,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (pkg.minOrder != null &&
                                pkg.minOrder!.isNotEmpty)
                              Text(
                                pkg.minOrder!,
                                style: TextStyle(
                                  color: _iosSubtext,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        child: Column(
                          children: [
                            _priceRow('Pendek', pkg.short ?? '-'),
                            const Gap(4),
                            _priceRow('Panjang', pkg.long ?? '-'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
        if (addons.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              color: _iosBg,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _iosNavy,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add-ons & Ketentuan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                    const Gap(16),
                    ...addons.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(a.name,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text('+ Rp ${a.price}/pcs',
                                  style: TextStyle(
                                      color: _iosGold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _iosMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: _iosSubtext,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          Text(value,
              style: TextStyle(
                  color: _iosNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
