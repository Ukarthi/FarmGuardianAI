import 'package:flutter/material.dart';
import '../core/constants.dart';

class CropCameraFeed extends StatefulWidget {
  final String condition;
  final String zone;

  const CropCameraFeed({
    Key? key,
    required this.condition,
    required this.zone,
  }) : super(key: key);

  @override
  State<CropCameraFeed> createState() => _CropCameraFeedState();
}

class _CropCameraFeedState extends State<CropCameraFeed>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(
          color: widget.condition == 'drought'
              ? AppColors.warning
              : widget.condition == 'healthy'
                  ? AppColors.primary
                  : AppColors.danger,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // The Custom Canvas Paint
          Positioned.fill(
            child: CustomPaint(
              painter: CropPainter(condition: widget.condition),
            ),
          ),

          // HUD details
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              '🎥 D-CAM MULTISPECTRAL [LIVE]',
              style: AppStyles.monoStyle.copyWith(
                color: widget.condition == 'drought'
                    ? AppColors.warning
                    : widget.condition == 'healthy'
                        ? AppColors.primary
                        : AppColors.danger,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Text(
              'ZONE: ${widget.zone}',
              style: AppStyles.monoStyle.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ),

          // Moving Scan Laser Line
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: _controller.value * 210,
                left: 2,
                right: 2,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Diagnostic Tag
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'STATUS: ${widget.condition.toUpperCase()}',
                textAlign: TextAlign.center,
                style: AppStyles.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.textBright,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CropPainter extends CustomPainter {
  final String condition;

  CropPainter({required this.condition});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw grid lines
    paint.color = Colors.white.withOpacity(0.04);
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw reticle lines
    paint.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(center, 70, paint);
    canvas.drawCircle(center, 40, paint);
    canvas.drawLine(Offset(size.width / 2, 20), Offset(size.width / 2, size.height - 20), paint);
    canvas.drawLine(Offset(20, size.height / 2), Offset(size.width - 20, size.height / 2), paint);

    // Draw Crop Leaf elements based on state
    final path = Path();
    final stemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final leafPaint = Paint()..style = PaintingStyle.fill;

    if (condition == 'drought') {
      // Withered drooping stem
      stemPaint.color = const Color(0xFF8B5A2B); // Brown
      path.moveTo(size.width / 2, size.height - 40);
      path.quadraticBezierTo(
        size.width / 2 - 15,
        size.height / 2 + 10,
        size.width / 2 - 25,
        size.height / 2 - 10,
      );
      canvas.drawPath(path, stemPaint);

      // Drooping dry leaves
      leafPaint.color = const Color(0xFF9E782F); // Yellow-brown
      // Left Leaf
      final leftLeaf = Path()
        ..moveTo(size.width / 2 - 20, size.height / 2 + 10)
        ..quadraticBezierTo(size.width / 2 - 45, size.height / 2 + 15, size.width / 2 - 50, size.height / 2 + 35)
        ..quadraticBezierTo(size.width / 2 - 35, size.height / 2 + 25, size.width / 2 - 20, size.height / 2 + 10);
      canvas.drawPath(leftLeaf, leafPaint);

      // Right Leaf
      final rightLeaf = Path()
        ..moveTo(size.width / 2 - 25, size.height / 2 - 10)
        ..quadraticBezierTo(size.width / 2 - 55, size.height / 2 - 20, size.width / 2 - 60, size.height / 2)
        ..quadraticBezierTo(size.width / 2 - 40, size.height / 2 - 5, size.width / 2 - 25, size.height / 2 - 10);
      canvas.drawPath(rightLeaf, leafPaint);

    } else if (condition == 'pests') {
      // Healthy green stem
      stemPaint.color = AppColors.primary;
      path.moveTo(size.width / 2, size.height - 40);
      path.quadraticBezierTo(
        size.width / 2 + 5,
        size.height / 2 + 10,
        size.width / 2,
        size.height / 2 - 30,
      );
      canvas.drawPath(path, stemPaint);

      // Green Leaves
      leafPaint.color = const Color(0xFF047857);
      // Left Leaf
      final leftLeaf = Path()
        ..moveTo(size.width / 2 + 2, size.height / 2 + 5)
        ..quadraticBezierTo(size.width / 2 - 30, size.height / 2 - 10, size.width / 2 - 40, size.height / 2 - 30)
        ..quadraticBezierTo(size.width / 2 - 20, size.height / 2, size.width / 2 + 2, size.height / 2 + 5);
      canvas.drawPath(leftLeaf, leafPaint);

      // Bugs (Small red dots crawling on leaves)
      final bugPaint = Paint()
        ..color = AppColors.danger
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2 - 25, size.height / 2 - 18), 4, bugPaint);
      canvas.drawCircle(Offset(size.width / 2 - 32, size.height / 2 - 24), 3, bugPaint);

      // Bug legs lines
      final legPaint = Paint()
        ..color = AppColors.danger
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(size.width / 2 - 25, size.height / 2 - 18), Offset(size.width / 2 - 29, size.height / 2 - 14), legPaint);
      canvas.drawLine(Offset(size.width / 2 - 25, size.height / 2 - 18), Offset(size.width / 2 - 21, size.height / 2 - 22), legPaint);

    } else if (condition == 'disease') {
      // Green stem
      stemPaint.color = AppColors.primary;
      path.moveTo(size.width / 2, size.height - 40);
      path.quadraticBezierTo(
        size.width / 2 - 5,
        size.height / 2 + 10,
        size.width / 2,
        size.height / 2 - 30,
      );
      canvas.drawPath(path, stemPaint);

      // Green leaves
      leafPaint.color = const Color(0xFF065F46);
      final leftLeaf = Path()
        ..moveTo(size.width / 2 - 2, size.height / 2 + 5)
        ..quadraticBezierTo(size.width / 2 - 35, size.height / 2 - 5, size.width / 2 - 45, size.height / 2 - 25)
        ..quadraticBezierTo(size.width / 2 - 22, size.height / 2 + 2, size.width / 2 - 2, size.height / 2 + 5);
      canvas.drawPath(leftLeaf, leafPaint);

      final rightLeaf = Path()
        ..moveTo(size.width / 2, size.height / 2 - 10)
        ..quadraticBezierTo(size.width / 2 + 35, size.height / 2 - 20, size.width / 2 + 45, size.height / 2 - 40)
        ..quadraticBezierTo(size.width / 2 + 22, size.height / 2 - 12, size.width / 2, size.height / 2 - 10);
      canvas.drawPath(rightLeaf, leafPaint);

      // White fungal circular mildew spots
      final mildewPaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2 - 25, size.height / 2 - 10), 5, mildewPaint);
      canvas.drawCircle(Offset(size.width / 2 - 32, size.height / 2 - 16), 3, mildewPaint);
      canvas.drawCircle(Offset(size.width / 2 + 26, size.height / 2 - 24), 4, mildewPaint);
      canvas.drawCircle(Offset(size.width / 2 + 32, size.height / 2 - 30), 2.5, mildewPaint);

    } else if (condition == 'nutrient_def') {
      // Yellowish stem
      stemPaint.color = const Color(0xFF854D0E);
      path.moveTo(size.width / 2, size.height - 40);
      path.quadraticBezierTo(
        size.width / 2,
        size.height / 2 + 10,
        size.width / 2,
        size.height / 2 - 30,
      );
      canvas.drawPath(path, stemPaint);

      // Chlorotic Yellow leaves
      leafPaint.color = const Color(0xFFCA8A04); // Yellow leaf
      final leftLeaf = Path()
        ..moveTo(size.width / 2, size.height / 2 + 5)
        ..quadraticBezierTo(size.width / 2 - 35, size.height / 2 - 10, size.width / 2 - 45, size.height / 2 - 30)
        ..quadraticBezierTo(size.width / 2 - 20, size.height / 2, size.width / 2, size.height / 2 + 5);
      canvas.drawPath(leftLeaf, leafPaint);

      // Draw Green veins on top of the yellow leaf
      final veinPaint = Paint()
        ..color = const Color(0xFF15803D) // Green veins
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawLine(Offset(size.width / 2 - 10, size.height / 2 - 3), Offset(size.width / 2 - 35, size.height / 2 - 20), veinPaint);
      canvas.drawLine(Offset(size.width / 2 - 20, size.height / 2 - 9), Offset(size.width / 2 - 26, size.height / 2 - 20), veinPaint);

    } else {
      // Healthy lush crop
      stemPaint.color = AppColors.primary;
      path.moveTo(size.width / 2, size.height - 40);
      path.quadraticBezierTo(
        size.width / 2,
        size.height / 2 + 10,
        size.width / 2,
        size.height / 2 - 40,
      );
      canvas.drawPath(path, stemPaint);

      // Lush emerald green leaves
      leafPaint.color = AppColors.primary;
      final leftLeaf = Path()
        ..moveTo(size.width / 2, size.height / 2 + 10)
        ..quadraticBezierTo(size.width / 2 - 38, size.height / 2 - 10, size.width / 2 - 50, size.height / 2 - 35)
        ..quadraticBezierTo(size.width / 2 - 22, size.height / 2 + 2, size.width / 2, size.height / 2 + 10);
      canvas.drawPath(leftLeaf, leafPaint);

      final rightLeaf = Path()
        ..moveTo(size.width / 2, size.height / 2 - 10)
        ..quadraticBezierTo(size.width / 2 + 38, size.height / 2 - 30, size.width / 2 + 50, size.height / 2 - 55)
        ..quadraticBezierTo(size.width / 2 + 22, size.height / 2 - 15, size.width / 2, size.height / 2 - 10);
      canvas.drawPath(rightLeaf, leafPaint);

      // Cyan dew drops
      final dewPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2 - 30, size.height / 2 - 15), 2.5, dewPaint);
      canvas.drawCircle(Offset(size.width / 2 + 30, size.height / 2 - 32), 2.5, dewPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
