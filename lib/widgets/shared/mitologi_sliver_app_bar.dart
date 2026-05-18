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
  final double? scrolledOpacity;

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
    this.scrolledOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = ResponsiveConfig.sp(context, 18);
    final brandFontSize = ResponsiveConfig.sp(context, 13);
    final subBrandFontSize = ResponsiveConfig.sp(context, 7.5);
    final horizontalPad = ResponsiveConfig.value(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    final bgColor = scrolledOpacity != null
        ? AppColors.background.withValues(alpha: scrolledOpacity)
        : AppColors.background.withValues(alpha: 0.95);

    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: showBackButton
          ? null
          : ResponsiveConfig.value(
              context: context,
              mobile: 110.0,
              tablet: 140.0,
              desktop: 160.0,
            ),
      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(left: horizontalPad * 0.5),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MITOLOGI',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: AppColors.primary,
                          fontSize: brandFontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text(
                          'ID',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: subBrandFontSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.secondary,
                            height: 1.0,
                          ),
                        ),
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
              child: showBackButton
                  ? const SizedBox(width: 36)
                  : const CartIconButton(),
            ),
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
              preferredSize: const Size.fromHeight(0),
              child: const SizedBox.shrink(),
            ),
      flexibleSpace: flexibleSpace,
    );
  }
}
