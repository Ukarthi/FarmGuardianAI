import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class FarmMemoryScreen extends StatefulWidget {
  const FarmMemoryScreen({Key? key}) : super(key: key);

  @override
  State<FarmMemoryScreen> createState() => _FarmMemoryScreenState();
}

class _FarmMemoryScreenState extends State<FarmMemoryScreen> {
  final _state = FarmState();
  String _searchQuery = '';
  String _selectedLevel = 'all';

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

  List<FarmLog> _getFilteredLogs() {
    return _state.logs.where((log) {
      final matchesSearch = log.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.source.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesLevel = _selectedLevel == 'all' || log.level == _selectedLevel;
      
      return matchesSearch && matchesLevel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();

    return Column(
      children: [
        // Top filter bar
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            children: [
              // Search Input field
              TextField(
                style: AppStyles.bodyStyle,
                decoration: InputDecoration(
                  hintText: 'Search Farm Memory logs...',
                  hintStyle: AppStyles.subtitleStyle,
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 10),
              
              // Level filters row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Level:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildLevelButton('all', 'All Logs'),
                      _buildLevelButton('info', 'Info'),
                      _buildLevelButton('warning', 'Warning'),
                      _buildLevelButton('critical', 'Critical'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Log timeline feed
        Expanded(
          child: filteredLogs.isEmpty
              ? const Center(child: Text('No matching log records found in Farm Memory.', style: AppStyles.subtitleStyle))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, idx) {
                    final log = filteredLogs[idx];
                    return _buildTimelineItem(log, idx == filteredLogs.length - 1);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLevelButton(String level, String label) {
    final isSelected = _selectedLevel == level;
    return InkWell(
      onTap: () => setState(() => _selectedLevel = level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.background : AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(FarmLog log, bool isLast) {
    Color indicatorColor = AppColors.primary;
    if (log.level == 'critical') {
      indicatorColor = AppColors.danger;
    } else if (log.level == 'warning') {
      indicatorColor = AppColors.warning;
    }

    final timeStr = '${log.timestamp.hour.toString().padLeft(2, "0")}:${log.timestamp.minute.toString().padLeft(2, "0")}:${log.timestamp.second.toString().padLeft(2, "0")}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left visual timeline line indicator
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: indicatorColor.withOpacity(0.5), blurRadius: 4)],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Log detail card contents
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomCard(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '[${log.source.toUpperCase()}]',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: indicatorColor,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: AppStyles.monoStyle.copyWith(fontSize: 9, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      log.message,
                      style: AppStyles.bodyStyle.copyWith(fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
