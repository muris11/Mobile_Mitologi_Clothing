import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final items = <_NavItem>[
      _NavItem(
          icon: PhosphorIconsRegular.house,
          activeIcon: PhosphorIconsFill.house,
          label: 'Beranda',
          route: '/'),
      _NavItem(
          icon: PhosphorIconsRegular.storefront,
          activeIcon: PhosphorIconsFill.storefront,
          label: 'Katalog',
          route: '/products'),
      _NavItem(
          icon: PhosphorIconsRegular.heart,
          activeIcon: PhosphorIconsFill.heart,
          label: 'Wishlist',
          route: '/wishlist'),
      _NavItem(
          icon: PhosphorIconsRegular.images,
          activeIcon: PhosphorIconsFill.images,
          label: 'Portfolio',
          route: '/portfolio-tab'),
      _NavItem(
          icon: PhosphorIconsRegular.user,
          activeIcon: PhosphorIconsFill.user,
          label: 'Akun',
          route: '/profile'),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
                top: BorderSide(color: AppColors.outlineVariant, width: 0.8)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: items.map((item) {
                  final isActive = item.route == '/'
                      ? location == '/'
                      : location.startsWith(item.route);
                  return Expanded(
                    child: _NavButton(item: item, isActive: isActive),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.route});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  const _NavButton({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(item.route);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.outline,
            ),
          ),
          const Gap(2),
          Text(
            item.label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
