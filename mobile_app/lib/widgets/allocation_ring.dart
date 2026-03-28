import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../models/dashboard_payload.dart';

class AllocationRing extends StatelessWidget {
  const AllocationRing({
    super.key,
    required this.segments,
    required this.centerLabel,
    required this.centerSupportLabel,
    this.size = 168,
  });

  final List<CategorySnapshot> segments;
  final String centerLabel;
  final String centerSupportLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: Size.square(size),
            painter: _AllocationRingPainter(segments),
          ),
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF05070A),
              border: Border.all(color: AppPalette.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    centerLabel,
                    textAlign: TextAlign.center,
                    style: AppTheme.hudStyle(size: 15),
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    centerSupportLabel,
                    textAlign: TextAlign.center,
                    style: AppTheme.tacticalLabel(size: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationRingPainter extends CustomPainter {
  _AllocationRingPainter(this.segments);

  final List<CategorySnapshot> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.13;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppPalette.border.withValues(alpha: 0.45);

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    if (segments.isEmpty) {
      return;
    }

    final totalShare = segments.fold<double>(
      0,
      (total, segment) => total + clampUnit(segment.shareRaw),
    );
    final effectiveTotal = totalShare <= 0 ? 1 : totalShare;
    const gap = 0.08;
    final availableSweep = math.max(
      0.0,
      (math.pi * 2) - (gap * segments.length),
    );
    var startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweep =
          availableSweep * (clampUnit(segment.shareRaw) / effectiveTotal);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = colorFromHex(segment.colorHex);

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _AllocationRingPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
