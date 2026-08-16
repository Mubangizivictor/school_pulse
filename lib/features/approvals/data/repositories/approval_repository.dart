import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/entities/approval_models.dart';

/// The client is deliberately read-mostly: all decisions and mutations go
/// through callable functions, where permission, delegation, source-version
/// and policy checks are performed in one transaction.
class ApprovalRepository {
  ApprovalRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _requests(String schoolId) =>
      _firestore
          .collection('schools')
          .doc(schoolId)
          .collection('approval_requests');

  Stream<List<ApprovalRequest>> watchInbox(String schoolId) =>
      _requests(schoolId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map(
            (s) => s.docs
                .map(
                  (d) => ApprovalRequest.fromMap({
                    ...d.data(),
                    'approvalRequestId': d.id,
                  }),
                )
                .toList(),
          );

  Stream<List<ApprovalAction>> watchActions(
    String schoolId,
    String requestId,
  ) => _requests(schoolId)
      .doc(requestId)
      .collection('actions')
      .orderBy('timestamp')
      .snapshots()
      .map(
        (s) => s.docs.map((d) {
          final m = d.data();
          final raw = m['timestamp'];
          return ApprovalAction(
            actionId: d.id,
            requestId: requestId,
            actorId: m['actorId'] as String? ?? '',
            action: m['action'] as String? ?? '',
            stage: m['stage'] as String? ?? '',
            comment: m['comment'] as String? ?? '',
            timestamp: raw is Timestamp
                ? raw.toDate()
                : DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now(),
          );
        }).toList(),
      );

  Future<void> decide({
    required String schoolId,
    required String requestId,
    required ApprovalDecision decision,
    String comment = '',
    int? expectedVersion,
  }) async {
    await _functions.httpsCallable('decideApprovalRequest').call({
      'institutionId': schoolId,
      'requestId': requestId,
      'decision': decision.name,
      'comment': comment,
      'expectedVersion': expectedVersion,
    });
  }

  Future<void> delegate({
    required String schoolId,
    required String delegateId,
    required DateTime startsAt,
    required DateTime endsAt,
    required String reason,
    List<String> modules = const [],
    List<String> requestTypes = const [],
  }) async {
    await _functions.httpsCallable('createApprovalDelegation').call({
      'institutionId': schoolId,
      'delegateId': delegateId,
      'startsAt': startsAt.toIso8601String(),
      'endsAt': endsAt.toIso8601String(),
      'reason': reason,
      'modules': modules,
      'requestTypes': requestTypes,
    });
  }

  Future<void> escalate({
    required String schoolId,
    required String requestId,
    String reason = '',
  }) async => _functions.httpsCallable('escalateApprovalRequest').call({
    'institutionId': schoolId,
    'requestId': requestId,
    'reason': reason,
  });
}
