import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';
import 'package:mitologi_clothing_mobile/widgets/common/premium_back_button.dart';
import 'package:mitologi_clothing_mobile/widgets/common/shimmer_image.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';
import 'package:provider/provider.dart';

import 'content_provider.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final String slug;

  const PortfolioDetailScreen({super.key, required this.slug});

  @override
  State<PortfolioDetailScreen> createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ContentProvider>();
      if (provider.portfolios.isEmpty) {
        provider.loadPortfolios();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<PortfolioItem?>(
        future: context.read<ContentProvider>().getPortfolioDetail(widget.slug),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PortfolioDetailSkeleton();
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: ErrorState(
                message: 'Gagal memuat detail portfolio.',
                onRetry: () {
                  setState(() {});
                },
              ),
            );
          }

          final portfolio = snapshot.data!;
          final others = context
              .watch<ContentProvider>()
              .portfolios
              .where((p) => p.slug != portfolio.slug)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                automaticallyImplyLeading: false,
                leadingWidth: 64,
                leading: PremiumBackButtonOnDark(onPressed: () => context.pop()),
                flexibleSpace: FlexibleSpaceBar(
                  background: portfolio.imageUrl != null &&
                          portfolio.imageUrl!.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ShimmerImage(
                              imageUrl:
                                  ApiConfig.buildImageUrl(portfolio.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.background
                                        .withValues(alpha: 0.9),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ColoredBox(color: AppColors.surfaceContainerHighest),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (portfolio.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            portfolio.category!.toUpperCase(),
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        portfolio.title,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (portfolio.description != null &&
                          portfolio.description!.isNotEmpty)
                        _buildDescription(portfolio.description!),
                    ],
                  ),
                ),
              ),
              if (others.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildOtherPortfoliosHeader(context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 24, bottom: 40),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: others.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final other = others[index];
                          return _buildOtherCard(context, other);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDescription(String raw) {
    final clean = _stripHtml(raw);
    return Text(
      clean,
      style: AppTextStyles.plusJakartaSans(
        fontSize: 15,
        height: 1.7,
        color: AppColors.onBackground,
      ),
    );
  }

  Widget _buildOtherPortfoliosHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Portofolio Lainnya',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherCard(BuildContext context, PortfolioItem item) {
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
      onTap: () {
        context.pushReplacement('/portfolio/${item.slug}');
      },
      child: Container(
        width: 210,
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
          children: [
            ShimmerImage(
              imageUrl: ApiConfig.buildImageUrl(item.imageUrl ?? ''),
              fit: BoxFit.cover,
              width: 210,
              height: 290,
            ),
            Positioned.fill(
              child: DecoratedBox(
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
                      fontSize: 14,
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
                        fontSize: 10,
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

  String _stripHtml(String html) {
    final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), '');
    final withoutEntities = withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return withoutEntities.trim();
  }
}
