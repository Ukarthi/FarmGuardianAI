import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class FarmHealthDashboardScreen extends StatefulWidget {
  const FarmHealthDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FarmHealthDashboardScreen> createState() => _FarmHealthDashboardScreenState();
}

class _FarmHealthDashboardScreenState extends State<FarmHealthDashboardScreen> {
  final _state = FarmState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  // Calculate dynamic health score based on anomalies
  double _calculateHealthScore() {
    double score = 96.0;
    for (final s in _state.sensors) {
      if (s.anomalies.isNotEmpty) {
        score -= (15.0 * s.anomalies.length);
      }
    }
    return max(30.0, score);
  }

  @override
  Widget build(BuildContext context) {
    final healthScore = _calculateHealthScore();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Farm Health Indices', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Real-time agronomy diagnostics & vegetation vigor audit.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          // Vigor Radial Gauge & General Score
          CustomCard(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: RadialGaugePainter(score: healthScore),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${healthScore.toInt()}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBright,
                              ),
                            ),
                            Text(
                              healthScore > 85 ? 'OPTIMAL' : healthScore > 65 ? 'STRESSED' : 'CRITICAL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: healthScore > 85
                                    ? AppColors.primary
                                    : healthScore > 65
                                        ? AppColors.warning
                                        : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vegetation Vigor & Chlorophyll Index',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Calculated globally across active IoT nodes and multi-spectral satellite overlays.',
                  textAlign: TextAlign.center,
                  style: AppStyles.subtitleStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Vigor details grid
          Text('Multispectral Vigor Indices', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildIndexCard('NDVI Rating', healthScore > 85 ? '0.78' : healthScore > 65 ? '0.62' : '0.45', 'Vigor Canopy Index', AppColors.primary),
              _buildIndexCard('Evapotranspiration', healthScore > 85 ? '89%' : healthScore > 65 ? '72%' : '54%', 'Leaf moisture sweat rate', AppColors.secondary),
              _buildIndexCard('Chlorophyll Density', healthScore > 85 ? '94%' : healthScore > 65 ? '81%' : '65%', 'Chloroplast density levels', AppColors.primary),
              _buildIndexCard('Canopy Turgor', healthScore > 85 ? '92%' : healthScore > 65 ? '70%' : '48%', 'Cellular water pressure', AppColors.warning),
            ],
          ),
          const SizedBox(height: 20),

          // Health status by Crop Field
          Text('Crop Health Status Grid', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _state.sensors.length,
            itemBuilder: (context, idx) {
              final sensor = _state.sensors[idx];
              final anomaliesCount = sensor.anomalies.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CustomCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            anomaliesCount > 0 ? Icons.error_outline : Icons.check_circle_outline,
                            color: anomaliesCount > 0 ? AppColors.danger : AppColors.primary,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sensor.cropName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(sensor.zone, style: AppStyles.subtitleStyle.copyWith(fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: anomaliesCount > 0 ? AppColors.danger.withOpacity(0.12) : AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          anomaliesCount > 0 ? '${anomaliesCount.toString()} Stress anomalies' : 'Optimal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: anomaliesCount > 0 ? AppColors.danger : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIndexCard(String label, String value, String description, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppStyles.subtitleStyle.copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(description, style: AppStyles.monoStyle.copyWith(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// Radial Speedometer Gauge painter widget
class RadialGaugePainter extends CustomPainter {
  final double score;

  RadialGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final progressPaint = Paint()
      ..color = score > 85
          ? AppColors.primary
          : score > 65
              ? AppColors.warning
              : AppColors.danger
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    // Draw background arc (from 140 degrees to 400 degrees)
    const startAngle = 3 * pi / 4;
    const sweepAngle = 3 * pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Draw active progress score arc
    final activeSweepAngle = sweepAngle * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      activeSweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
