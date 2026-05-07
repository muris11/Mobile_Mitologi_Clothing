import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeGuaranteeBonusSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeGuaranteeBonusSection({super.key, required this.viewModel});

  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosSubtext = Color(0xFF64748B);
  static const Color _iosGold = Color(0xFFD8A73C);
  static const Color _iosNavy = Color(0xFF1E2A44);

  @override
  Widget build(BuildContext context) {
    final settings = viewModel.siteSettings;
    final bonuses = settings?.garansiBonusData ?? [];
    if (bonuses.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final icons = [
      PhosphorIconsRegular.clock,
      PhosphorIconsRegular.shieldCheck,
      PhosphorIconsRegular.gift,
    ];

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 32, height: 2, color: _iosGold),
                    const Gap(10),
                    const Text(
                      'KEUNTUNGAN MEMILIH KAMI',
                      style: TextStyle(
                        color: _iosGold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                const Text(
                  'Garansi & Bonus Eksklusif',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _iosText,
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final b = bonuses[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _iosSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _iosBorder),
                    boxShadow: [AppShadows.cardSoft],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _iosNavy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icons[i % icons.length],
                          color: _iosGold,
                          size: 22,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: _iosText,
                              ),
                            ),
                            if (b.description.isNotEmpty) ...[
                              const Gap(6),
                              Text(
                                b.description,
                                style: const TextStyle(
                                  color: _iosSubtext,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: bonuses.length,
            ),
          ),
        ),
      ],
    );
  }
}
