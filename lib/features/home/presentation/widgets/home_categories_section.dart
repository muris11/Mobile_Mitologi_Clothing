import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeCategoriesSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeCategoriesSection({super.key, required this.viewModel});

  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosMuted = Color(0xFFF1F5F9);
  static const Color _iosCream = Color(0xFFF8F4EC);
  static const Color _iosSubtext = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    if (viewModel.categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderInline(
            context,
            title: 'Kategori',
            subtitle: 'Pilih jenis produk sesuai kebutuhan komunitas, organisasi, atau brand kamu',
            onSeeAll: () => context.go('/products'),
          ),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final category = viewModel.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            context.push('/products?category=${category.slug}'),
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: index.isEven ? _iosMuted : _iosCream,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: _iosBorder, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: category.iconUrl != null
                                ? AppImage(
                                    imageUrl: ApiConfig.buildImageUrl(
                                        category.iconUrl!),
                                    width: 40,
                                    height: 40)
                                : const Icon(PhosphorIconsRegular.tShirt,
                                    size: 30),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _iosText,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
                  style: TextStyle(
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
              decoration: BoxDecoration(
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
