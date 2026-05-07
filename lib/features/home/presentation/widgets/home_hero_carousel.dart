import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/home/presentation/home_view_model.dart';

class HomeHeroCarousel extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeHeroCarousel({super.key, required this.viewModel});

  @override
  State<HomeHeroCarousel> createState() => _HomeHeroCarouselState();
}

class _HomeHeroCarouselState extends State<HomeHeroCarousel> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      if (widget.viewModel.banners.length <= 1) return;
      if (!_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % widget.viewModel.banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.banners.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 220));
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 240,
        child: PageView.builder(
          controller: _bannerController,
          itemCount: widget.viewModel.banners.length,
          onPageChanged: (index) {
            setState(() => _currentBannerIndex = index);
          },
          itemBuilder: (context, index) {
            final banner = widget.viewModel.banners[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surfaceContainerLow,
                image: banner.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(banner.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: banner.imageUrl.isEmpty
                  ? Center(
                      child: Text(
                        banner.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}