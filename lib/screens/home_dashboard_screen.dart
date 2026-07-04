import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeDashboardScreen({
    Key? key,
    required this.onTabChange,
  }) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
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
    final activeAlerts = _state.recommendations.where((r) => !r.resolved).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm General Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _state.farmName,
                    style: AppStyles.titleStyle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.secondary, size: 14),
                      const SizedBox(width: 4),
                      Text(_state.location, style: AppStyles.subtitleStyle.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGlow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI ENGINE ACTIVE',
                      style: AppStyles.monoStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weather Station Widget Row
          _buildWeatherWidget(),
          const SizedBox(height: 20),

          // Quick Navigation Grid Mocks
          Text('Tactical Operations', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => widget.onTabChange(2), // Farm Map
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: const [
                        Icon(Icons.map, color: AppColors.secondary),
                        SizedBox(width: 10),
                        Text('Farm Map', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => widget.onTabChange(3), // Drone Mission
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: const [
                        Icon(Icons.flight_takeoff, color: AppColors.secondary),
                        SizedBox(width: 10),
                        Text('Drone Launch', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // IoT Sensor Probes Telemetry List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IoT Telemetry Probes', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
              TextButton(
                onPressed: () => widget.onTabChange(4), // Sensor Monitoring Screen
                child: const Text('View Charts', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _state.sensors.length,
            itemBuilder: (context, idx) {
              final sensor = _state.sensors[idx];
              final isWarning = sensor.status == 'Warning';
              return _buildSensorCard(sensor, isWarning);
            },
          ),
          const SizedBox(height: 24),

          // Active Recommendations Alerts Section
          if (activeAlerts.isNotEmpty) ...[
            Text('Active AI Prescriptions', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeAlerts.length,
              itemBuilder: (context, idx) {
                final rec = activeAlerts[idx];
                return Padding(
                  padding: const EdgeInsets.bottomOffset(10.0),
                  child: CustomCard(
                    borderColor: rec.severity == 'critical' ? AppColors.danger : AppColors.warning,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(rec.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${rec.zone} (${rec.cropName})', style: AppStyles.monoStyle.copyWith(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(rec.description, style: AppStyles.subtitleStyle.copyWith(fontSize: 12)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rec.recommendations.first,
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            ElevatedButton(
                              onPressed: () => _state.resolveRecommendation(rec.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGlow,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                              ),
                              child: const Text('Apply Cure', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherWidget() {
    final warningActive = _state.stormWarning || _state.frostWarning;
    return CustomCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_state.weatherTemp}°C', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('Condition: ${_state.weatherCondition}', style: AppStyles.subtitleStyle.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Humidity: ${_state.weatherHumidity}%', style: AppStyles.bodyStyle.copyWith(fontSize: 12)),
                  Text('Wind: ${_state.weatherWindSpeed} km/h', style: AppStyles.bodyStyle.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
          if (warningActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.danger, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _state.stormWarning
                          ? 'WEATHER HAZARD: SEVERE WINDS INBOUND'
                          : 'WEATHER HAZARD: FROST WARNING CANOPY RISK',
                      style: AppStyles.monoStyle.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weather Simulator Override:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              DropdownButton<String>(
                value: _state.weatherCondition == 'Sunny' ? 'normal' : 
                       _state.weatherCondition == 'Stormy' ? 'severe_storm' :
                       _state.weatherCondition == 'Frosty' ? 'frost_alert' :
                       _state.weatherCondition == 'HeatWave' ? 'heat_wave' : 'normal',
                dropdownColor: AppColors.cardBg,
                style: const TextStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.bold),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text('Sunny (Normal)')),
                  DropdownMenuItem(value: 'severe_storm', child: Text('Severe Storm')),
                  DropdownMenuItem(value: 'frost_alert', child: Text('Frost Warning')),
                  DropdownMenuItem(value: 'heat_wave', child: Text('Heat Wave')),
                ],
                onChanged: (val) {
                  if (val != null) _state.triggerWeatherEvent(val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(SensorReading sensor, bool isWarning) {
    return CustomCard(
      padding: const EdgeInsets.all(10),
      borderColor: isWarning ? AppColors.danger : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sensor.zone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isWarning ? AppColors.danger : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Text(sensor.cropName, style: AppStyles.subtitleStyle.copyWith(fontSize: 10)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Moisture:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(
                '${sensor.soilMoisture}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: sensor.soilMoisture < 40 ? AppColors.danger : AppColors.textMain,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Temp:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('${sensor.temperature}°C', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          // Set stress anomaly triggers directly from UI
          Container(
            height: 22,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: null,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  sensor.anomalies.isNotEmpty ? 'Anomaly: ${sensor.anomalies.first}' : 'Test Anomaly',
                  style: TextStyle(
                    fontSize: 9, 
                    fontWeight: FontWeight.bold,
                    color: sensor.anomalies.isNotEmpty ? AppColors.danger : AppColors.textMuted
                  ),
                ),
              ),
              underline: const SizedBox(),
              iconSize: 12,
              dropdownColor: AppColors.cardBg,
              items: const [
                DropdownMenuItem(value: 'drought', child: Text('Drought', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'pests', child: Text('Pest Attack', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'disease', child: Text('Fungal Rot', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'nutrient_def', child: Text('NPK Deficit', style: TextStyle(fontSize: 10))),
                DropdownMenuItem(value: 'clear', child: Text('Clear/Recover', style: TextStyle(fontSize: 10))),
              ],
              onChanged: (val) {
                if (val != null) _state.triggerAnomaly(sensor.zone, val);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper padding offset extension to resolve build padding list issues
extension ListPadding on Widget {
  Widget paddingBottomOffset(double val) {
    return Padding(padding: EdgeInsets.only(bottom: val), child: this);
  }
}
