import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : AppColors.primary,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: widget.isOutlined
                ? Border.all(color: AppColors.outlineVariant)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isOutlined
                          ? AppColors.primary
                          : AppColors.onPrimary,
                    ),
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.isOutlined
                        ? AppColors.primary
                        : AppColors.onPrimary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isOutlined
                        ? AppColors.primary
                        : AppColors.onPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: widget.backgroundColor != null
              ? BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color ?? AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onToggle;
  final double size;
  final Color activeColor;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onToggle,
    this.size = 24,
    this.activeColor = const Color(0xFFE53935),
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.8),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.4),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.15),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.15, end: 0.15),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.15, end: 0.0),
        weight: 25,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isFavorite) {
      // Only burst when adding to favorites
      _generateParticles();
    }
    _controller.forward(from: 0);
    widget.onToggle?.call();
  }

  void _generateParticles() {
    _particles.clear();
    const count = 8;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * 3.14159;
      _particles.add(_Particle(
        angle: angle,
        distance: 20 + (i % 3) * 10,
        size: 3 + (i % 2) * 2,
        color: widget.activeColor.withValues(
          alpha: 0.6 + (i % 3) * 0.15,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Particles burst
                  if (!widget.isFavorite)
                    ..._particles.map((particle) {
                      final progress = _controller.value;
                      final distance = particle.distance * progress;
                      final dx = distance * particle.cos;
                      final dy = distance * particle.sin;
                      final opacity = 1.0 - progress;
                      final particleSize = particle.size * (1 - progress * 0.5);

                      return Positioned(
                        left: widget.size / 2 + dx - particleSize / 2,
                        top: widget.size / 2 + dy - particleSize / 2,
                        child: Opacity(
                          opacity: opacity.clamp(0, 1),
                          child: Container(
                            width: particleSize.clamp(1, 10),
                            height: particleSize.clamp(1, 10),
                            decoration: BoxDecoration(
                              color: particle.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  // Heart icon with glow when active
                  Container(
                    decoration: widget.isFavorite
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.activeColor.withValues(
                                  alpha: 0.3 * _controller.value,
                                ),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          )
                        : null,
                    child: Icon(
                      widget.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      size: widget.size,
                      color: widget.isFavorite
                          ? widget.activeColor
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });

  double get cos => _cosLookup();
  double get sin => _sinLookup();

  double _cosLookup() {
    // Small lookup for common angles to avoid repeated trig
    const values = [1.0, 0.707, 0.0, -0.707, -1.0, -0.707, 0.0, 0.707];
    final idx = ((angle / (3.14159 / 4)).round()) % 8;
    return values[idx];
  }

  double _sinLookup() {
    const values = [0.0, 0.707, 1.0, 0.707, 0.0, -0.707, -1.0, -0.707];
    final idx = ((angle / (3.14159 / 4)).round()) % 8;
    return values[idx];
  }
}
