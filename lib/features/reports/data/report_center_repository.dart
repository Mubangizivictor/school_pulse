import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/reports/domain/reporting.dart';

/// Tenant-scoped metadata only. It deliberately never stores report rows.
class ReportCenterRepository {
  ReportCenterRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(
    String institutionId,
    String name,
  ) =>
      _firestore.collection('institutions').doc(institutionId).collection(name);

  Stream<List<SavedReport>> watchSavedReports(
    String institutionId,
    String userId,
  ) => _collection(institutionId, 'saved_reports')
      .where('ownerUserId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return SavedReport(
            id: doc.id,
            reportKey: data['reportKey'] as String? ?? '',
            name: data['name'] as String? ?? 'Untitled report',
            ownerUserId: userId,
            filters: Map<String, dynamic>.from(
              data['filters'] as Map? ?? const {},
            ),
            createdAt: _date(data['createdAt']),
          );
        }).toList(),
      );

  Future<void> savePreset(String institutionId, SavedReport preset) =>
      _collection(institutionId, 'saved_reports').doc(preset.id).set({
        ...preset.toJson(),
        'institutionId': institutionId,
      });

  Future<void> deletePreset(String institutionId, String presetId) =>
      _collection(institutionId, 'saved_reports').doc(presetId).delete();

  Future<void> queueExport(String institutionId, ReportExportJob job) async {
    await _collection(
      institutionId,
      'report_export_jobs',
    ).doc(job.id).set({...job.toJson(), 'institutionId': institutionId});
  }

  Future<void> audit(
    String institutionId, {
    required String action,
    required String actorId,
    required String reportKey,
    Map<String, dynamic> filters = const {},
  }) => _collection(institutionId, 'report_audit').add({
    'action': action,
    'actorId': actorId,
    'reportKey': reportKey,
    'filters': filters,
    'createdAt': FieldValue.serverTimestamp(),
  });

  DateTime _date(Object? value) => value is Timestamp
      ? value.toDate()
      : DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
