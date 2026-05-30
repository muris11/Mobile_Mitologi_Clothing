import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/utils/responsive_utils.dart';
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
  String? _selectedCategory;

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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveConfig.getGridColumnCount(context),
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const PortfolioCardSkeleton(),
                        childCount: 6,
                      ),
                    ),
                  );
                }

                final categories = _portfolioCategories(provider.portfolios);
                final visibleItems = _selectedCategory == null
                    ? provider.portfolios
                    : provider.portfolios
                        .where((item) => item.category == _selectedCategory)
                        .toList();

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

                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildCategoryFilters(categories),
                    ),
                    if (visibleItems.isEmpty)
                      SliverFillRemaining(
                        child: AnimatedEmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'Portfolio tidak ditemukan',
                          subtitle: 'Pilih kategori lain untuk melihat karya kami.',
                          actionLabel: 'Reset Filter',
                          onAction: () => setState(() => _selectedCategory = null),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                ResponsiveConfig.getGridColumnCount(context),
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = visibleItems[index];
                              return _buildPortfolioCard(context, item, index);
                            },
                            childCount: visibleItems.length,
                          ),
                        ),
                      ),
                  ],
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

  List<String> _portfolioCategories(List<PortfolioItem> items) {
    return items
        .map((item) => item.category?.trim())
        .whereType<String>()
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
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

  Widget _buildCategoryFilters(List<String> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _PortfolioCategoryChip(
            label: 'Semua',
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...categories.map(
            (category) => _PortfolioCategoryChip(
              label: category,
              isSelected: _selectedCategory == category,
              onTap: () => setState(() {
                _selectedCategory =
                    _selectedCategory == category ? null : category;
              }),
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

    return GestureDetector(
      onTap: () => context.push('/portfolio/${item.slug}'),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
          boxShadow: [AppShadows.cardSoft],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShimmerImage(
              imageUrl: ApiConfig.buildImageUrl(item.imageUrl ?? ''),
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.76),
                  ],
                  stops: const [0, 0.48, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.category != null && item.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.full),
                      ),
                      child: Text(
                        item.category!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.discountBadge.copyWith(
                          fontSize: 9,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  if (cleanDescription.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      cleanDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.35,
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
  }
}

class _PortfolioCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PortfolioCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

