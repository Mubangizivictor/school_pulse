import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:school_pulse/features/institution_health/domain/institution_health_models.dart';

class InstitutionHealthRepository {
  InstitutionHealthRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  DocumentReference<Map<String, dynamic>> _summary(String id) => _firestore
      .collection('institutions')
      .doc(id)
      .collection('health_summary')
      .doc('current');
  CollectionReference<Map<String, dynamic>> _checks(String id) =>
      _firestore.collection('institutions').doc(id).collection('health_checks');

  Stream<InstitutionHealthScore?> watchScore(String institutionId) =>
      _summary(institutionId).snapshots().map(
        (snapshot) => snapshot.exists
            ? InstitutionHealthScore.fromMap(institutionId, snapshot.data()!)
            : null,
      );
  Stream<List<HealthCheckResult>> watchChecks(String institutionId) =>
      _checks(institutionId)
          .orderBy('priority', descending: true)
          .limit(100)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => HealthCheckResult.fromMap(doc.id, doc.data()))
                .toList(),
          );

  Future<void> recheck(String institutionId, {String? checkKey}) async {
    final payload = <String, dynamic>{'institutionId': institutionId};
    if (checkKey?.isNotEmpty ?? false) {
      payload['checkKey'] = checkKey;
    }
    await _functions
        .httpsCallable('requestInstitutionHealthRecheck')
        .call(payload);
  }

  Future<void> acknowledge(String institutionId, String checkId) async =>
      _functions.httpsCallable('resolveInstitutionHealthIssue').call({
        'institutionId': institutionId,
        'checkId': checkId,
        'state': 'acknowledged',
      });
}
