import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePrintingMethodsSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomePrintingMethodsSection({super.key, required this.viewModel});

  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);
  static const Color _iosSubtext = Color(0xFF64748B);
  static const Color _iosGold = Color(0xFFD8A73C);
  static const Color _iosNavy = Color(0xFF1E2A44);

  @override
  Widget build(BuildContext context) {
    final methods = viewModel.printingMethods;
    if (methods.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(width: 32, height: 2, color: _iosGold),
                  const Gap(10),
                  const Text('TEKNIK SABLON',
                      style: TextStyle(
                          color: _iosGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2)),
                ]),
                const Gap(12),
                const Text(
                  'Pilih Sesuai Kebutuhan Anda',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _iosText,
                  ),
                ),
                const Gap(8),
                const Text(
                  'Berbagai teknik printing berkualitas tinggi, dari sablon manual legendaris hingga digital modern.',
                  style: TextStyle(
                    color: _iosSubtext,
                    fontSize: 13,
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final method = methods[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _iosSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _iosBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (method.image.isNotEmpty)
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppImage(
                                imageUrl: ApiConfig.buildImageUrl(method.image),
                                fit: BoxFit.cover,
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      _iosNavy.withValues(alpha: 0.9),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    if (method.priceRange.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: Colors.white38),
                                        ),
                                        child: Text(method.priceRange,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (method.image.isEmpty) ...[
                              Text(method.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900)),
                              if (method.priceRange.isNotEmpty) ...[
                                const Gap(4),
                                Text(method.priceRange,
                                     style: const TextStyle(
                                        color: _iosGold,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ],
                              const Gap(8),
                            ],
                             Text(method.description,
                                 style: const TextStyle(
                                     color: _iosSubtext,
                                     fontSize: 13,
                                     height: 1.5)),
                             if (method.pros.isNotEmpty) ...[
                               const Gap(12),
                               const Text('Keunggulan',
                                    style: TextStyle(
                                        color: _iosGold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1)),
                               const Gap(8),
                               ...method.pros.map((pro) => Padding(
                                     padding: const EdgeInsets.only(bottom: 6),
                                     child: Row(
                                       crossAxisAlignment:
                                           CrossAxisAlignment.start,
                                       children: [
                                        const Icon(PhosphorIconsRegular.checkCircle,
                                             size: 14, color: _iosNavy),
                                         const Gap(8),
                                         Expanded(
                                           child: Text(pro,
                                               style: const TextStyle(
                                                   fontSize: 13,
                                                   fontWeight: FontWeight.w500)),
                                         ),
                                       ],
                                     ),
                                   )),
                             ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: methods.length,
            ),
          ),
        ),
      ],
    );
  }
}
