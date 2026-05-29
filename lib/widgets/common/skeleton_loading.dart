import 'package:flutter/material.dart';

import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/utils/responsive_utils.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enabled;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  @override
  State<Shimmer> createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Positioned.fill(
              child: IgnorePointer(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value + 1, 0),
                      colors: const [
                        Colors.transparent,
                                        Color(0x40FFFFFF),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcOver,
                  child: Container(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
      child: Container(
        color: AppColors.surfaceContainerLow,
        child: widget.child,
      ),
    );
  }
}

class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({
    super.key,
    this.size = 48,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppShadows.cardSoft],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonBlock(width: 80, height: 12),
                    const SkeletonBlock(height: 14),
                    const SkeletonBlock(width: 60, height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SkeletonBlock(width: 70, height: 16, borderRadius: 8),
                        const SkeletonCircle(size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => ProductCardSkeleton(
        key: ValueKey('skeleton_$index'),
      ),
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  final double height;
  final bool showAvatar;

  const ListItemSkeleton({
    super.key,
    this.height = 60,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            if (showAvatar) ...[
              const SkeletonCircle(size: 48),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBlock(height: 14),
                  const SizedBox(height: 8),
                  SkeletonBlock(
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeroSkeleton extends StatelessWidget {
  const HeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SkeletonBlock(height: 400, borderRadius: 32),
      ),
    );
  }
}

class CategoriesSkeleton extends StatelessWidget {
  const CategoriesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => const Column(
            children: [
              SkeletonCircle(size: 64),
              SizedBox(height: 8),
              SkeletonBlock(width: 50, height: 10, borderRadius: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(height: 400, borderRadius: 0),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBlock(width: 100, height: 20, borderRadius: 10),
                const SizedBox(height: 16),
                const SkeletonBlock(height: 28, borderRadius: 14),
                const SizedBox(height: 8),
                SkeletonBlock(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  height: 28,
                  borderRadius: 14,
                ),
                const SizedBox(height: 24),
                const SkeletonBlock(width: 150, height: 24, borderRadius: 12),
                const SizedBox(height: 24),
                const SkeletonBlock(height: 100, borderRadius: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemSkeleton extends StatelessWidget {
  const CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              SkeletonBlock(width: 96, height: 128, borderRadius: 12),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(height: 18, borderRadius: 9),
                    SizedBox(height: 8),
                    SkeletonBlock(width: 120, height: 14, borderRadius: 7),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBlock(width: 80, height: 16, borderRadius: 8),
                        SkeletonBlock(width: 80, height: 36, borderRadius: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CartListSkeleton extends StatelessWidget {
  final int itemCount;

  const CartListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBlock(width: 80, height: 11, borderRadius: 6),
                  const SizedBox(height: 8),
                  const SkeletonBlock(width: 200, height: 28, borderRadius: 14),
                  const SizedBox(height: 12),
                  const SkeletonBlock(width: 48, height: 2, borderRadius: 1),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const CartItemSkeleton(),
              childCount: itemCount,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(width: 180, height: 20, borderRadius: 10),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBlock(width: 120, height: 14, borderRadius: 7),
                        SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBlock(width: 120, height: 14, borderRadius: 7),
                        SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class WishlistGridSkeleton extends StatelessWidget {
  final int itemCount;

  const WishlistGridSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveConfig.getGridColumnCount(context),
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const SkeletonBlock(height: 16, borderRadius: 8),
              const SizedBox(height: 8),
              const SkeletonBlock(width: 80, height: 14, borderRadius: 7),
            ],
          ),
        ),
        childCount: itemCount,
      ),
    );
  }
}

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBlock(width: 100, height: 14, borderRadius: 7),
                SkeletonBlock(width: 80, height: 24, borderRadius: 12),
              ],
            ),
            SizedBox(height: 12),
            SkeletonBlock(height: 1, borderRadius: 0),
            SizedBox(height: 12),
            Row(
              children: [
                SkeletonBlock(width: 48, height: 48, borderRadius: 8),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(height: 14, borderRadius: 7),
                      SizedBox(height: 8),
                      SkeletonBlock(width: 120, height: 12, borderRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBlock(width: 80, height: 12, borderRadius: 6),
                SkeletonBlock(width: 100, height: 16, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderListSkeleton extends StatelessWidget {
  final int itemCount;

  const OrderListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const OrderCardSkeleton(),
      ),
    );
  }
}

class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          SkeletonBlock(width: 140, height: 12, borderRadius: 6),
          const SizedBox(height: 8),
          SkeletonBlock(width: 200, height: 26, borderRadius: 13),
          const SizedBox(height: 12),
          SkeletonBlock(width: 100, height: 28, borderRadius: 14),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                    SkeletonBlock(width: 90, height: 14, borderRadius: 7),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBlock(width: 60, height: 14, borderRadius: 7),
                    SkeletonBlock(width: 110, height: 14, borderRadius: 7),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBlock(width: 70, height: 14, borderRadius: 7),
                    SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBlock(width: 90, height: 16, borderRadius: 8),
                    SkeletonBlock(width: 100, height: 16, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 120, height: 16, borderRadius: 8),
                SizedBox(height: 16),
                Row(
                  children: [
                    SkeletonBlock(width: 64, height: 64, borderRadius: 12),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBlock(height: 14, borderRadius: 7),
                          SizedBox(height: 6),
                          SkeletonBlock(width: 100, height: 12, borderRadius: 6),
                          SizedBox(height: 6),
                          SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 100, height: 16, borderRadius: 8),
                SizedBox(height: 12),
                SkeletonBlock(width: 160, height: 12, borderRadius: 6),
                SizedBox(height: 6),
                SkeletonBlock(width: 140, height: 12, borderRadius: 6),
                SizedBox(height: 6),
                SkeletonBlock(width: 180, height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SkeletonCircle(size: 72),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonBlock(width: 150, height: 20, borderRadius: 10),
                          const SizedBox(height: 8),
                          const SkeletonBlock(width: 200, height: 14, borderRadius: 7),
                          const SizedBox(height: 8),
                          const SkeletonBlock(width: 100, height: 14, borderRadius: 7),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (_) => const Column(
                    children: [
                      SkeletonCircle(size: 56),
                      SizedBox(height: 8),
                      SkeletonBlock(width: 50, height: 10, borderRadius: 5),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBlock(width: 120, height: 18, borderRadius: 9),
                    const SizedBox(height: 16),
                    ...List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SkeletonBlock(width: 80, height: 12, borderRadius: 6),
                            SizedBox(width: 12),
                            Expanded(child: SkeletonBlock(height: 12, borderRadius: 6)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SkeletonCircle(size: 20),
                    SizedBox(width: 10),
                    SkeletonBlock(width: 120, height: 16, borderRadius: 8),
                  ],
                ),
                SkeletonBlock(width: 60, height: 24, borderRadius: 12),
              ],
            ),
            SizedBox(height: 12),
            SkeletonBlock(height: 14, borderRadius: 7),
            SizedBox(height: 6),
            SkeletonBlock(width: 250, height: 14, borderRadius: 7),
            SizedBox(height: 6),
            SkeletonBlock(width: 180, height: 14, borderRadius: 7),
            SizedBox(height: 12),
            Row(
              children: [
                SkeletonBlock(width: 60, height: 28, borderRadius: 14),
                Spacer(),
                SkeletonBlock(width: 60, height: 28, borderRadius: 14),
                SizedBox(width: 12),
                SkeletonBlock(width: 60, height: 28, borderRadius: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddressListSkeleton extends StatelessWidget {
  final int itemCount;

  const AddressListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const AddressCardSkeleton(),
      ),
    );
  }
}

class CheckoutSkeleton extends StatelessWidget {
  const CheckoutSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 100, height: 28, borderRadius: 14),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonCircle(size: 20),
                      SizedBox(width: 10),
                      SkeletonBlock(width: 100, height: 16, borderRadius: 8),
                    ],
                  ),
                  SizedBox(height: 12),
                  SkeletonBlock(height: 13, borderRadius: 6),
                  SizedBox(height: 6),
                  SkeletonBlock(width: 220, height: 13, borderRadius: 6),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 140, height: 16, borderRadius: 8),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SkeletonBlock(width: 64, height: 64, borderRadius: 12),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBlock(height: 14, borderRadius: 7),
                            SizedBox(height: 6),
                            SkeletonBlock(width: 100, height: 12, borderRadius: 6),
                            SizedBox(height: 6),
                            SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonBlock(width: 64, height: 64, borderRadius: 12),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBlock(height: 14, borderRadius: 7),
                            SizedBox(height: 6),
                            SkeletonBlock(width: 100, height: 12, borderRadius: 6),
                            SizedBox(height: 6),
                            SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 120, height: 16, borderRadius: 8),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBlock(width: 100, height: 14, borderRadius: 7),
                      SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBlock(width: 120, height: 14, borderRadius: 7),
                      SkeletonBlock(width: 90, height: 14, borderRadius: 7),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                      SkeletonBlock(width: 100, height: 14, borderRadius: 7),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(height: 1),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBlock(width: 60, height: 16, borderRadius: 8),
                      SkeletonBlock(width: 100, height: 18, borderRadius: 9),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewSkeleton extends StatelessWidget {
  const ReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SkeletonBlock(width: 100, height: 14, borderRadius: 7),
                      const SkeletonBlock(width: 60, height: 12, borderRadius: 6),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonBlock(width: 120, height: 12, borderRadius: 6),
                  const SizedBox(height: 8),
                  const SkeletonBlock(height: 13, borderRadius: 6),
                  const SizedBox(height: 4),
                  const SkeletonBlock(width: 200, height: 13, borderRadius: 6),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SkeletonBlock(width: 72, height: 72, borderRadius: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonCircle(size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SkeletonBlock(height: 14, borderRadius: 7),
                      ),
                      SizedBox(width: 16),
                      SkeletonBlock(width: 50, height: 10, borderRadius: 5),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const SkeletonBlock(width: 220, height: 12, borderRadius: 6),
                  const SizedBox(height: 6),
                  const SkeletonBlock(width: 160, height: 12, borderRadius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessageSkeleton extends StatelessWidget {
  final bool isOutgoing;

  const ChatMessageSkeleton({super.key, this.isOutgoing = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOutgoing) ...[
              const SkeletonCircle(size: 36),
              const SizedBox(width: 10),
            ],
            Column(
              crossAxisAlignment: isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(
                      isOutgoing ? 18 : 18,
                    ).copyWith(
                      bottomRight: isOutgoing ? const Radius.circular(4) : null,
                      bottomLeft: !isOutgoing ? const Radius.circular(4) : null,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(width: 160, height: 13, borderRadius: 6),
                      SizedBox(height: 4),
                      SkeletonBlock(width: 80, height: 13, borderRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const SkeletonBlock(width: 40, height: 8, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBlock(width: 100, height: 12, borderRadius: 6),
                          SizedBox(height: 6),
                          SkeletonBlock(width: 160, height: 20, borderRadius: 10),
                        ],
                      ),
                      Row(
                        children: [
                          const SkeletonCircle(size: 40),
                          const SizedBox(width: 12),
                          SkeletonBlock(width: 60, height: 32, borderRadius: 16),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SkeletonBlock(height: 180, borderRadius: 24),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBlock(width: 120, height: 18, borderRadius: 9),
                      SkeletonBlock(width: 60, height: 14, borderRadius: 7),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: List.generate(
                        4,
                        (_) => const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              SkeletonCircle(size: 56),
                              SizedBox(height: 8),
                              SkeletonBlock(width: 48, height: 10, borderRadius: 5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBlock(width: 140, height: 18, borderRadius: 9),
                      SkeletonBlock(width: 60, height: 14, borderRadius: 7),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: Row(
                      children: List.generate(
                        2,
                        (_) => Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              const SkeletonBlock(height: 14, borderRadius: 7),
                              const SizedBox(height: 6),
                              const SkeletonBlock(width: 80, height: 14, borderRadius: 7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
