import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_reading.dart';
import '../models/drone_flight.dart';
import '../models/recommendation.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------------------
  // Farm Profile Actions
  // ----------------------------------------------------
  Stream<DocumentSnapshot> getFarmStream(String farmId) {
    return _db.collection('farms').doc(farmId).snapshots();
  }

  Future<void> updateFarmDetails(String farmId, String name, String location, double acreage) async {
    await _db.collection('farms').doc(farmId).update({
      'name': name,
      'location': location,
      'acreage': acreage,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ----------------------------------------------------
  // Telemetry Actions
  // ----------------------------------------------------
  Stream<QuerySnapshot> getTelemetryStream(String farmId, {int limit = 50}) {
    return _db.collection('telemetry')
        .where('farmId', '==', farmId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> saveTelemetryTick(String farmId, Map<String, Map<String, dynamic>> readings) async {
    await _db.collection('telemetry').add({
      'farmId': farmId,
      'timestamp': FieldValue.serverTimestamp(),
      'readings': readings,
    });
  }

  // ----------------------------------------------------
  // Drone Mission Actions
  // ----------------------------------------------------
  Stream<QuerySnapshot> getDroneMissionsStream(String farmId, {int limit = 20}) {
    return _db.collection('drone_missions')
        .where('farmId', '==', farmId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<DocumentReference> launchDroneMission({
    required String farmId,
    required String zone,
    required String cropName,
    required String reason,
    required String triggerType,
  }) async {
    return await _db.collection('drone_missions').add({
      'farmId': farmId,
      'zone': zone,
      'cropName': cropName,
      'status': 'launching',
      'reason': reason,
      'triggerType': triggerType,
      'battery': 100,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDroneMission(String missionId, Map<String, dynamic> updates) async {
    await _db.collection('drone_missions').doc(missionId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ----------------------------------------------------
  // AI Recommendations Actions
  // ----------------------------------------------------
  Stream<QuerySnapshot> getRecommendationsStream(String farmId) {
    return _db.collection('recommendations')
        .where('farmId', '==', farmId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> resolveRecommendation(String recId) async {
    await _db.collection('recommendations').doc(recId).update({
      'resolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  // ----------------------------------------------------
  // System Activity Logs Actions
  // ----------------------------------------------------
  Stream<QuerySnapshot> getLogsStream(String farmId, {int limit = 100}) {
    return _db.collection('logs')
        .where('farmId', '==', farmId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> saveSystemLog(String farmId, String source, String message, String level) async {
    await _db.collection('logs').add({
      'farmId': farmId,
      'timestamp': FieldValue.serverTimestamp(),
      'source': source,
      'message': message,
      'level': level,
    });
  }
}
