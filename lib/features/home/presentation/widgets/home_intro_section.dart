import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeIntroSection extends StatelessWidget {
  const HomeIntroSection({super.key});

  static const Color _iosGold = Color(0xFFD8A73C);
  static const Color _iosText = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: _iosGold,
                ),
                const Gap(12),
                Text(
                  'MITOLOGI PILIHAN',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _iosGold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Text(
              'Vendor Konveksi Terpercaya',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: _iosText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
