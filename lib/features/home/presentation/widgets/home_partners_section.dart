import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/core/widgets/app_image.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';

class HomePartnersSection extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomePartnersSection({super.key, required this.viewModel});

  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosSubtext = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final partners = viewModel.partners;
    if (partners.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
            child: Text(
              'DIPERCAYA OLEH',
              style: TextStyle(
                color: _iosSubtext,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: partners.length,
              itemBuilder: (context, index) {
                final partner = partners[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _iosSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _iosBorder),
                    ),
                    child: Opacity(
                      opacity: 0.72,
                      child: AppImage(
                        imageUrl: ApiConfig.buildImageUrl(partner.logo),
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
