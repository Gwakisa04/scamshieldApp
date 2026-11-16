import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

class RiskDonut extends StatelessWidget {
  final int riskPercent;
  final int safePercent;
  final bool scam;
  final double size;
  final int? score;
  final String? caption;

  const RiskDonut({
    super.key,
    required this.riskPercent,
    required this.safePercent,
    required this.scam,
    this.size = 140,
    this.score,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final riskColor = scam ? AppColors.red : AppColors.green;
    final safeColor = scam ? AppColors.lightRed : AppColors.lightGreen;
    final centerValue = score ?? riskPercent;
    final centerColor = score != null
        ? (centerValue >= 80
            ? AppColors.green
            : centerValue >= 50
                ? AppColors.comfortOrange
                : AppColors.red)
        : riskColor;
    final subColor = dark ? AppColors.darkTextSecondary : AppColors.textSlate500;
    final trackColor = dark ? AppColors.darkDivider : AppColors.divider;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          riskPercent: riskPercent / 100,
          riskColor: riskColor,
          safeColor: scam ? safeColor.withOpacity(0.85) : Colors.transparent,
          trackColor: trackColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$centerValue%',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: centerColor,
                ),
              ),
              if (caption != null || score == null) ...[
                const SizedBox(height: 2),
                Text(
                  caption ??
                      (scam ? 'Scam risk' : 'Safe'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size * 0.085,
                    color: subColor,
                    fontWeight: FontWeight.w600,
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

class _DonutPainter extends CustomPainter {
  final double riskPercent;
  final Color riskColor;
  final Color safeColor;
  final Color trackColor;

  _DonutPainter({
    required this.riskPercent,
    required this.riskColor,
    required this.safeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.1;
    final rect = EdgeInsets.all(stroke / 2).deflateRect(Offset.zero & size);
    final startAngle = -math.pi / 2;
    final sweepFull = 2 * math.pi;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, startAngle, sweepFull, false, track);

    if (safeColor != Colors.transparent && riskPercent > 0) {
      final safe = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = safeColor;
      canvas.drawArc(
          rect, startAngle + riskPercent * sweepFull,
          (1 - riskPercent) * sweepFull, false, safe);
    }

    if (riskPercent > 0) {
      final risk = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = riskColor;
      canvas.drawArc(rect, startAngle, riskPercent * sweepFull, false, risk);
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.riskPercent != riskPercent;
}
