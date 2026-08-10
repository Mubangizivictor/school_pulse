import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sheets_integration.dart';

abstract class SheetsIntegrationRemoteDataSource {
  Future<SheetsIntegration> getIntegration(String schoolId);
  Future<void> saveIntegration(String schoolId, SheetsIntegration integration);
  Future<void> disconnect(String schoolId);
  Future<List<SheetsSyncLogEntry>> getSyncLog(String schoolId);
  Future<void> appendSyncLog(String schoolId, SheetsSyncLogEntry entry);
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
    final data = doc.data()!;
    return SheetsIntegration(
      linked: data['linked'] as bool? ?? false,
      spreadsheetId: data['spreadsheetId'] as String? ?? '',
      spreadsheetName: data['spreadsheetName'] as String? ?? '',
      worksheetName: data['worksheetName'] as String? ?? '',
      autoSync: data['autoSync'] as bool? ?? true,
      syncFrequency: data['syncFrequency'] as String? ?? 'Every marking',
      lastSyncAt: (data['lastSyncAt'] as Timestamp?)?.toDate(),
      lastSyncStatus: data['lastSyncStatus'] as String? ?? '',
    );
  }

  @override
  Future<void> saveIntegration(
    String schoolId,
    SheetsIntegration integration,
  ) async {
    await _integrationDoc(schoolId).set({
      'linked': integration.linked,
      'spreadsheetId': integration.spreadsheetId,
      'spreadsheetName': integration.spreadsheetName,
      'worksheetName': integration.worksheetName,
      'autoSync': integration.autoSync,
      'syncFrequency': integration.syncFrequency,
      'lastSyncAt': integration.lastSyncAt != null
          ? Timestamp.fromDate(integration.lastSyncAt!)
          : null,
      'lastSyncStatus': integration.lastSyncStatus,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> disconnect(String schoolId) async {
    await _integrationDoc(schoolId).set({
      'linked': false,
      'spreadsheetId': '',
      'spreadsheetName': '',
      'worksheetName': '',
    }, SetOptions(merge: true));
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

  @override
  Future<void> appendSyncLog(String schoolId, SheetsSyncLogEntry entry) async {
    await _syncLog(schoolId).add({
      'startedAt': Timestamp.fromDate(entry.startedAt),
      'success': entry.success,
      'recordCount': entry.recordCount,
      'errorMessage': entry.errorMessage,
    });
  }
}
