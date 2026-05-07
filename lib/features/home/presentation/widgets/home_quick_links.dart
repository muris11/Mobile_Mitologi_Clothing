import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomeQuickLinks extends StatelessWidget {
  const HomeQuickLinks({super.key});

  static const Color _iosNavy = Color(0xFF1E2A44);
  static const Color _iosSurface = Color(0xFFFFFFFF);
  static const Color _iosBorder = Color(0xFFE2E8F0);
  static const Color _iosText = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final links = [
      ('Tentang Kami', '/tentang-kami'),
      ('Kategori', '/kategori'),
      ('Layanan', '/layanan'),
      ('Portofolio', '/portfolio'),
      ('Kontak', '/kontak'),
      ('Mulai Belanja', '/products'),
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          itemBuilder: (context, index) {
            final (label, route) = links[index];
            final isPrimary = label == 'Mulai Belanja';
            return GestureDetector(
              onTap: () => context.push(route),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isPrimary ? _iosNavy : _iosSurface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: isPrimary ? _iosNavy : _iosBorder),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : _iosText,
                    fontSize: 12,
                    fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const Gap(10),
          itemCount: links.length,
        ),
      ),
    );
  }
}
