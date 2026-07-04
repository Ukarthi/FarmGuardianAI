import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';
import '../widgets/drone_flight_path.dart';

class FarmMapScreen extends StatefulWidget {
  const FarmMapScreen({Key? key}) : super(key: key);

  @override
  State<FarmMapScreen> createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
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

  @override
  Widget build(BuildContext context) {
    final active = _state.activeFlight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tactical Farm Map', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Interactive layout detailing GPS boundary overlays and active drone sweeps.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          // Flight Path Map widget
          DroneFlightPath(
            status: active?.status ?? 'docked',
            targetZone: active?.zone ?? 'Zone A',
            progress: _state.flightProgress,
          ),
          const SizedBox(height: 20),

          // Map Legend / Info Panel
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Map Overlay Legend',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _buildLegendItem(Icons.crop_square, AppColors.primary, 'Healthy Quadrant (Uniform transpiration turgor)'),
                _buildLegendItem(Icons.crop_square, AppColors.danger, 'Anomaly Warning Quadrant (Drought or biological stress detected)'),
                _buildLegendItem(Icons.fiber_manual_record, AppColors.secondary, 'Drone Base Station Dock (Automatic recharging pod)'),
                _buildLegendItem(Icons.gps_fixed, AppColors.danger, 'Target Inspection coordinates waypoint'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sector detail indicators
          Text('Farm Sector Boundaries', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _state.sensors.length,
            itemBuilder: (context, idx) {
              final sensor = _state.sensors[idx];
              final hasAnomalies = sensor.anomalies.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CustomCard(
                  borderColor: hasAnomalies ? AppColors.danger : AppColors.border,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: hasAnomalies ? AppColors.danger.withOpacity(0.12) : AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.grid_view,
                          color: hasAnomalies ? AppColors.danger : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${sensor.zone}: ${sensor.cropName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              hasAnomalies ? '⚠️ Anomaly: ${sensor.anomalies.join(", ")}' : 'Optimal moisture and nutrients baseline',
                              style: TextStyle(
                                fontSize: 11,
                                color: hasAnomalies ? AppColors.danger : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flight_takeoff, color: AppColors.secondary),
                        onPressed: _state.activeFlight != null
                            ? null
                            : () => _state.launchDroneMission(sensor.zone, 'Manual operator survey check.', 'manual', sensor.anomalies.isNotEmpty ? sensor.anomalies.first : 'none'),
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

  Widget _buildLegendItem(IconData icon, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: AppStyles.subtitleStyle.copyWith(fontSize: 11, color: AppColors.textMain),
            ),
          ),
        ],
      ),
    );
  }
}
