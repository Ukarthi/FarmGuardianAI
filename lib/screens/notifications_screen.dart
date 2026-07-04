import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
    // Generate notification list by compiling logs + critical recommendations
    final warningLogs = _state.logs.where((l) => l.level == 'warning' || l.level == 'critical').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alert Station', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Real-time sensor warning triggers and drone inspection completions.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          if (warningLogs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: const [
                    Icon(Icons.notifications_off, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('All modules running nominal. No alerts.', style: AppStyles.subtitleStyle),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: warningLogs.length,
              itemBuilder: (context, idx) {
                final log = warningLogs[idx];
                final isCritical = log.level == 'critical';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: CustomCard(
                    borderColor: isCritical ? AppColors.danger : AppColors.warning,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isCritical ? Icons.error : Icons.warning_amber,
                          color: isCritical ? AppColors.danger : AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log.source.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isCritical ? AppColors.danger : AppColors.warning,
                                    ),
                                  ),
                                  Text(
                                    '${log.timestamp.hour.toString().padLeft(2, "0")}:${log.timestamp.minute.toString().padLeft(2, "0")}',
                                    style: AppStyles.monoStyle.copyWith(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.message,
                                style: AppStyles.bodyStyle.copyWith(fontSize: 12, height: 1.3),
                              ),
                            ],
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
}
