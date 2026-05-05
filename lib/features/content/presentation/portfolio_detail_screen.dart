import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';
import 'package:mitologi_clothing_mobile/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'content_provider.dart';

class PortfolioDetailScreen extends StatelessWidget {
  final String slug;

  const PortfolioDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<PortfolioItem?>(
        future: context.read<ContentProvider>().getPortfolioDetail(slug),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: ErrorState(
                message: 'Gagal memuat detail portfolio.',
                onRetry: () {
                  (context as Element).markNeedsBuild();
                },
              ),
            );
          }

          final portfolio = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: portfolio.imageUrl != null &&
                          portfolio.imageUrl!.isNotEmpty
                      ? AppImage(
                          imageUrl:
                              ApiConfig.buildImageUrl(portfolio.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : const ColoredBox(color: Color(0xFF000613)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (portfolio.category != null)
                        Text(
                          portfolio.category!.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                            letterSpacing: 2,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        portfolio.title,
                        style: GoogleFonts.notoSerif(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (portfolio.description != null)
                        Text(
                          portfolio.description!,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            height: 1.6,
                            color: AppColors.onBackground,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
