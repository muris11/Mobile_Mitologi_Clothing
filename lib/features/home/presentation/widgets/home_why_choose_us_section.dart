import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeWhyChooseUsSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeWhyChooseUsSection({super.key, required this.viewModel});

  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosMuted = Color(0xFFF1F5F9);
  static const Color _iosSubtext = Color(0xFF64748B);
  static const Color _iosGold = Color(0xFFD8A73C);
  static const Color _iosNavy = Color(0xFF1E2A44);

  @override
  Widget build(BuildContext context) {
    final settings = viewModel.siteSettings;
    final guarantees = settings?.guaranteesData ?? [];
    if (guarantees.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final icons = [
      PhosphorIconsRegular.clock,
      PhosphorIconsRegular.thumbsUp,
      PhosphorIconsRegular.arrowsClockwise,
      PhosphorIconsRegular.shieldCheck,
      PhosphorIconsRegular.star,
      PhosphorIconsRegular.medal,
    ];

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: _iosMuted,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 32, height: 2, color: _iosGold),
                    const Gap(10),
                    const Text(
                      'KENAPA MEMILIH KAMI?',
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
                  'Standar Kualitas Terbaik',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _iosText,
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final g = guarantees[i];
                return Container(
                  color: _iosMuted,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _iosSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _iosBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _iosNavy,
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                                g.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: _iosText,
                                ),
                              ),
                              if (g.description.isNotEmpty) ...[
                                const Gap(4),
                                Text(
                                  g.description,
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
                  ),
                );
              },
              childCount: guarantees.length,
            ),
          ),
        ),
      ],
    );
  }
}
