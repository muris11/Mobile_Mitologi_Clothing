import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gap/gap.dart';

class HomePortfolioSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomePortfolioSection({super.key, required this.viewModel});

  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosMuted = Color(0xFFF1F5F9);
  static const Color _iosSubtext = Color(0xFF64748B);
  static const Color _iosNavy = Color(0xFF1E2A44);

  @override
  Widget build(BuildContext context) {
    final portfolio = viewModel.portfolioItems.take(4).toList();
    if (portfolio.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _buildSectionHeaderInline(
            context,
            title: 'Portofolio',
            subtitle: 'Lihat hasil produksi terbaik kami untuk komunitas, organisasi, dan brand',
            onSeeAll: () => context.go('/portfolio'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = portfolio[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(
                        imageUrl: ApiConfig.buildImageUrl(item.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                _iosNavy.withValues(alpha: 0.92),
                              ],
                            ),
                          ),
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: portfolio.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderInline(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: _iosText,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _iosSubtext,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: _iosMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.arrowRight,
                size: 20,
                color: _iosText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
