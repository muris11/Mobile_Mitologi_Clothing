import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/widgets/common/cart_icon_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MitologiSliverAppBar extends StatelessWidget {
  final String? pageTitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final bool pinned;
  final bool floating;
  final double? expandedHeight;
  final Widget? flexibleSpace;

  const MitologiSliverAppBar({
    super.key,
    this.pageTitle,
    this.actions,
    this.showBackButton = false,
    this.bottom,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: showBackButton ? null : 140,
      leading: showBackButton
          ? IconButton(
              icon: Icon(PhosphorIconsRegular.caretLeft, color: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Container(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MITOLOGI',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'CLOTHING',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
      centerTitle: true,
      title: pageTitle != null
          ? Text(
              pageTitle!.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            )
          : null,
      actions: actions ??
          [
            const CartIconButton(),
            const SizedBox(width: 24),
          ],
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: bottom!.preferredSize,
              child: Column(
                children: [
                  bottom!,
                  Divider(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    height: 0.5,
                    thickness: 0.5,
                  ),
                ],
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Divider(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                height: 0.5,
                thickness: 0.5,
              ),
            ),
      flexibleSpace: flexibleSpace,
    );
  }
}
