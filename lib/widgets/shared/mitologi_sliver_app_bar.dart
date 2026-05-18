import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/widgets/glass_container.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_text_styles.dart';
import 'package:mitologi_clothing_mobile/core/utils/responsive_utils.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/widgets/cart_icon_button.dart';
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
    final titleFontSize = ResponsiveConfig.sp(context, 20);
    final brandFontSize = ResponsiveConfig.sp(context, 14);
    final subBrandFontSize = ResponsiveConfig.sp(context, 8);
    final horizontalPad = ResponsiveConfig.value(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      backgroundColor: AppColors.background.withValues(alpha: 0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: showBackButton
          ? null
          : ResponsiveConfig.value(
              context: context,
              mobile: 120.0,
              tablet: 150.0,
              desktop: 180.0,
            ),
      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(left: horizontalPad * 0.75),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                blur: 12,
                borderRadius: AppBorderRadius.circular,
                child: IconButton(
                  icon: Icon(PhosphorIconsRegular.caretLeft,
                      color: AppColors.primary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.only(left: horizontalPad, right: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MITOLOGI',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: AppColors.primary,
                          fontSize: brandFontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'CLOTHING',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: subBrandFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.4,
                          height: 1.0,
                        ).copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      centerTitle: true,
      title: pageTitle != null
          ? Text(
              pageTitle!,
              style: AppTextStyles.notoSerif(
                color: AppColors.primary,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      actions: actions ??
          [
            Padding(
              padding: EdgeInsets.only(right: horizontalPad * 0.5),
              child: const CartIconButton(),
            ),
            SizedBox(width: horizontalPad * 0.5),
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
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
                height: 0.5,
                thickness: 0.5,
              ),
            ),
      flexibleSpace: flexibleSpace,
    );
  }
}
