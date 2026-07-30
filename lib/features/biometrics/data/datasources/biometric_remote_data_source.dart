import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/biometrics/data/models/biometric_settings_model.dart';
import 'package:school_pulse/features/biometrics/data/models/biometric_audit_log_model.dart';

abstract class BiometricRemoteDataSource {
  Future<BiometricSettingsModel> getSettings(String schoolId);
  Future<void> updateSettings(String schoolId, BiometricSettingsModel settings);
  Future<void> saveTemplate(String schoolId, String personId, String personType, String template);
  Future<String?> getTemplate(String schoolId, String personId);
  Future<void> logEvent(BiometricAuditLogModel log);
  Stream<List<BiometricAuditLogModel>> getAuditLogs(String schoolId, {String? personId});
}

class BiometricRemoteDataSourceImpl implements BiometricRemoteDataSource {
  final FirebaseFirestore firestore;

  BiometricRemoteDataSourceImpl({required this.firestore});

  @override
  Future<BiometricSettingsModel> getSettings(String schoolId) async {
    final doc = await firestore.collection('schools').doc(schoolId).collection('config').doc('biometrics').get();
    if (doc.exists) {
      return BiometricSettingsModel.fromMap(doc.data()!);
    }
    return BiometricSettingsModel();
  }

  @override
  Future<void> updateSettings(String schoolId, BiometricSettingsModel settings) async {
    await firestore.collection('schools').doc(schoolId).collection('config').doc('biometrics').set(settings.toMap());
  }

  @override
  Future<void> saveTemplate(String schoolId, String personId, String personType, String template) async {
    await firestore.collection('schools').doc(schoolId).collection('biometric_templates').doc(personId).set({
      'personId': personId,
      'personType': personType,
      'template': template,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String?> getTemplate(String schoolId, String personId) async {
    final doc = await firestore.collection('schools').doc(schoolId).collection('biometric_templates').doc(personId).get();
    return doc.data()?['template'];
  }

  @override
  Future<void> logEvent(BiometricAuditLogModel log) async {
    await firestore.collection('schools').doc(log.schoolId).collection('biometric_logs').doc(log.id).set(log.toMap());
  }

  @override
  Stream<List<BiometricAuditLogModel>> getAuditLogs(String schoolId, {String? personId}) {
    var query = firestore.collection('schools').doc(schoolId).collection('biometric_logs').orderBy('timestamp', descending: true);
    
    if (personId != null) {
      query = query.where('personId', isEqualTo: personId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BiometricAuditLogModel.fromMap(doc.data())).toList();
    });
  }
}
