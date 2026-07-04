import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class SensorMonitoringScreen extends StatefulWidget {
  const SensorMonitoringScreen({Key? key}) : super(key: key);

  @override
  State<SensorMonitoringScreen> createState() => _SensorMonitoringScreenState();
}

class _SensorMonitoringScreenState extends State<SensorMonitoringScreen> {
  final _state = FarmState();
  String _selectedZone = 'Zone A';
  String _selectedMetric = 'soilMoisture';

  final Map<String, String> _metricLabels = {
    'soilMoisture': 'Soil Moisture (%)',
    'temperature': 'Temperature (°C)',
    'ph': 'Soil pH',
    'nitrogen': 'Nitrogen (N) mg/kg',
    'phosphorus': 'Phosphorus (P) mg/kg',
    'potassium': 'Potassium (K) mg/kg'
  };

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

  List<double> _getPoints() {
    return _state.telemetryHistory.map<double>((tick) {
      final zoneData = tick[_selectedZone];
      if (zoneData == null) return 0.0;
      return (zoneData[_selectedMetric] as num).toDouble();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final points = _getPoints();
    final current = points.isNotEmpty ? points.last : 0.0;
    final minVal = points.isNotEmpty ? points.reduce(min) : 0.0;
    final maxVal = points.isNotEmpty ? points.reduce(max) : 0.0;
    final avgVal = points.isNotEmpty ? points.reduce((a, b) => a + b) / points.length : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sensor Monitoring', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Real-time history logs from connected IoT telemetry probes.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          // Filters Card
          CustomCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Zone Field:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedZone,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 13),
                        underline: const SizedBox(),
                        items: _state.sensors
                            .map((s) => DropdownMenuItem(value: s.zone, child: Text(s.zone)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedZone = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sensor Metric:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedMetric,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 13),
                        underline: const SizedBox(),
                        items: _metricLabels.entries
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMetric = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Custom Line Chart painting
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_metricLabels[_selectedMetric]} Trend Timeline',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: points.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : CustomPaint(
                          painter: TelemetryChartPainter(points: points),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Summary Statistics Cards
          Text('Telemetry Summary Statistics', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('CURRENT READING', current.toStringAsFixed(1), 'Latest value logged', AppColors.primary),
              _buildStatCard('AVERAGE VALUE', avgVal.toStringAsFixed(1), 'Running telemetry mean', AppColors.secondary),
              _buildStatCard('MINIMUM RECORDED', minVal.toStringAsFixed(1), 'Lowest index registered', AppColors.warning),
              _buildStatCard('MAXIMUM RECORDED', maxVal.toStringAsFixed(1), 'Highest peak registered', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String description, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppStyles.subtitleStyle.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(description, style: AppStyles.monoStyle.copyWith(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// Custom Painter drawing the Line chart
class TelemetryChartPainter extends CustomPainter {
  final List<double> points;

  TelemetryChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // Determine min/max boundaries
    final minVal = points.reduce(min);
    final maxVal = points.reduce(max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Padding parameters
    const double padLeft = 10;
    const double padRight = 10;
    const double padTop = 15;
    const double padBottom = 15;

    final chartWidth = size.width - padLeft - padRight;
    final chartHeight = size.height - padTop - padBottom;

    final double stepX = chartWidth / (points.length - 1);
    
    // Draw baseline grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < 4; i++) {
      final y = padTop + chartHeight * (i / 3);
      canvas.drawLine(Offset(padLeft, y), Offset(size.width - padRight, y), gridPaint);
    }

    final path = Path();
    final fillPath = Path();

    // Map first point
    double getX(int idx) => padLeft + idx * stepX;
    double getY(double val) {
      final t = (val - minVal) / range;
      return padTop + chartHeight * (1.0 - t); // invert coordinates for screen drawing
    }

    path.moveTo(getX(0), getY(points[0]));
    fillPath.moveTo(getX(0), size.height - padBottom);
    fillPath.lineTo(getX(0), getY(points[0]));

    for (int i = 1; i < points.length; i++) {
      path.lineTo(getX(i), getY(points[i]));
      fillPath.lineTo(getX(i), getY(points[i]));
    }

    fillPath.lineTo(getX(points.length - 1), size.height - padBottom);
    fillPath.close();

    // Draw area gradient fill
    final rect = Rect.fromPoints(Offset(padLeft, padTop), Offset(size.width - padRight, size.height - padBottom));
    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withOpacity(0.3),
        AppColors.primary.withOpacity(0.0),
      ],
    ).createShader(rect);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw active indicator dot on the latest point
    final lastX = getX(points.length - 1);
    final lastY = getY(points.last);
    
    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lastX, lastY), 8, glowPaint);

    final dotPaint = Paint()
      ..color = AppColors.textBright
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lastX, lastY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
