import 'package:equatable/equatable.dart';

enum ApprovalStatus {
  draft,
  submitted,
  pending,
  inReview,
  awaitingInformation,
  returned,
  approved,
  rejected,
  partiallyApproved,
  escalated,
  delegated,
  cancelled,
  expired,
  executed,
  executionFailed,
  archived,
}

enum ApprovalPriority { low, normal, high, urgent, critical }

enum ApprovalSensitivity { normal, sensitive, confidential, restricted }

enum ApprovalDecision {
  approved,
  rejected,
  returned,
  informationRequested,
  cancelled,
  executionFailed,
  executed,
}

extension ApprovalStatusWire on ApprovalStatus {
  String get wire => name;
  static ApprovalStatus parse(Object? value) => ApprovalStatus.values
      .firstWhere((v) => v.name == value, orElse: () => ApprovalStatus.pending);
}

class ApprovalStage extends Equatable {
  final String stageId;
  final int order;
  final String name;
  final String requiredPermission;
  final String? requiredRoleTemplate;
  final int minimumApprovals;
  final bool parallel,
      allowReturn,
      allowReject,
      allowComment,
      requiresMfa,
      requiresReauth;
  final Duration? escalationTimeout;
  const ApprovalStage({
    required this.stageId,
    required this.order,
    required this.name,
    required this.requiredPermission,
    this.requiredRoleTemplate,
    this.minimumApprovals = 1,
    this.parallel = false,
    this.allowReturn = true,
    this.allowReject = true,
    this.allowComment = true,
    this.requiresMfa = false,
    this.requiresReauth = false,
    this.escalationTimeout,
  });
  Map<String, dynamic> toMap() => {
    'stageId': stageId,
    'order': order,
    'name': name,
    'requiredPermission': requiredPermission,
    'requiredRoleTemplate': requiredRoleTemplate,
    'minimumApprovals': minimumApprovals,
    'parallel': parallel,
    'allowReturn': allowReturn,
    'allowReject': allowReject,
    'allowComment': allowComment,
    'requiresMfa': requiresMfa,
    'requiresReauth': requiresReauth,
    'escalationTimeoutMinutes': escalationTimeout?.inMinutes,
  };
  factory ApprovalStage.fromMap(Map<String, dynamic> map) => ApprovalStage(
    stageId: map['stageId'] as String? ?? '',
    order: (map['order'] as num? ?? 0).toInt(),
    name: map['name'] as String? ?? 'Approval',
    requiredPermission:
        map['requiredPermission'] as String? ?? 'approvals.approve',
    requiredRoleTemplate: map['requiredRoleTemplate'] as String?,
    minimumApprovals: (map['minimumApprovals'] as num? ?? 1).toInt(),
    parallel: map['parallel'] == true,
    allowReturn: map['allowReturn'] != false,
    allowReject: map['allowReject'] != false,
    allowComment: map['allowComment'] != false,
    requiresMfa: map['requiresMfa'] == true,
    requiresReauth: map['requiresReauth'] == true,
    escalationTimeout: map['escalationTimeoutMinutes'] == null
        ? null
        : Duration(minutes: (map['escalationTimeoutMinutes'] as num).toInt()),
  );
  @override
  List<Object?> get props => [
    stageId,
    order,
    name,
    requiredPermission,
    requiredRoleTemplate,
    minimumApprovals,
    parallel,
    allowReturn,
    allowReject,
    allowComment,
    requiresMfa,
    requiresReauth,
    escalationTimeout,
  ];
}

class ApprovalPolicy extends Equatable {
  final String approvalPolicyId,
      institutionId,
      name,
      moduleKey,
      requestType,
      status;
  final List<ApprovalStage> stages;
  final int minimumApprovals, version;
  final bool sequential,
      delegationAllowed,
      selfApprovalAllowed,
      escalationAllowed,
      requiresMfa,
      requiresReauth;
  final Duration? dueTime;
  const ApprovalPolicy({
    required this.approvalPolicyId,
    required this.institutionId,
    required this.name,
    required this.moduleKey,
    required this.requestType,
    required this.stages,
    this.status = 'active',
    this.minimumApprovals = 1,
    this.version = 1,
    this.sequential = true,
    this.delegationAllowed = false,
    this.selfApprovalAllowed = false,
    this.escalationAllowed = true,
    this.requiresMfa = false,
    this.requiresReauth = false,
    this.dueTime,
  });
  Map<String, dynamic> toMap() => {
    'approvalPolicyId': approvalPolicyId,
    'institutionId': institutionId,
    'name': name,
    'moduleKey': moduleKey,
    'requestType': requestType,
    'stages': stages.map((s) => s.toMap()).toList(),
    'status': status,
    'minimumApprovals': minimumApprovals,
    'version': version,
    'sequential': sequential,
    'delegationAllowed': delegationAllowed,
    'selfApprovalAllowed': selfApprovalAllowed,
    'escalationAllowed': escalationAllowed,
    'requiresMfa': requiresMfa,
    'requiresReauth': requiresReauth,
    'dueTimeMinutes': dueTime?.inMinutes,
  };
  factory ApprovalPolicy.fromMap(Map<String, dynamic> map) => ApprovalPolicy(
    approvalPolicyId: map['approvalPolicyId'] as String? ?? '',
    institutionId: map['institutionId'] as String? ?? '',
    name: map['name'] as String? ?? '',
    moduleKey: map['moduleKey'] as String? ?? '',
    requestType: map['requestType'] as String? ?? '',
    stages: ((map['stages'] as List?) ?? [])
        .map((x) => ApprovalStage.fromMap(Map<String, dynamic>.from(x as Map)))
        .toList(),
    status: map['status'] as String? ?? 'active',
    minimumApprovals: (map['minimumApprovals'] as num? ?? 1).toInt(),
    version: (map['version'] as num? ?? 1).toInt(),
    sequential: map['sequential'] != false,
    delegationAllowed: map['delegationAllowed'] == true,
    selfApprovalAllowed: map['selfApprovalAllowed'] == true,
    escalationAllowed: map['escalationAllowed'] != false,
    requiresMfa: map['requiresMfa'] == true,
    requiresReauth: map['requiresReauth'] == true,
    dueTime: map['dueTimeMinutes'] == null
        ? null
        : Duration(minutes: (map['dueTimeMinutes'] as num).toInt()),
  );
  @override
  List<Object?> get props => [
    approvalPolicyId,
    institutionId,
    name,
    moduleKey,
    requestType,
    stages,
    status,
    minimumApprovals,
    version,
    sequential,
    delegationAllowed,
    selfApprovalAllowed,
    escalationAllowed,
    requiresMfa,
    requiresReauth,
    dueTime,
  ];
}

class ApprovalRequest extends Equatable {
  final String approvalRequestId,
      institutionId,
      moduleKey,
      requestType,
      sourceRecordType,
      sourceRecordId,
      sourceRoute,
      title,
      summary,
      requestedBy,
      requesterRole,
      currentStage,
      approvalPolicyId,
      sourceRecordVersion,
      correlationId;
  final String? requesterDepartment, requesterCampus, requesterDivision, reason;
  final ApprovalStatus currentStatus;
  final ApprovalPriority priority;
  final ApprovalSensitivity sensitivity;
  final double? amount;
  final Map<String, dynamic>? oldValue, proposedValue;
  final List<String> attachments, requiredApprovers;
  final DateTime createdAt, submittedAt;
  final DateTime? dueAt, resolvedAt;
  final int version;
  const ApprovalRequest({
    required this.approvalRequestId,
    required this.institutionId,
    required this.moduleKey,
    required this.requestType,
    required this.sourceRecordType,
    required this.sourceRecordId,
    required this.sourceRoute,
    required this.title,
    required this.summary,
    required this.requestedBy,
    required this.requesterRole,
    required this.currentStage,
    required this.currentStatus,
    required this.priority,
    required this.sensitivity,
    required this.approvalPolicyId,
    required this.sourceRecordVersion,
    required this.correlationId,
    required this.createdAt,
    required this.submittedAt,
    this.requesterDepartment,
    this.requesterCampus,
    this.requesterDivision,
    this.reason,
    this.amount,
    this.oldValue,
    this.proposedValue,
    this.attachments = const [],
    this.requiredApprovers = const [],
    this.dueAt,
    this.resolvedAt,
    this.version = 1,
  });
  factory ApprovalRequest.fromMap(Map<String, dynamic> map) {
    DateTime date(String k) {
      final v = map[k];
      if (v is DateTime) return v;
      try {
        final converted = (v as dynamic).toDate();
        if (converted is DateTime) return converted;
      } catch (_) {}
      return DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    }

    return ApprovalRequest(
      approvalRequestId: map['approvalRequestId'] as String? ?? '',
      institutionId: map['institutionId'] as String? ?? '',
      moduleKey: map['moduleKey'] as String? ?? '',
      requestType: map['requestType'] as String? ?? '',
      sourceRecordType: map['sourceRecordType'] as String? ?? '',
      sourceRecordId: map['sourceRecordId'] as String? ?? '',
      sourceRoute: map['sourceRoute'] as String? ?? '',
      title: map['title'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      requestedBy: map['requestedBy'] as String? ?? '',
      requesterRole: map['requesterRole'] as String? ?? '',
      currentStage: map['currentStage'] as String? ?? '',
      currentStatus: ApprovalStatusWire.parse(map['currentStatus']),
      priority: ApprovalPriority.values.firstWhere(
        (v) => v.name == map['priority'],
        orElse: () => ApprovalPriority.normal,
      ),
      sensitivity: ApprovalSensitivity.values.firstWhere(
        (v) => v.name == map['sensitivity'],
        orElse: () => ApprovalSensitivity.normal,
      ),
      approvalPolicyId: map['approvalPolicyId'] as String? ?? '',
      sourceRecordVersion: map['sourceRecordVersion']?.toString() ?? '',
      correlationId: map['correlationId'] as String? ?? '',
      createdAt: date('createdAt'),
      submittedAt: date('submittedAt'),
      requesterDepartment: map['requesterDepartment'] as String?,
      requesterCampus: map['requesterCampus'] as String?,
      requesterDivision: map['requesterDivision'] as String?,
      reason: map['reason'] as String?,
      amount: (map['amount'] as num?)?.toDouble(),
      oldValue: map['oldValue'] == null
          ? null
          : Map<String, dynamic>.from(map['oldValue'] as Map),
      proposedValue: map['proposedValue'] == null
          ? null
          : Map<String, dynamic>.from(map['proposedValue'] as Map),
      attachments: List<String>.from(map['attachments'] ?? const []),
      requiredApprovers: List<String>.from(
        map['requiredApprovers'] ?? const [],
      ),
      dueAt: map['dueAt'] == null ? null : date('dueAt'),
      resolvedAt: map['resolvedAt'] == null ? null : date('resolvedAt'),
      version: (map['version'] as num? ?? 1).toInt(),
    );
  }
  @override
  List<Object?> get props => [
    approvalRequestId,
    institutionId,
    moduleKey,
    requestType,
    sourceRecordId,
    currentStage,
    currentStatus,
    priority,
    sensitivity,
    version,
  ];
}

class ApprovalDelegation extends Equatable {
  final String delegationId,
      institutionId,
      delegatorId,
      delegateId,
      reason,
      status;
  final List<String> modules, requestTypes;
  final DateTime start, end;
  const ApprovalDelegation({
    required this.delegationId,
    required this.institutionId,
    required this.delegatorId,
    required this.delegateId,
    required this.reason,
    required this.status,
    required this.start,
    required this.end,
    this.modules = const [],
    this.requestTypes = const [],
  });
  bool get isActive =>
      status == 'active' &&
      start.isBefore(DateTime.now()) &&
      end.isAfter(DateTime.now());
  factory ApprovalDelegation.fromMap(Map<String, dynamic> map) {
    DateTime date(Object? v) {
      if (v is DateTime) return v;
      try {
        final converted = (v as dynamic).toDate();
        if (converted is DateTime) return converted;
      } catch (_) {}
      return DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    }

    return ApprovalDelegation(
      delegationId: map['delegationId'] as String? ?? '',
      institutionId: map['institutionId'] as String? ?? '',
      delegatorId: map['delegatorId'] as String? ?? '',
      delegateId: map['delegateId'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
      start: date(map['start']),
      end: date(map['end']),
      modules: List<String>.from(map['modules'] ?? const []),
      requestTypes: List<String>.from(map['requestTypes'] ?? const []),
    );
  }
  @override
  List<Object?> get props => [
    delegationId,
    institutionId,
    delegatorId,
    delegateId,
    status,
    start,
    end,
    modules,
    requestTypes,
  ];
}

class ApprovalAction extends Equatable {
  final String actionId, requestId, actorId, action, stage, comment;
  final DateTime timestamp;
  const ApprovalAction({
    required this.actionId,
    required this.requestId,
    required this.actorId,
    required this.action,
    required this.stage,
    required this.comment,
    required this.timestamp,
  });
  @override
  List<Object?> get props => [
    actionId,
    requestId,
    actorId,
    action,
    stage,
    comment,
    timestamp,
  ];
}
