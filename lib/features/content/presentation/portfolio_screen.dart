import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/widgets/common/custom_pull_to_refresh.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';
import 'package:mitologi_clothing_mobile/widgets/common/shimmer_image.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/mitologi_sliver_app_bar.dart';
import 'package:provider/provider.dart';

import 'content_provider.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadPortfolios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomPullToRefresh(
        onRefresh: () => context.read<ContentProvider>().loadPortfolios(),
        child: CustomScrollView(
          slivers: [
            const MitologiSliverAppBar(pageTitle: 'Portfolio'),
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            Consumer<ContentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.portfolios.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: ProductCardSkeleton(),
                        ),
                        childCount: 3,
                      ),
                    ),
                  );
                }

                if (provider.portfolios.isEmpty) {
                  return SliverFillRemaining(
                    child: AnimatedEmptyState(
                      icon: Icons.auto_awesome_mosaic_outlined,
                      title: 'Belum Ada Portfolio',
                      subtitle:
                          'Kami sedang menyiapkan konten menarik untuk Anda.',
                      actionLabel: 'Kembali',
                      onAction: () => context.pop(),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = provider.portfolios[index];
                        return _buildPortfolioCard(context, item, index);
                      },
                      childCount: provider.portfolios.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 2,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'OUR JOURNEY',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Masterpieces',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Showcasing our best work and collaborations',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 14,
              color: AppColors.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(
      BuildContext context, PortfolioItem item, int index) {
    final cleanDescription = item.description != null
        ? item.description!
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'")
            .trim()
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: () => context.push('/portfolio/${item.slug}'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ShimmerImage(
                    imageUrl: ApiConfig.buildImageUrl(item.imageUrl ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.category != null)
                        Text(
                          item.category!.toUpperCase(),
                          style: AppTextStyles.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (cleanDescription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          cleanDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.outline,
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
        ),
      ),
    );
  }
}

