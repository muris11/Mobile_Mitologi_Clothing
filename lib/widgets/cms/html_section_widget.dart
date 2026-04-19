import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../utils/html_parser.dart';

class HtmlSectionWidget extends StatelessWidget {
  final HtmlSection section;

  const HtmlSectionWidget({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (section.type) {
      case 'h1':
        child = Text(
          section.content,
          style: GoogleFonts.notoSerif(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        );
        break;
      case 'h2':
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.content,
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 56,
              height: 2,
              color: AppColors.outlineVariant,
            ),
          ],
        );
        break;
      case 'h3':
        child = Text(
          section.content,
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        );
        break;
      case 'p':
        child = Text(
          section.content,
          style: GoogleFonts.manrope(
            fontSize: 15,
            color: AppColors.onSurface,
            height: 1.7,
          ),
        );
        break;
      case 'list':
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < section.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        section.ordered ? '${i + 1}.' : '•',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        section.items[i],
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          color: AppColors.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
        break;
      default:
        child = Text(
          section.content,
          style: GoogleFonts.manrope(
            fontSize: 15,
            color: AppColors.onSurface,
          ),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }
}
