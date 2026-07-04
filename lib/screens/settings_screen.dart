import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _state = FarmState();
  
  // Settings values in-memory mocks
  bool _pushNotifications = true;
  bool _autonomousAudit = true;
  double _auditInterval = 25.0; // seconds
  double _moistureThreshold = 40.0; // percentage
  String _selectedLanguage = 'en';

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
          Text('Settings Console', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Adjust warning limits, audit frequencies, and language presets.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          // Toggles card
          Text('Operational Alarms', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          CustomCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  subtitle: const Text('Notify supervisor when threshold errors trigger.', style: AppStyles.subtitleStyle),
                  value: _pushNotifications,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(color: AppColors.border, height: 16),
                SwitchListTile(
                  title: const Text('Autonomous AI Drone Launches', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  subtitle: const Text('Allow Gemini decision auditor to schedule missions.', style: AppStyles.subtitleStyle),
                  value: _autonomousAudit,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _autonomousAudit = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sliders card
          Text('Auditor Limits', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audit frequency slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Telemetry Audit Rate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${_auditInterval.toInt()}s', style: AppStyles.monoStyle.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Rate at which Gemini audits database sensor charts.', style: AppStyles.subtitleStyle),
                Slider(
                  value: _auditInterval,
                  min: 10.0,
                  max: 60.0,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => setState(() => _auditInterval = val),
                ),
                const Divider(color: AppColors.border, height: 20),

                // Soil moisture trigger slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Drought Alarm Threshold', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${_moistureThreshold.toInt()}%', style: AppStyles.monoStyle.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Moisture level below which field triggers a drought warn.', style: AppStyles.subtitleStyle),
                Slider(
                  value: _moistureThreshold,
                  min: 20.0,
                  max: 55.0,
                  activeColor: AppColors.warning,
                  onChanged: (val) => setState(() => _moistureThreshold = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Language & Theme card
          Text('Language Preset', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Language Translation:', style: TextStyle(fontSize: 13)),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  dropdownColor: AppColors.cardBg,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English (US)')),
                    DropdownMenuItem(value: 'es', child: Text('Español (ES)')),
                    DropdownMenuItem(value: 'fr', child: Text('Français (FR)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLanguage = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Clear DB Action Buttons
          CustomCard(
            borderColor: AppColors.danger.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Danger Zone commands', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.danger)),
                const SizedBox(height: 6),
                const Text('Erases all recommendations logs, flight missions and sensor histories from Farm Memory.', style: AppStyles.subtitleStyle),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    // Reset simulator
                    _state.sensors.clear();
                    _state.droneFlights.clear();
                    _state.recommendations.clear();
                    _state.logs.clear();
                    _state.chats.clear();
                    _state.saveLog('System', 'Farm Memory database cleared by manual command.', 'info');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Farm database cleared successfully!'), backgroundColor: AppColors.danger),
                    );
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Erase Farm Memory DB'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.textBright,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
