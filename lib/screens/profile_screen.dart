import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Operator Profile', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Configure facility registration info and audit connected IoT nodes.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          // User details header block
          CustomCard(
            child: Row(
              children: [
                // Operator Avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_state.farmerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Lead Agricultural Operations Supervisor', style: AppStyles.subtitleStyle),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGlow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _state.subscriptionTier,
                          style: AppStyles.monoStyle.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Facility Information summary card
          Text('Facility Information', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          CustomCard(
            child: Column(
              children: [
                _buildInfoRow('Farm Name', _state.farmName, Icons.agriculture),
                const Divider(color: AppColors.border, height: 20),
                _buildInfoRow('GPS Boundary', _state.location, Icons.location_on),
                const Divider(color: AppColors.border, height: 20),
                _buildInfoRow('Total Size', '${_state.acreage} Acres', Icons.square_foot),
                const Divider(color: AppColors.border, height: 20),
                _buildInfoRow('Connected since', '${_state.registrationDate.day}/${_state.registrationDate.month}/${_state.registrationDate.year}', Icons.calendar_today),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Connected Hardware node list
          Text('Connected Node Hardware', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          CustomCard(
            child: Column(
              children: [
                _buildHardwareRow('Telemetry Soil Probes', '4 Probes Active', Icons.sensors, AppColors.primary),
                const Divider(color: AppColors.border, height: 20),
                _buildHardwareRow('Quadcopter drone', '1 DJI Agras Docked', Icons.flight, AppColors.secondary),
                const Divider(color: AppColors.border, height: 20),
                _buildHardwareRow('Weather Station Probe', '1 solar Station Online', Icons.wb_sunny, AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 18),
        const SizedBox(width: 12),
        Text(label, style: AppStyles.subtitleStyle.copyWith(color: AppColors.textMuted, fontSize: 12)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildHardwareRow(String title, String status, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(status, style: AppStyles.subtitleStyle.copyWith(fontSize: 11)),
          ],
        ),
        const Spacer(),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
