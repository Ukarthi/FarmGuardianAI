import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class DroneFlightPath extends StatelessWidget {
  final String status; // launching, active, scanning, completed
  final String targetZone; // Zone A, B, C, D
  final double progress; // 0.0 to 1.0

  const DroneFlightPath({
    Key? key,
    required this.status,
    required this.targetZone,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Grid & Path Painting
          Positioned.fill(
            child: CustomPaint(
              painter: FlightPainter(
                status: status,
                targetZone: targetZone,
                progress: progress,
              ),
            ),
          ),
          
          // HUD tags
          Positioned(
            top: 8,
            left: 10,
            child: Text(
              '🛰️ GPS FLIGHT MAP',
              style: AppStyles.monoStyle.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 10,
            child: Text(
              'BATTERY: ${(100 - (progress * 30)).toInt()}%',
              style: AppStyles.monoStyle.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlightPainter extends CustomPainter {
  final String status;
  final String targetZone;
  final double progress;

  FlightPainter({
    required this.status,
    required this.targetZone,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw boundary line
    paint.color = Colors.white.withOpacity(0.06);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Grid quadrants dividing farm into A, B, C, D
    paint.color = Colors.white.withOpacity(0.04);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Label quadrants
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawZoneLabel(String text, Offset offset) {
      textPainter.text = TextSpan(
        text: text,
        style: AppStyles.monoStyle.copyWith(color: Colors.white.withOpacity(0.2), fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }

    drawZoneLabel('ZONE A\n(Lettuce)', const Offset(15, 15));
    drawZoneLabel('ZONE B\n(Orchard)', Offset(size.width - 90, 15));
    drawZoneLabel('ZONE C\n(Vineyard)', Offset(15, size.height - 45));
    drawZoneLabel('ZONE D\n(Wheat)', Offset(size.width - 90, size.height - 45));

    // Draw Dock station in the center
    final dockPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, dockPaint);
    
    final dockLine = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 12, dockLine);

    // Coordinate points for each target quadrant center
    Offset targetOffset;
    switch (targetZone) {
      case 'Zone A':
        targetOffset = Offset(size.width * 0.25, size.height * 0.25);
        break;
      case 'Zone B':
        targetOffset = Offset(size.width * 0.75, size.height * 0.25);
        break;
      case 'Zone C':
        targetOffset = Offset(size.width * 0.25, size.height * 0.75);
        break;
      case 'Zone D':
      default:
        targetOffset = Offset(size.width * 0.75, size.height * 0.75);
        break;
    }

    // Draw flight trajectory path
    final trajectoryPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    // Draw line from Dock center to Target
    canvas.drawLine(center, targetOffset, trajectoryPaint);

    // Calculate dynamic Drone Position along path
    Offset dronePos = center;
    if (progress < 0.3) {
      // Launching / climbing: interpolate from dock to target
      final t = progress / 0.3;
      dronePos = Offset.lerp(center, targetOffset, t)!;
    } else if (progress >= 0.3 && progress < 0.8) {
      // Active flight sweep / scanning in target zone quadrant: orbit target
      dronePos = targetOffset;
      final angle = (progress - 0.3) / 0.5 * 2 * pi;
      dronePos = Offset(
        targetOffset.dx + 25 * cos(angle),
        targetOffset.dy + 15 * sin(angle),
      );

      // Draw flight scan circle overlay
      if (status == 'scanning') {
        final scanOverlay = Paint()
          ..color = AppColors.secondary.withOpacity(0.12)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(targetOffset, 45, scanOverlay);

        final scanBorder = Paint()
          ..color = AppColors.secondary.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(targetOffset, 45, scanBorder);
      }
    } else {
      // Returning: interpolate from target to dock
      final t = (progress - 0.8) / 0.2;
      dronePos = Offset.lerp(targetOffset, center, t)!;
    }

    // Draw target marker
    final targetPaint = Paint()
      ..color = AppColors.danger.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(targetOffset, 15, targetPaint);
    
    final targetCross = Paint()
      ..color = AppColors.danger
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(targetOffset, 6, targetCross);

    // Draw Drone Position (glowing cyan circle)
    final droneGlow = Paint()
      ..color = AppColors.secondary.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dronePos, 9, droneGlow);

    final droneCore = Paint()
      ..color = AppColors.textBright
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dronePos, 4, droneCore);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
