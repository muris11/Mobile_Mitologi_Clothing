import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/content/domain/models/content_models.dart';
import 'package:mitologi_clothing_mobile/utils/responsive_utils.dart';
import 'package:mitologi_clothing_mobile/widgets/common/custom_pull_to_refresh.dart';
import 'package:mitologi_clothing_mobile/widgets/common/empty_state.dart';
import 'package:mitologi_clothing_mobile/widgets/common/loading_indicator.dart';
import 'package:mitologi_clothing_mobile/widgets/common/premium_back_button.dart';
import 'package:mitologi_clothing_mobile/widgets/shared/product_card.dart';
import 'package:provider/provider.dart';

import 'content_provider.dart';

class CollectionScreen extends StatelessWidget {
  final String handle;

  const CollectionScreen({super.key, required this.handle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<CollectionDetail?>(
        future:
            context.read<ContentProvider>().getCollectionWithProducts(handle),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: AnimatedEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Gagal Memuat Koleksi',
                subtitle:
                    'Koleksi tidak ditemukan atau terjadi kendala jaringan.',
                actionLabel: 'Kembali',
                onAction: () => context.pop(),
              ),
            );
          }

          final collection = snapshot.data!;

          return CustomPullToRefresh(
            onRefresh: () async => (context as Element).markNeedsBuild(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.surface,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  leadingWidth: 64,
                  leading: PremiumBackButtonOnDark(onPressed: () => context.pop()),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      collection.title.toUpperCase(),
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            blurRadius: 10,
                            color: Colors.black45,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (collection.imageUrl != null &&
                            collection.imageUrl!.isNotEmpty)
                          AppImage(
                            imageUrl:
                                ApiConfig.buildImageUrl(collection.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        else
                          Container(color: AppColors.primary),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black26, Colors.black54],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (collection.description != null &&
                    collection.description!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Text(
                        collection.description!,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 15,
                          color: AppColors.outline,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (collection.products == null || collection.products!.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada produk dalam koleksi ini.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: ResponsiveConfig.getResponsivePadding(context)
                        .copyWith(top: 32),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            ResponsiveConfig.getGridColumnCount(context),
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = collection.products![index];
                          return ProductCard(product: product);
                        },
                        childCount: collection.products!.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
