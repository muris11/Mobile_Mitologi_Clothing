import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeTestimonialsSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeTestimonialsSection({super.key, required this.viewModel});

  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosMuted = Color(0xFFF1F5F9);
  static const Color _iosSubtext = Color(0xFF64748B);
  static const Color _iosGold = Color(0xFFD8A73C);
  static const Color _iosNavy = Color(0xFF1E2A44);

  @override
  Widget build(BuildContext context) {
    final testimonials = viewModel.testimonials;
    if (testimonials.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderInline(
            context,
            title: 'Testimoni',
            subtitle: 'Cerita dan pengalaman pelanggan yang sudah mempercayakan produksinya kepada kami',
            onSeeAll: () {},
          ),
          SizedBox(
            height: 244,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                final testimonial = testimonials[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _iosSurface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _iosBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                            5,
                            (i) => Icon(
                                  i < testimonial.rating.round()
                                      ? PhosphorIconsFill.star
                                      : PhosphorIconsRegular.star,
                                  size: 14,
                                  color: i < testimonial.rating.round()
                                      ? _iosGold
                                      : _iosBorder,
                                )),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          '"${testimonial.content}"',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _iosText,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Gap(12),
                      const Divider(height: 1),
                      const Gap(12),
                      Row(
                        children: [
                          if (testimonial.avatarUrl != null &&
                              testimonial.avatarUrl!.isNotEmpty)
                            ClipOval(
                              child: AppImage(
                                imageUrl: ApiConfig.buildImageUrl(
                                    testimonial.avatarUrl!),
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: _iosNavy,
                              child: Text(
                                testimonial.name.isNotEmpty
                                    ? testimonial.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  testimonial.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: _iosText,
                                  ),
                                ),
                                Text(
                                  testimonial.role,
                                  style: const TextStyle(
                                    color: _iosSubtext,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
