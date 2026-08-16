import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:school_pulse/features/data_management/domain/data_operation_models.dart';

/// Client for backend-owned data operations. No source collection is ever
/// mutated from here; the callable validates membership, permission, schema,
/// idempotency and delegates to the owning module provider.
class DataManagementRepository {
  DataManagementRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<DataOperation>> watchRecent(String institutionId) {
    Stream<List<DataOperation>> watch(
      String collection,
      DataOperationKind kind,
    ) => _firestore
        .collection('institutions')
        .doc(institutionId)
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (event) => event.docs
              .map((doc) => DataOperation.fromFirestore(doc, kind))
              .toList(),
        );
    return watch('import_jobs', DataOperationKind.import).asyncExpand(
      (imports) => watch(
        'export_jobs',
        DataOperationKind.export,
      ).map((exports) => [...imports, ...exports]),
    );
  }

  Stream<List<DataOperation>> watch(
    String institutionId,
    DataOperationKind kind,
  ) {
    final collection = switch (kind) {
      DataOperationKind.import => 'import_jobs',
      DataOperationKind.export => 'export_jobs',
      DataOperationKind.migration => 'migration_jobs',
      DataOperationKind.quality => 'data_quality_runs',
      DataOperationKind.restore => 'restore_requests',
    };
    return _firestore
        .collection('institutions')
        .doc(institutionId)
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (event) => event.docs
              .map((doc) => DataOperation.fromFirestore(doc, kind))
              .toList(),
        );
  }

  Future<String> request({
    required String operation,
    required String institutionId,
    String moduleKey = 'data',
    Map<String, dynamic> payload = const {},
  }) async {
    final result = await _functions
        .httpsCallable('requestDataOperation')
        .call<Map<String, dynamic>>({
          'operation': operation,
          'institutionId': institutionId,
          'moduleKey': moduleKey,
          ...payload,
        });
    return result.data['jobId'] as String;
  }
}
