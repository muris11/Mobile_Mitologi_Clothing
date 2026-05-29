import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';
import 'package:mitologi_clothing_mobile/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'content_provider.dart';

class CmsPageScreen extends StatelessWidget {
  final String handle;

  const CmsPageScreen({super.key, required this.handle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<CmsPage?>(
        future: context.read<ContentProvider>().getPage(handle),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: ErrorState(
                message: 'Gagal memuat halaman.',
                onRetry: () => (context as Element).markNeedsBuild(),
              ),
            );
          }

          final page = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.surface.withValues(alpha: 0.95),
                surfaceTintColor: Colors.transparent,
                title: Text(
                  page.title.toUpperCase(),
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                centerTitle: true,
              ),
              if (page.imageUrl != null)
                SliverToBoxAdapter(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: AppImage(
                      imageUrl: ApiConfig.buildImageUrl(page.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.title,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Html(
                        data: page.body,
                        style: {
                          "body": Style(
                            fontSize: FontSize(15),
                            lineHeight: LineHeight(1.6),
                            color: AppColors.onSurface,
                            fontFamily: AppTextStyles.plusJakartaSans().fontFamily,
                          ),
                        },
                      ),
                      const SizedBox(height: 60),
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

