import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _state = FarmState();
  bool _isGenerating = false;

  void _simulateReportDownload(String format) {
    setState(() => _isGenerating = true);
    Future.delayed(const Duration(seconds: 1.5), () {
      if (mounted) {
        setState(() => _isGenerating = false);
        _state.saveLog('System', 'Harvest report generated & exported as $format successfully.', 'info');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farm audit database successfully downloaded as $format!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Agronomy Analytics', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          Text('Export detailed farm logs and review forecasted yield parameters.', style: AppStyles.subtitleStyle),
          const SizedBox(height: 20),

          // Export panel buttons
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Generate Audit Reports',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Compile full multispectral drone flight paths, historical soil telemetry trends, and active crop diagnostics.',
                  style: AppStyles.subtitleStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : () => _simulateReportDownload('PDF'),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : () => _simulateReportDownload('CSV'),
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isGenerating) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 3,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Forecast Yield Projections
          Text('Harvest Yield Projections', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          CustomCard(
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.8),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5))),
                  children: [
                    _buildTableHeader('CROP FIELD'),
                    _buildTableHeader('ACREAGE'),
                    _buildTableHeader('EST. YIELD'),
                    _buildTableHeader('HARVEST WINDOW'),
                  ],
                ),
                _buildTableRow('Lettuce Field', '30 ac', '950 kg/ac', '14 Days'),
                _buildTableRow('Apple Orchard', '45 ac', '4,200 kg/ac', '45 Days'),
                _buildTableRow('Vineyard', '25 ac', '1,850 kg/ac', '60 Days'),
                _buildTableRow('Wheat Fields', '20 ac', '2,900 kg/ac', '90 Days'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Resource Distribution summary
          Text('Environmental Resource Usage', style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildUsageCard('Total Water Irrigated', '480k gal', 'Drip lines automatic cycle', Icons.opacity, AppColors.secondary),
              _buildUsageCard('Organic Fertilizer', '3,400 kg', 'Distributed via fertigation', Icons.grass, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: AppStyles.monoStyle.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  TableRow _buildTableRow(String field, String size, String yield, String window) {
    return TableRow(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8))),
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text(field, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text(size, style: const TextStyle(fontSize: 11))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text(yield, style: AppStyles.monoStyle.copyWith(fontSize: 10, color: AppColors.primary))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 10.0), child: Text(window, style: AppStyles.monoStyle.copyWith(fontSize: 10, color: AppColors.secondary))),
      ],
    );
  }

  Widget _buildUsageCard(String label, String value, String details, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(label, style: AppStyles.subtitleStyle.copyWith(fontSize: 10)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(details, style: AppStyles.monoStyle.copyWith(fontSize: 8, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
