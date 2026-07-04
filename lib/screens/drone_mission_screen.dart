import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';
import '../widgets/crop_camera_feed.dart';

class DroneMissionScreen extends StatefulWidget {
  const DroneMissionScreen({Key? key}) : super(key: key);

  @override
  State<DroneMissionScreen> createState() => _DroneMissionScreenState();
}

class _DroneMissionScreenState extends State<DroneMissionScreen> {
  final _state = FarmState();
  String _selectedZone = 'Zone A';

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
    final lastMission = _state.droneFlights.isNotEmpty ? _state.droneFlights.first : null;
    final isScanning = active != null && active.status == 'scanning';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Drone Station', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Manage autonomous aerial sweeps, monitor battery and review AI scans.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          // Core status widget
          _buildStationStatusCard(active),
          const SizedBox(height: 20),

          // Camera visual feed block
          Text('Multispectral Camera Stream', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          if (isScanning)
            CropCameraFeed(
              condition: _state.sensors.firstWhere((s) => s.zone == active.zone).anomalies.isNotEmpty
                  ? _state.sensors.firstWhere((s) => s.zone == active.zone).anomalies.first
                  : 'healthy',
              zone: active.zone,
            )
          else if (lastMission != null && lastMission.status == 'completed')
            CropCameraFeed(
              condition: lastMission.diagnostics?['issueDetected']?.toString().contains('Drought') == true
                  ? 'drought'
                  : lastMission.diagnostics?['issueDetected']?.toString().contains('Deficit') == true
                      ? 'nutrient_def'
                      : lastMission.diagnostics?['issueDetected']?.toString().contains('Aphid') == true
                          ? 'pests'
                          : lastMission.diagnostics?['issueDetected']?.toString().contains('Mildew') == true
                              ? 'disease'
                              : 'healthy',
              zone: lastMission.zone,
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.videocam_off, color: AppColors.textMuted, size: 36),
                  SizedBox(height: 8),
                  Text('Video Feed Offline. Launch drone to connect.', style: AppStyles.subtitleStyle),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Gemini Diagnostic output report
          if (lastMission != null && lastMission.diagnostics != null && active == null) ...[
            Text('Gemini Diagnostic Report', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            CustomCard(
              borderColor: lastMission.diagnostics!['severity'] == 'critical'
                  ? AppColors.danger
                  : lastMission.diagnostics!['severity'] == 'warning'
                      ? AppColors.warning
                      : AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGlow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'GEMINI DIAGNOSIS COMPLETE',
                              style: AppStyles.monoStyle.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastMission.diagnostics!['issueDetected'] ?? 'No stress detected',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: lastMission.diagnostics!['severity'] == 'critical'
                              ? AppColors.danger.withOpacity(0.12)
                              : AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          lastMission.diagnostics!['severity']?.toUpperCase() ?? 'NORMAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: lastMission.diagnostics!['severity'] == 'critical'
                                ? AppColors.danger
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lastMission.diagnostics!['findings'] ?? '',
                    style: AppStyles.bodyStyle.copyWith(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Agronomist Recommendations:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  ...List<String>.from(lastMission.diagnostics!['recommendations'] ?? [])
                      .map((rec) => Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                Expanded(child: Text(rec, style: const TextStyle(fontSize: 11))),
                              ],
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'CONFIDENCE: ${lastMission.diagnostics!['confidence']}% | TARGET: ${lastMission.zone}',
                      style: AppStyles.monoStyle.copyWith(fontSize: 9, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Drone Command Launcher
          if (active == null) ...[
            Text('Station Commands launcher', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Quadrant field:', style: TextStyle(fontSize: 12)),
                      DropdownButton<String>(
                        value: _selectedZone,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                        underline: const SizedBox(),
                        items: _state.sensors
                            .map((s) => DropdownMenuItem(value: s.zone, child: Text('${s.zone} (${s.cropName})')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedZone = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final s = _state.sensors.firstWhere((s) => s.zone == _selectedZone);
                      _state.launchDroneMission(
                        _selectedZone,
                        'Manual command operator survey check.',
                        'manual',
                        s.anomalies.isNotEmpty ? s.anomalies.first : 'none',
                      );
                    },
                    icon: const Icon(Icons.flight_takeoff),
                    label: const Text('Initiate Aerial Survey'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStationStatusCard(DroneFlight? active) {
    final hasActive = active != null;
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasActive ? AppColors.secondaryGlow : AppColors.primaryGlow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasActive ? Icons.navigation : Icons.battery_charging_full,
              color: hasActive ? AppColors.secondary : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActive
                      ? 'MISSION STATE: ${active.status.toUpperCase()}'
                      : 'DRONE DOCKED (CHARGING)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  hasActive
                      ? 'Surveying ${active.zone} due to warning signals.'
                      : 'Battery fully optimized at 100%. Dock pods stable.',
                  style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                ),
                if (hasActive) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _state.flightProgress,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
