import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShimmerImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  final int? memCacheWidth;
  final int? memCacheHeight;

  const ShimmerImage({
    super.key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final widget = (imageUrl == null || imageUrl!.isEmpty)
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: fit,
            width: width,
            height: height,
            memCacheWidth: memCacheWidth ?? 800,
            memCacheHeight: memCacheHeight,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _fallback(),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: widget);
    }
    return widget;
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      );
}
