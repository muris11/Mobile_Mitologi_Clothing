import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool showBorder;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppBorderRadius.lg,
    this.showBorder = false,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: AppColors.outlineVariant) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: memCacheWidth ?? 800, // Default to 800px width to prevent OOM
          memCacheHeight: memCacheHeight,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: AppColors.surfaceContainerHigh,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            color: AppColors.surfaceContainerLow,
            child: const Icon(Icons.broken_image_outlined,
                color: AppColors.outline),
          ),
        ),
      ),
    );
  }
}
