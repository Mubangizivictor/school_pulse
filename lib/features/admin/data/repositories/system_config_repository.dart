import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/system_config.dart';

class SystemConfigRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<SystemConfig?> getConfig() async {
    final doc = await _firestore.collection('config').doc('system').get();
    if (doc.exists) {
      return SystemConfig.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateConfig(SystemConfig config) async {
    await _firestore.collection('config').doc('system').set(config.toMap());
  }
  
  Stream<SystemConfig> watchConfig() {
    return _firestore
        .collection('config')
        .doc('system')
        .snapshots()
        .map((doc) => SystemConfig.fromMap(doc.data() ?? {}));
  }
}
