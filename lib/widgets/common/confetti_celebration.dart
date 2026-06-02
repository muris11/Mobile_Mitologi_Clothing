import 'dart:math';
import 'package:flutter/material.dart';

void showConfetti(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (_) => const _ConfettiOverlay(),
  );
}

class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay();

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pieces = List.generate(40, (i) => _ConfettiPiece.random(i));
    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ConfettiPainter(_pieces, _controller.value),
        );
      },
    );
  }
}

class _ConfettiPiece {
  final double startX;
  final double endX;
  final double startY;
  final double endY;
  final double size;
  final Color color;
  final double rotation;
  final double delay;

  _ConfettiPiece({
    required this.startX,
    required this.endX,
    required this.startY,
    required this.endY,
    required this.size,
    required this.color,
    required this.rotation,
    required this.delay,
  });

  factory _ConfettiPiece.random(int index) {
    final rng = Random(index * 7 + 13);
    final colors = [
      const Color(0xFFCA8A04),
      const Color(0xFFE5C463),
      const Color(0xFF0C1A2E),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
    ];
    return _ConfettiPiece(
      startX: rng.nextDouble(),
      endX: rng.nextDouble() * 0.4 - 0.2,
      startY: -0.1 - rng.nextDouble() * 0.2,
      endY: 1.0 + rng.nextDouble() * 0.3,
      size: 4 + rng.nextDouble() * 6,
      color: colors[index % colors.length],
      rotation: rng.nextDouble() * 6.28,
      delay: rng.nextDouble() * 0.5,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter(this.pieces, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final t = ((progress - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = (piece.startX + piece.endX * t) * size.width;
      final y = (piece.startY + (piece.endY - piece.startY) * t) * size.height;
      final opacity = t < 0.8 ? 1.0 : (1.0 - (t - 0.8) / 0.2);
      final rotation = piece.rotation + t * 6.28;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 0.6,
        ),
        Paint()..color = piece.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
