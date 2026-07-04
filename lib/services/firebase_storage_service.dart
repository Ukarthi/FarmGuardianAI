import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload crop multispectral image bytes to Storage
  Future<String> uploadDroneInspectionImage(String missionId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('farms/drone_sweeps/inspection_$missionId.jpg');
      
      // Upload metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'missionId': missionId},
      );

      final uploadTask = await ref.putData(imageBytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Firebase Storage Upload Exception: $e');
      rethrow;
    }
  }
}
