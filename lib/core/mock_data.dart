import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/sensor_reading.dart';
import '../models/drone_flight.dart';
import '../models/recommendation.dart';
import '../services/firebase_firestore_service.dart';

class FarmLog {
  final String id;
  final DateTime timestamp;
  final String level; // info, warning, error, critical
  final String source;
  final String message;

  FarmLog({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
  });
}

class ChatMessage {
  final String role; // user, bot
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.message,
    required this.timestamp,
  });
}

class FarmState extends ChangeNotifier {
  // Singleton
  static final FarmState _instance = FarmState._internal();
  factory FarmState() => _instance;
  FarmState._internal() {
    _initializeData();
    _checkFirebaseAndConnect();
  }

  // Firebase integration status
  bool useFirebase = false;
  String? currentFarmId;
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();

  // Subscriptions to cancel upon logout
  final List<StreamSubscription> _firebaseSubscriptions = [];

  // Current Weather State
  String weatherCondition = 'Sunny';
  double weatherTemp = 24.0;
  int weatherHumidity = 60;
  int weatherWindSpeed = 10;
  bool stormWarning = false;
  bool frostWarning = false;

  // Weather forecast mocks
  List<Map<String, dynamic>> forecast = [
    {'day': 'Mon', 'temp': 24.5, 'humidity': 58, 'condition': 'Sunny'},
    {'day': 'Tue', 'temp': 25.0, 'humidity': 60, 'condition': 'Sunny'},
    {'day': 'Wed', 'temp': 22.0, 'humidity': 75, 'condition': 'Cloudy'},
    {'day': 'Thu', 'temp': 20.5, 'humidity': 85, 'condition': 'Rainy'},
    {'day': 'Fri', 'temp': 23.0, 'humidity': 65, 'condition': 'Cloudy'},
  ];

  // Farm Details
  String farmName = "Green Valley Homestead";
  String location = "37.7749° N, 122.4194° W";
  double acreage = 120.0;
  String farmerName = "Karthik";
  String subscriptionTier = "Enterprise Pro";
  DateTime registrationDate = DateTime.now().subtract(const Duration(days: 365));

  // Collections
  final List<SensorReading> sensors = [];
  final List<DroneFlight> droneFlights = [];
  final List<Recommendation> recommendations = [];
  final List<FarmLog> logs = [];
  final List<ChatMessage> chats = [];
  
  // Historical chart tracker
  final List<Map<String, dynamic>> telemetryHistory = [];

  // Active flight simulation tracker
  DroneFlight? activeFlight;
  double flightProgress = 0.0;
  Timer? _flightTimer;
  Timer? _simulationTimer;

  // ----------------------------------------------------
  // Firebase Handshake Setup
  // ----------------------------------------------------
  Future<void> _checkFirebaseAndConnect() async {
    try {
      // Check if Firebase is initialized in the app
      if (Firebase.apps.isNotEmpty) {
        useFirebase = true;
        currentFarmId = "farm_demo_id"; // default demo node
        _connectFirebaseStreams();
        saveLog('Firebase', 'Connected to cloud services & live database.', 'info');
      } else {
        _startSimulation();
      }
    } catch (_) {
      useFirebase = false;
      _startSimulation();
    }
  }

  // Connect firestore data streams to UI state variables
  void _connectFirebaseStreams() {
    if (!useFirebase || currentFarmId == null) return;

    // 1. Clear local mock simulation timers to free up resources
    _simulationTimer?.cancel();

    // 2. Stream Farm Details
    _firebaseSubscriptions.add(
      _firestoreService.getFarmStream(currentFarmId!).listen((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          farmName = data['name'] ?? farmName;
          location = data['location'] ?? location;
          acreage = (data['acreage'] as num?)?.toDouble() ?? acreage;
          notifyListeners();
        }
      })
    );

    // 3. Stream Telemetry logs
    _firebaseSubscriptions.add(
      _firestoreService.getTelemetryStream(currentFarmId!).listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          telemetryHistory.clear();
          
          // Populate history ticks
          for (final doc in snapshot.docs.reversed) {
            final data = doc.data() as Map<String, dynamic>;
            final readingsMap = data['readings'] as Map<String, dynamic>? ?? {};
            
            final tick = {
              'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now()
            };

            readingsMap.forEach((zone, values) {
              tick[zone] = Map<String, dynamic>.from(values);
            });
            
            telemetryHistory.add(tick);
          }

          // Update current live sensors view using the latest tick entry
          final latestData = snapshot.docs.first.data() as Map<String, dynamic>;
          final readingsMap = latestData['readings'] as Map<String, dynamic>? ?? {};
          
          sensors.clear();
          readingsMap.forEach((zone, values) {
            sensors.add(SensorReading(
              zone: zone,
              cropName: values['cropName'] ?? 'Crop',
              temperature: (values['temperature'] as num?)?.toDouble() ?? 20.0,
              soilMoisture: values['soilMoisture'] ?? 50,
              ph: (values['ph'] as num?)?.toDouble() ?? 6.5,
              nitrogen: values['nitrogen'] ?? 100,
              phosphorus: values['phosphorus'] ?? 40,
              potassium: values['potassium'] ?? 200,
              status: values['status'] ?? 'Online',
              anomalies: List<String>.from(values['anomalies'] ?? []),
            ));
          });
          
          notifyListeners();
        }
      })
    );

    // 4. Stream Drone Missions logs
    _firebaseSubscriptions.add(
      _firestoreService.getDroneMissionsStream(currentFarmId!).listen((snapshot) {
        droneFlights.clear();
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final flight = DroneFlight(
            id: doc.id,
            timestamp: (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
            zone: data['zone'] ?? 'Zone A',
            cropName: data['cropName'] ?? 'Crop',
            status: data['status'] ?? 'completed',
            reason: data['reason'] ?? '',
            triggerType: data['triggerType'] ?? 'manual',
            battery: data['battery'] ?? 100,
            diagnostics: data['diagnostics'] != null ? Map<String, dynamic>.from(data['diagnostics']) : null,
          );
          droneFlights.add(flight);

          // If there is an active flight session, map it to local progress view
          if (['launching', 'active', 'scanning'].contains(flight.status)) {
            activeFlight = flight;
            flightProgress = flight.status == 'launching' ? 0.2 : flight.status == 'active' ? 0.5 : 0.8;
          }
        }
        
        if (activeFlight != null && !snapshot.docs.any((d) => ['launching', 'active', 'scanning'].contains(d.data()['status']))) {
          activeFlight = null;
          flightProgress = 0.0;
        }

        notifyListeners();
      })
    );

    // 5. Stream active Recommendations warnings
    _firebaseSubscriptions.add(
      _firestoreService.getRecommendationsStream(currentFarmId!).listen((snapshot) {
        recommendations.clear();
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          recommendations.add(Recommendation(
            id: doc.id,
            timestamp: (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
            zone: data['zone'] ?? 'Zone A',
            cropName: data['cropName'] ?? 'Crop',
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            severity: data['severity'] ?? 'warning',
            recommendations: List<String>.from(data['recommendations'] ?? []),
            resolved: data['resolved'] ?? false,
            resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate().toIso8601String(),
          ));
        }
        notifyListeners();
      })
    );

    // 6. Stream chronological activity logs
    _firebaseSubscriptions.add(
      _firestoreService.getLogsStream(currentFarmId!).listen((snapshot) {
        logs.clear();
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          logs.add(FarmLog(
            id: doc.id,
            timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            level: data['level'] ?? 'info',
            source: data['source'] ?? 'System',
            message: data['message'] ?? '',
          ));
        }
        notifyListeners();
      })
    );
  }

  // Disconnect Firebase listeners on operator logout
  void disconnectFirebase() {
    for (final sub in _firebaseSubscriptions) {
      sub.cancel();
    }
    _firebaseSubscriptions.clear();
    useFirebase = false;
    currentFarmId = null;
    _initializeData();
    _startSimulation();
  }

  // ----------------------------------------------------
  // Initial Mock Setup Data
  // ----------------------------------------------------
  void _initializeData() {
    sensors.clear();
    sensors.addAll([
      SensorReading(
        zone: 'Zone A',
        cropName: 'Lettuce Field',
        temperature: 20.4,
        soilMoisture: 68,
        ph: 6.2,
        nitrogen: 140,
        phosphorus: 48,
        potassium: 210,
        status: 'Online',
        anomalies: [],
      ),
      SensorReading(
        zone: 'Zone B',
        cropName: 'Apple Orchard',
        temperature: 21.8,
        soilMoisture: 56,
        ph: 6.5,
        nitrogen: 110,
        phosphorus: 38,
        potassium: 195,
        status: 'Online',
        anomalies: [],
      ),
      SensorReading(
        zone: 'Zone C',
        cropName: 'Vineyard',
        temperature: 23.5,
        soilMoisture: 47,
        ph: 6.8,
        nitrogen: 95,
        phosphorus: 35,
        potassium: 170,
        status: 'Online',
        anomalies: [],
      ),
      SensorReading(
        zone: 'Zone D',
        cropName: 'Wheat Fields',
        temperature: 20.9,
        soilMoisture: 51,
        ph: 6.0,
        nitrogen: 130,
        phosphorus: 42,
        potassium: 205,
        status: 'Online',
        anomalies: [],
      ),
    ]);

    logs.clear();
    saveLog('System', 'FarmGuardian AI Dashboard initialized successfully.', 'info');
    saveLog('Sensors', 'All 4 multi-spectrum soil probes online.', 'info');
    saveLog('DroneStation', 'DJI Agras Quadcopter docked & fully charged.', 'info');

    telemetryHistory.clear();
    for (int i = 10; i >= 0; i--) {
      final timestamp = DateTime.now().subtract(Duration(minutes: i * 5));
      _recordHistoryTick(timestamp);
    }
  }

  Future<void> updateProfile({required String newFarmName, required String newLocation, required double newAcreage}) async {
    if (useFirebase && currentFarmId != null) {
      await _firestoreService.updateFarmDetails(currentFarmId!, newFarmName, newLocation, newAcreage);
    } else {
      farmName = newFarmName;
      location = newLocation;
      acreage = newAcreage;
      saveLog('Profile', 'Farm profile updated: $farmName ($acreage acres)', 'info');
      notifyListeners();
    }
  }

  void saveLog(String source, String message, String level) {
    if (useFirebase && currentFarmId != null) {
      _firestoreService.saveSystemLog(currentFarmId!, source, message, level);
    } else {
      logs.insert(0, FarmLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        level: level,
        source: source,
        message: message,
      ));
      if (logs.length > 200) logs.removeLast();
      notifyListeners();
    }
  }

  // Set weather manuals
  void triggerWeatherEvent(String event) {
    if (useFirebase) {
      saveLog('WeatherMonitor', 'Weather override event triggered: $event', 'warning');
      // For real cloud database we can write to a /weather config document, 
      // but for frontend UI prototype simulation keeping it local to this client is perfect!
    }

    switch (event) {
      case 'severe_storm':
        weatherCondition = 'Stormy';
        weatherTemp = 16.0;
        weatherHumidity = 92;
        weatherWindSpeed = 78;
        stormWarning = true;
        frostWarning = false;
        break;
      case 'frost_alert':
        weatherCondition = 'Frosty';
        weatherTemp = -1.5;
        weatherHumidity = 85;
        weatherWindSpeed = 12;
        stormWarning = false;
        frostWarning = true;
        break;
      case 'heat_wave':
        weatherCondition = 'HeatWave';
        weatherTemp = 41.5;
        weatherHumidity = 14;
        weatherWindSpeed = 22;
        stormWarning = false;
        frostWarning = false;
        break;
      case 'normal':
      default:
        weatherCondition = 'Sunny';
        weatherTemp = 24.0;
        weatherHumidity = 60;
        weatherWindSpeed = 8;
        stormWarning = false;
        frostWarning = false;
        break;
    }
    
    _tickTelemetry();
    
    if (useFirebase && currentFarmId != null) {
      // Sync the telemetry readings tick directly into Firestore!
      final Map<String, Map<String, dynamic>> readings = {};
      for (final s in sensors) {
        readings[s.zone] = s.toJson();
      }
      _firestoreService.saveTelemetryTick(currentFarmId!, readings);
    }

    notifyListeners();
  }

  // Trigger Sensor Anomalies
  Future<void> triggerAnomaly(String zone, String anomalyType) async {
    final idx = sensors.indexWhere((s) => s.zone == zone);
    if (idx == -1) return;

    final s = sensors[idx];
    if (anomalyType == 'clear') {
      s.anomalies.clear();
      s.status = 'Online';
      s.soilMoisture = zone == 'Zone A' ? 70 : zone == 'Zone B' ? 58 : zone == 'Zone C' ? 48 : 52;
      s.nitrogen = 130;
      s.phosphorus = 45;
      s.potassium = 200;
      saveLog('SensorMonitor', 'Cleaned active issues in $zone. Recovery sequence initiated.', 'info');
      
      if (useFirebase && currentFarmId != null) {
        _syncSensorsToFirestore();
      } else {
        notifyListeners();
      }
      return;
    }

    if (!s.anomalies.contains(anomalyType)) {
      s.anomalies.add(anomalyType);
    }
    s.status = 'Warning';
    saveLog('SensorMonitor', 'ALERT: anomaly [$anomalyType] detected in $zone (${s.cropName}).', 'warning');

    if (anomalyType == 'drought') {
      s.soilMoisture = (s.soilMoisture * 0.4).round();
    } else if (anomalyType == 'nutrient_def') {
      s.nitrogen = (s.nitrogen * 0.25).round();
      s.phosphorus = (s.phosphorus * 0.3).round();
      s.potassium = (s.potassium * 0.4).round();
    }

    if (useFirebase && currentFarmId != null) {
      await _syncSensorsToFirestore();
    } else {
      notifyListeners();
      // Trigger AI assessment locally
      Timer(const Duration(seconds: 2), () => auditTelemetry(zone, anomalyType));
    }
  }

  Future<void> _syncSensorsToFirestore() async {
    final Map<String, Map<String, dynamic>> readings = {};
    for (final s in sensors) {
      readings[s.zone] = s.toJson();
    }
    await _firestoreService.saveTelemetryTick(currentFarmId!, readings);
  }

  // Gemini Telemetry Audit simulation (used only in local simulation fallback mode)
  void auditTelemetry(String zone, String activeAnomaly) {
    if (useFirebase) return; // cloud functions handle this autonomously on write!

    final s = sensors.firstWhere((s) => s.zone == zone);
    saveLog('GeminiDecisionEngine', 'AI Telemetry Audit running for $zone...', 'info');

    if (activeAnomaly == 'drought' || activeAnomaly == 'nutrient_def' || activeAnomaly == 'pests' || activeAnomaly == 'disease') {
      final reason = activeAnomaly == 'drought' 
        ? "Soil moisture in $zone fell to ${s.soilMoisture}%. High-priority thermal leaf scan scheduled."
        : "Biological stress anomaly detected in ${s.cropName}. Drone launch authorized.";
      
      saveLog('GeminiDecisionEngine', 'AUTONOMOUS ORDER: Launching drone for $zone. Reason: $reason', 'critical');
      launchDroneMission(zone, reason, 'autonomous', activeAnomaly);
    }
  }

  // Trigger Drone Flight
  Future<void> launchDroneMission(String zone, String reason, String triggerType, String activeAnomaly) async {
    if (activeFlight != null) return;

    if (useFirebase && currentFarmId != null) {
      final s = sensors.firstWhere((s) => s.zone == zone);
      await _firestoreService.launchDroneMission(
        farmId: currentFarmId!,
        zone: zone,
        cropName: s.cropName,
        reason: reason,
        triggerType: triggerType,
      );
      // Firestore trigger function takes care of compiling the drone sweep state
    } else {
      // Local mockup drone loop
      final s = sensors.firstWhere((s) => s.zone == zone);
      final missionId = 'mission_${DateTime.now().millisecondsSinceEpoch}';

      activeFlight = DroneFlight(
        id: missionId,
        timestamp: DateTime.now().toIso8601String(),
        zone: zone,
        cropName: s.cropName,
        status: 'launching',
        reason: reason,
        triggerType: triggerType,
        battery: 100,
      );

      droneFlights.insert(0, activeFlight!);
      flightProgress = 0.0;
      saveLog('DroneStation', 'Drone launched for mission $missionId (Target: $zone).', 'info');
      notifyListeners();

      _flightTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (activeFlight == null) {
          timer.cancel();
          return;
        }

        flightProgress += 0.1;
        activeFlight!.battery -= 2;

        if (flightProgress >= 0.3 && flightProgress < 0.6) {
          activeFlight!.status = 'active';
        } else if (flightProgress >= 0.6 && flightProgress < 1.0) {
          activeFlight!.status = 'scanning';
        } else if (flightProgress >= 1.0) {
          timer.cancel();
          _completeDroneMission(activeAnomaly);
        }
        notifyListeners();
      });
    }
  }

  void _completeDroneMission(String anomaly) {
    if (activeFlight == null) return;

    final mission = activeFlight!;
    mission.status = 'completed';
    mission.battery -= 10;

    final diagnostics = getMockImageDiagnosis(mission.zone, mission.cropName, anomaly);
    mission.diagnostics = diagnostics;

    if (diagnostics['issueDetected'] != 'None') {
      final rec = Recommendation(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now().toIso8601String(),
        zone: mission.zone,
        cropName: mission.cropName,
        title: diagnostics['issueDetected'],
        description: diagnostics['findings'],
        severity: diagnostics['severity'],
        recommendations: List<String>.from(diagnostics['recommendations']),
        resolved: false,
      );
      recommendations.insert(0, rec);
      saveLog('GeminiDecisionEngine', 'New prescription registered: ${rec.title} for ${rec.zone}.', 'warning');
    }

    saveLog('DroneStation', 'Mission ${mission.id} completed. Diagnostics synchronized.', 'info');
    activeFlight = null;
    notifyListeners();
  }

  Map<String, dynamic> getMockImageDiagnosis(String zone, String cropName, String anomaly) {
    if (anomaly == 'drought') {
      return {
        'cropHealthStatus': 'stressed',
        'issueDetected': 'Water Deficiency (Drought stress)',
        'severity': 'critical',
        'confidence': 95,
        'findings': 'Thermal imaging reveals severe plant dehydration in $cropName. Canopy leaf temperatures are elevated, and soil structural cracks are visible.',
        'recommendations': [
          'Initiate drip-irrigation cycle immediately for 120 minutes.',
          'Inject soil-wetting agents to improve capillary hydration.',
          'Apply organic crop straw mulch layers.'
        ]
      };
    } else if (anomaly == 'nutrient_def') {
      return {
        'cropHealthStatus': 'stressed',
        'issueDetected': 'Nitrogen & Phosphorus Deficit',
        'severity': 'warning',
        'confidence': 88,
        'findings': 'Multispectral NDVI indices show chlorotic yellowing trends matching Nitrogen deficiency signatures.',
        'recommendations': [
          'Apply liquid NPK custom soil treatment.',
          'Review fertilizer concentration schedules.'
        ]
      };
    }
    return {
      'cropHealthStatus': 'healthy',
      'issueDetected': 'None',
      'severity': 'normal',
      'confidence': 98,
      'findings': 'Lush, uniform chlorophyll turgor detected.',
      'recommendations': ['Maintain regular watering checks.']
    };
  }

  Future<void> resolveRecommendation(String recId) async {
    if (useFirebase) {
      await _firestoreService.resolveRecommendation(recId);
    } else {
      final idx = recommendations.indexWhere((r) => r.id == recId);
      if (idx == -1) return;

      final rec = recommendations[idx];
      rec.resolved = true;
      rec.resolvedAt = DateTime.now().toIso8601String();
      triggerAnomaly(rec.zone, 'clear');
      saveLog('Operations', 'Applied agronomical cure for alert ID $recId in ${rec.zone}.', 'info');
      notifyListeners();
    }
  }

  // Local Simulation Clock Tick loop
  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _tickWeather();
      _tickTelemetry();
      _recordHistoryTick(DateTime.now());
      notifyListeners();
    });
  }

  void _tickWeather() {
    if (stormWarning || frostWarning || weatherCondition == 'HeatWave') {
      weatherTemp += (Random().nextDouble() * 0.8 - 0.4);
      return;
    }
    weatherTemp += (Random().nextDouble() * 0.6 - 0.3);
    weatherHumidity = max(20, min(95, weatherHumidity + Random().nextInt(5) - 2));
    weatherTemp = double.parse(weatherTemp.toStringAsFixed(1));
  }

  void _tickTelemetry() {
    for (final s in sensors) {
      s.temperature = double.parse((weatherTemp + Random().nextDouble() * 1.5 - 0.75).toStringAsFixed(1));

      if (weatherCondition == 'Stormy' || weatherCondition == 'Rainy') {
        s.soilMoisture = min(95, s.soilMoisture + Random().nextInt(4) + 2);
      } else if (weatherCondition == 'HeatWave' || s.anomalies.contains('drought')) {
        s.soilMoisture = max(6, s.soilMoisture - Random().nextInt(3) - 1);
      } else {
        final target = s.zone == 'Zone A' ? 70 : s.zone == 'Zone B' ? 58 : s.zone == 'Zone C' ? 48 : 52;
        if (s.soilMoisture > target) s.soilMoisture--;
        else if (s.soilMoisture < target) s.soilMoisture++;
      }

      if (s.anomalies.contains('nutrient_def')) {
        s.nitrogen = max(10, s.nitrogen - Random().nextInt(2));
        s.phosphorus = max(5, s.phosphorus - Random().nextInt(1));
        s.potassium = max(20, s.potassium - Random().nextInt(3));
      } else {
        s.nitrogen = max(60, min(180, s.nitrogen + Random().nextInt(5) - 2));
        s.phosphorus = max(20, min(70, s.phosphorus + Random().nextInt(3) - 1));
        s.potassium = max(100, min(300, s.potassium + Random().nextInt(6) - 3));
      }

      s.ph = double.parse((s.ph + Random().nextDouble() * 0.04 - 0.02).toStringAsFixed(2));

      if (s.anomalies.isNotEmpty || s.soilMoisture < 35 || s.nitrogen < 50) {
        s.status = 'Warning';
      } else {
        s.status = 'Online';
      }
    }
  }

  void _recordHistoryTick(DateTime time) {
    final tickData = {'timestamp': time};
    for (final s in sensors) {
      tickData[s.zone] = {
        'soilMoisture': s.soilMoisture,
        'temperature': s.temperature,
        'ph': s.ph,
        'nitrogen': s.nitrogen,
        'phosphorus': s.phosphorus,
        'potassium': s.potassium,
      };
    }
    telemetryHistory.add(tickData);
    if (telemetryHistory.length > 50) telemetryHistory.removeAt(0);
  }

  // Chat consultation execution
  Future<void> sendChatMessage(String msg) async {
    chats.add(ChatMessage(role: 'user', message: msg, timestamp: DateTime.now()));
    notifyListeners();

    if (useFirebase && currentFarmId != null) {
      try {
        // Query the Firebase Cloud Function consultAI
        final result = await FirebaseFunctions.instance
            .httpsCallable('consultAI')
            .call({
              'farmId': currentFarmId,
              'message': msg,
              'history': chats.map((c) => {'role': c.role, 'message': c.message}).toList()
            });

        final reply = result.data['response']?.toString() ?? 'I could not compile a response.';
        chats.add(ChatMessage(role: 'bot', message: reply, timestamp: DateTime.now()));
        notifyListeners();
      } catch (err) {
        print('Cloud Functions Consult Error: $err');
        chats.add(ChatMessage(role: 'bot', message: 'Failed to contact AI cloud services.', timestamp: DateTime.now()));
        notifyListeners();
      }
    } else {
      // Local mockup response
      Timer(const Duration(seconds: 1), () {
        String reply = "";
        final msgLower = msg.toLowerCase();
        
        if (msgLower.contains('water') || msgLower.contains('irrigate') || msgLower.contains('dry')) {
          reply = "Based on our latest IoT logs, **Zone A** (Lettuce) has an optimal moisture profile of 70%, but active dry spell alerts could deplete this by 15% daily. I suggest scheduling a 45-minute drip irrigation sweep tomorrow at sunrise to mitigate thermal evaporation.";
        } else if (msgLower.contains('pest') || msgLower.contains('bug') || msgLower.contains('disease')) {
          reply = "Visual leaf sweep logs indicate a moderate aphid risk in the Apple Orchard (**Zone B**). I suggest applying a 2% organic neem oil spray solution. Alternatively, introducing bio-predators (ladybugs) will regulate them naturally.";
        } else {
          reply = "Hello! I am your FarmGuardian AI Agronomy Consultant. I monitor sensors, forecast trends, and review drone imagery across all zones (Lettuce, Apple, Grape, Wheat).\n\nHow can I help you improve crop yields or treat crop symptoms today?";
        }

        chats.add(ChatMessage(role: 'bot', message: reply, timestamp: DateTime.now()));
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _flightTimer?.cancel();
    _simulationTimer?.cancel();
    disconnectFirebase();
    super.dispose();
  }
}

extension ListContains<T> on List<T> {
  bool includes(T element) => contains(element);
}
