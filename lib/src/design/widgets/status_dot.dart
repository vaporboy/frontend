import 'dart:math' as math;

import 'package:flutter/material.dart';

enum StatusDotState { pending, running, done, failed }

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.state, this.size = 12});

  final StatusDotState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (Color fill, Color border) = switch (state) {
      StatusDotState.pending => (cs.surface, cs.outline),
      StatusDotState.running => (cs.surface, cs.primary),
      StatusDotState.done => (cs.primary, cs.primary),
      StatusDotState.failed => (cs.error, cs.error),
    };

    if (state == StatusDotState.pending) {
      return CustomPaint(
        size: Size.square(size),
        painter: _DashedRingPainter(color: border, fill: fill),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: border, width: 2),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter({required this.color, required this.fill});

  final Color color;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashCount = 8;
    const sweep = math.pi * 2 / dashCount;
    final rect = Rect.fromCircle(center: center, radius: radius - 1);
    for (var i = 0; i < dashCount; i++) {
      final start = i * sweep;
      canvas.drawArc(rect, start, sweep * 0.55, false, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) =>
      old.color != color || old.fill != fill;
}
