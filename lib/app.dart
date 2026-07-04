import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/farm_health_dashboard_screen.dart';
import 'screens/farm_map_screen.dart';
import 'screens/drone_mission_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/sensor_monitoring_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/farm_memory_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({Key? key}) : super(key: key);

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentBottomTab = 0;
  String _activeDrawerPage = 'tabs'; // 'tabs' or 'sensors', 'notifications', 'reports', 'memory', 'profile', 'settings'

  // Tab views index list
  late final List<Widget> _tabScreens;

  @override
  void initState() {
    super.initState();
    _tabScreens = [
      HomeDashboardScreen(onTabChange: (idx) {
        setState(() {
          _activeDrawerPage = 'tabs';
          _currentBottomTab = idx;
        });
      }),
      const FarmHealthDashboardScreen(),
      const FarmMapScreen(),
      const DroneMissionScreen(),
      const AIChatScreen(),
    ];
  }

  // Resolve titles dynamically
  String _getAppBarTitle() {
    if (_activeDrawerPage != 'tabs') {
      switch (_activeDrawerPage) {
        case 'sensors':
          return 'IoT Monitoring';
        case 'notifications':
          return 'System Alerts';
        case 'reports':
          return 'Reports & Analytics';
        case 'memory':
          return 'Farm Memory logs';
        case 'profile':
          return 'Farmer Profile';
        case 'settings':
          return 'System Settings';
        default:
          return 'FarmGuardian AI';
      }
    }
    
    switch (_currentBottomTab) {
      case 0:
        return 'Facility Operations';
      case 1:
        return 'Canopy Health Vigor';
      case 2:
        return 'Autonomous Drone Radar';
      case 3:
        return 'Aerial Diagnostics Station';
      case 4:
        return 'Gemini AI Agronomist';
      default:
        return 'FarmGuardian AI';
    }
  }

  // Active page selector
  Widget _getActiveBody() {
    if (_activeDrawerPage != 'tabs') {
      switch (_activeDrawerPage) {
        case 'sensors':
          return const SensorMonitoringScreen();
        case 'notifications':
          return const NotificationsScreen();
        case 'reports':
          return const ReportsScreen();
        case 'memory':
          return const FarmMemoryScreen();
        case 'profile':
          return const ProfileScreen();
        case 'settings':
          return const SettingsScreen();
        default:
          return _tabScreens[0];
      }
    }
    return _tabScreens[_currentBottomTab];
  }

  @override
  Widget build(BuildContext context) {
    final activeBody = _getActiveBody();
    final isTabActive = _activeDrawerPage == 'tabs';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textBright,
        elevation: 2,
        actions: [
          // Quick Notifications trigger bell
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _activeDrawerPage = 'notifications';
              });
            },
          ),
        ],
      ),
      
      // Bottom Navigation Bar Drawer
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.cardBg,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGlow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.spa, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'FarmGuardian AI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textBright,
                          ),
                        ),
                        Text(
                          'Facility Management Console',
                          style: AppStyles.subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem('Home Dashboard', Icons.dashboard, isTabActive, () {
                    setState(() {
                      _activeDrawerPage = 'tabs';
                      _currentBottomTab = 0;
                    });
                  }),
                  _buildDrawerItem('IoT Telemetry Trends', Icons.insights, _activeDrawerPage == 'sensors', () {
                    setState(() => _activeDrawerPage = 'sensors');
                  }),
                  _buildDrawerItem('Alert Alarms Feed', Icons.notification_important, _activeDrawerPage == 'notifications', () {
                    setState(() => _activeDrawerPage = 'notifications');
                  }),
                  _buildDrawerItem('Reports & Analytics', Icons.assessment, _activeDrawerPage == 'reports', () {
                    setState(() => _activeDrawerPage = 'reports');
                  }),
                  _buildDrawerItem('Farm Memory timeline', Icons.storage, _activeDrawerPage == 'memory', () {
                    setState(() => _activeDrawerPage = 'memory');
                  }),
                  const Divider(color: AppColors.border, height: 24),
                  _buildDrawerItem('Facility Profile', Icons.location_city, _activeDrawerPage == 'profile', () {
                    setState(() => _activeDrawerPage = 'profile');
                  }),
                  _buildDrawerItem('Settings Console', Icons.settings, _activeDrawerPage == 'settings', () {
                    setState(() => _activeDrawerPage = 'settings');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey('${_activeDrawerPage}_$_currentBottomTab'),
          child: activeBody,
        ),
      ),

      // Bottom Bar Navigation only shown when drawer page isn't override
      bottomNavigationBar: isTabActive
          ? BottomNavigationBar(
              currentIndex: _currentBottomTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.cardBg,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              onTap: (idx) {
                setState(() {
                  _currentBottomTab = idx;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.healing_outlined),
                  activeIcon: Icon(Icons.healing),
                  label: 'Health',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.flight_takeoff_outlined),
                  activeIcon: Icon(Icons.flight_takeoff),
                  label: 'Drone',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_outlined),
                  activeIcon: Icon(Icons.forum),
                  label: 'AI Chat',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, bool selected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textMain,
          fontSize: 13,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.primaryGlow,
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        onTap();
      },
    );
  }
}
