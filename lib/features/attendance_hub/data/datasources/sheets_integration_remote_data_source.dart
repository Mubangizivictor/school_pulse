import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sheets_integration.dart';

abstract class SheetsIntegrationRemoteDataSource {
  Future<SheetsIntegration> getIntegration(String schoolId);

  /// Client-owned display preferences only (auto-sync toggle). Connection
  /// state (linked/spreadsheetId/connectedAccountEmail/...) is written only
  /// by the OAuth callback and disconnect callable, server-side.
  Future<void> updatePreferences(String schoolId, {bool? autoSync});

  Future<List<SheetsSyncLogEntry>> getSyncLog(String schoolId);
}

class SheetsIntegrationRemoteDataSourceImpl
    implements SheetsIntegrationRemoteDataSource {
  final FirebaseFirestore firestore;

  SheetsIntegrationRemoteDataSourceImpl({required this.firestore});

  DocumentReference<Map<String, dynamic>> _integrationDoc(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('attendance_sheets_integration')
          .doc('config');

  CollectionReference<Map<String, dynamic>> _syncLog(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('attendance_sheets_sync_log');

  @override
  Future<SheetsIntegration> getIntegration(String schoolId) async {
    final doc = await _integrationDoc(schoolId).get();
    if (!doc.exists) return const SheetsIntegration();
    return SheetsIntegration.fromMap(doc.data()!);
  }

  @override
  Future<void> updatePreferences(String schoolId, {bool? autoSync}) async {
    final updates = <String, dynamic>{};
    if (autoSync != null) updates['autoSync'] = autoSync;
    if (updates.isEmpty) return;
    await _integrationDoc(schoolId).set(updates, SetOptions(merge: true));
  }

  @override
  Future<List<SheetsSyncLogEntry>> getSyncLog(String schoolId) async {
    final snapshot = await _syncLog(
      schoolId,
    ).orderBy('startedAt', descending: true).limit(20).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SheetsSyncLogEntry(
        id: doc.id,
        startedAt: (data['startedAt'] as Timestamp).toDate(),
        success: data['success'] as bool? ?? false,
        recordCount: data['recordCount'] as int? ?? 0,
        errorMessage: data['errorMessage'] as String?,
      );
    }).toList();
  }
}
