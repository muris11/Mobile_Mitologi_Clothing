import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';

class TeamMembersSection extends StatelessWidget {
  const TeamMembersSection({super.key});

  final List<Map<String, dynamic>> _members = const [
    {
      'initials': 'AR',
      'name': 'Arya Wijaya',
      'role': 'Founder & Creative Director',
      'color': Color(0xFF735C00),
    },
    {
      'initials': 'DS',
      'name': 'Dewi Sartika',
      'role': 'Head of Design',
      'color': Color(0xFF001F3F),
    },
    {
      'initials': 'RB',
      'name': 'Rizky Bahar',
      'role': 'Operations Lead',
      'color': Color(0xFF5B3A00),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 32),
            Text(
              'Tim di Balik Layar',
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Perkenalkan tim yang mewujudkan setiap koleksi dengan dedikasi dan kreativitas.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: _members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                final isLast = index == _members.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMemberCard(
                          initials: member['initials'] as String,
                          name: member['name'] as String,
                          role: member['role'] as String,
                          color: member['color'] as Color,
                        ),
                      ),
                      if (!isLast) const SizedBox(width: 12),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required String initials,
    required String name,
    required String role,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.cardSoft,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        boxShadow: [
          AppShadows.cardSoft,
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
