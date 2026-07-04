import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../core/mock_data.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _state = FarmState();

  // Initialize and request notification settings
  Future<void> initializeNotificationServices(BuildContext context) async {
    try {
      // 1. Request OS Permission
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Operator notification permission status: ${settings.authorizationStatus}');

      // 2. Fetch Device Token for targeting individual runs
      final token = await _fcm.getToken();
      print('FCM Registration Device Token: $token');

      // 3. Configure foreground message listeners
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground notification received: ${message.notification?.title}');
        
        // Log in system logs
        _state.saveLog(
          'AlertManager', 
          'Notification: ${message.notification?.title} - ${message.notification?.body}', 
          'warning'
        );

        // Display in-app banner snackbar alert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.notification?.title ?? 'AI System Alarm', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(message.notification?.body ?? '', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.deepOrangeAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      });

      // 4. Handle Notification click actions when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened via notification click: ${message.notification?.title}');
        // Take custom navigation route inside dashboard
      });
      
    } catch (e) {
      print('FCM Init Exception: $e');
    }
  }

  // Subscribe to regional farm topic Alerts channel
  Future<void> subscribeToFarmAlerts(String farmId) async {
    final topic = 'farm_${farmId}_alerts';
    await _fcm.subscribeToTopic(topic);
    print('Subscribed operator to topic channel: $topic');
    _state.saveLog('AlertManager', 'Subscribed device node to alerts channel topic: $topic', 'info');
  }

  // Unsubscribe
  Future<void> unsubscribeFromFarmAlerts(String farmId) async {
    final topic = 'farm_${farmId}_alerts';
    await _fcm.unsubscribeFromTopic(topic);
    print('Unsubscribed operator from topic channel: $topic');
  }
}
