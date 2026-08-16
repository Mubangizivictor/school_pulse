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

  CollectionReference<Map<String, dynamic>> _policies(String schoolId) =>
      _firestore
          .collection('schools')
          .doc(schoolId)
          .collection('approval_policies');

  CollectionReference<Map<String, dynamic>> _delegations(String schoolId) =>
      _firestore
          .collection('schools')
          .doc(schoolId)
          .collection('approval_delegations');

  Stream<List<ApprovalPolicy>> watchPolicies(String schoolId) =>
      _policies(schoolId).snapshots().map(
        (s) => s.docs
            .map(
              (d) => ApprovalPolicy.fromMap({
                ...d.data(),
                'approvalPolicyId': d.id,
              }),
            )
            .toList(),
      );

  Stream<List<ApprovalDelegation>> watchDelegations(String schoolId) =>
      _delegations(schoolId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (s) => s.docs
                .map(
                  (d) => ApprovalDelegation.fromMap({
                    ...d.data(),
                    'delegationId': d.id,
                  }),
                )
                .toList(),
          );

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

  /// Source-module entry point: creates an [ApprovalRequest] snapshot at
  /// the policy's first stage. Returns the assigned `requestId`.
  Future<String> submit({
    required String schoolId,
    required String moduleKey,
    required String requestType,
    required String sourceRecordType,
    required String sourceRecordId,
    required String title,
    required String approvalPolicyId,
    required String sourceRecordVersion,
    String sourceRoute = '',
    String summary = '',
    String? reason,
    ApprovalPriority priority = ApprovalPriority.normal,
    ApprovalSensitivity sensitivity = ApprovalSensitivity.normal,
    double? amount,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? proposedValue,
    List<String> attachments = const [],
    DateTime? dueAt,
    String? idempotencyKey,
    String? correlationId,
  }) async {
    final result = await _functions
        .httpsCallable('submitApprovalRequest')
        .call({
          'institutionId': schoolId,
          'moduleKey': moduleKey,
          'requestType': requestType,
          'sourceRecordType': sourceRecordType,
          'sourceRecordId': sourceRecordId,
          'sourceRoute': sourceRoute,
          'title': title,
          'summary': summary,
          'reason': reason,
          'approvalPolicyId': approvalPolicyId,
          'sourceRecordVersion': sourceRecordVersion,
          'priority': priority.name,
          'sensitivity': sensitivity.name,
          'amount': amount,
          'oldValue': oldValue,
          'proposedValue': proposedValue,
          'attachments': attachments,
          'dueAt': dueAt?.toIso8601String(),
          'idempotencyKey': idempotencyKey,
          'correlationId': correlationId,
        });
    return (result.data as Map)['requestId'] as String;
  }

  /// Source-module entry point: reports whether the operation an approved
  /// request authorized actually succeeded once executed.
  Future<void> reportExecutionResult({
    required String schoolId,
    required String requestId,
    required bool succeeded,
    String errorReference = '',
  }) async => _functions.httpsCallable('reportApprovalExecutionResult').call({
    'institutionId': schoolId,
    'requestId': requestId,
    'result': succeeded ? 'executed' : 'executionFailed',
    'errorReference': errorReference,
  });

  /// Creates a new policy, or updates an existing one (bumping its version)
  /// when [approvalPolicyId] is passed. Returns the policy id.
  Future<String> savePolicy({
    required String schoolId,
    required String name,
    required String moduleKey,
    required String requestType,
    required List<ApprovalStage> stages,
    String? approvalPolicyId,
    bool sequential = true,
    bool delegationAllowed = false,
    bool selfApprovalAllowed = false,
    bool escalationAllowed = true,
    bool requiresMfa = false,
    bool requiresReauth = false,
    Duration? dueTime,
    String status = 'active',
  }) async {
    final result = await _functions.httpsCallable('saveApprovalPolicy').call({
      'institutionId': schoolId,
      'approvalPolicyId': approvalPolicyId,
      'name': name,
      'moduleKey': moduleKey,
      'requestType': requestType,
      'stages': stages.map((s) => s.toMap()).toList(),
      'sequential': sequential,
      'delegationAllowed': delegationAllowed,
      'selfApprovalAllowed': selfApprovalAllowed,
      'escalationAllowed': escalationAllowed,
      'requiresMfa': requiresMfa,
      'requiresReauth': requiresReauth,
      'dueTimeMinutes': dueTime?.inMinutes,
      'status': status,
    });
    return (result.data as Map)['policyId'] as String;
  }
}
