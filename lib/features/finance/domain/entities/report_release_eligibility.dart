import 'package:equatable/equatable.dart';

/// The five learner-facing report-card release states surfaced by the Bursar
/// console. Mirrors `uiStatus` from the `getReportCardReleaseEligibility`
/// Cloud Function - the server is authoritative, this enum only drives
/// grouping and chip colour.
enum ReportReleaseUiStatus {
  automaticallyAvailable,
  withheldForFees,
  exceptionActive,
  exceptionExpired, // expired OR revoked (grouped)
  pendingApproval;

  static ReportReleaseUiStatus fromId(String? id) {
    switch (id) {
      case 'automaticallyAvailable':
        return ReportReleaseUiStatus.automaticallyAvailable;
      case 'withheldForFees':
        return ReportReleaseUiStatus.withheldForFees;
      case 'exceptionActive':
        return ReportReleaseUiStatus.exceptionActive;
      case 'exceptionExpired':
        return ReportReleaseUiStatus.exceptionExpired;
      case 'pendingApproval':
        return ReportReleaseUiStatus.pendingApproval;
      default:
        return ReportReleaseUiStatus.withheldForFees;
    }
  }

  String get label => switch (this) {
    ReportReleaseUiStatus.automaticallyAvailable => 'Automatically available',
    ReportReleaseUiStatus.withheldForFees => 'Withheld for fees',
    ReportReleaseUiStatus.exceptionActive => 'Exception active',
    ReportReleaseUiStatus.exceptionExpired => 'Exception expired/revoked',
    ReportReleaseUiStatus.pendingApproval => 'Pending second approval',
  };
}

/// Structured reason codes for a Bursar release exception. Matches the
/// `reasonCode` accepted by `grantReportCardReleaseException`.
enum ExceptionReasonCode {
  paymentPlan,
  scholarship,
  managementInstruction,
  hardship,
  staffBenefit,
  custom;

  static ExceptionReasonCode fromId(String? id) => switch (id) {
    'paymentPlan' => ExceptionReasonCode.paymentPlan,
    'scholarship' => ExceptionReasonCode.scholarship,
    'managementInstruction' => ExceptionReasonCode.managementInstruction,
    'hardship' => ExceptionReasonCode.hardship,
    'staffBenefit' => ExceptionReasonCode.staffBenefit,
    _ => ExceptionReasonCode.custom,
  };

  String get id => name;

  String get label => switch (this) {
    ExceptionReasonCode.paymentPlan => 'Payment plan',
    ExceptionReasonCode.scholarship => 'Scholarship',
    ExceptionReasonCode.managementInstruction => 'Management instruction',
    ExceptionReasonCode.hardship => 'Hardship',
    ExceptionReasonCode.staffBenefit => 'Staff benefit',
    ExceptionReasonCode.custom => 'Custom reason',
  };
}

/// One redacted audit entry on a release exception (safe for staff display -
/// carries names, never raw uids).
class ExceptionAuditEntry extends Equatable {
  final String action;
  final String actorName;
  final String? note;
  final String? fromStatus;
  final String? toStatus;
  final DateTime? at;

  const ExceptionAuditEntry({
    required this.action,
    required this.actorName,
    this.note,
    this.fromStatus,
    this.toStatus,
    this.at,
  });

  factory ExceptionAuditEntry.fromMap(Map<String, dynamic> m) =>
      ExceptionAuditEntry(
        action: m['action'] as String? ?? '',
        actorName: m['actorName'] as String? ?? 'Staff',
        note: m['note'] as String?,
        fromStatus: m['fromStatus'] as String?,
        toStatus: m['toStatus'] as String?,
        at: _millis(m['at']),
      );

  @override
  List<Object?> get props => [
    action,
    actorName,
    note,
    fromStatus,
    toStatus,
    at,
  ];
}

/// A release exception as surfaced to the Bursar console.
class ReportReleaseException extends Equatable {
  final String id;
  final String status; // pendingApproval | active | expired | revoked
  final ExceptionReasonCode reasonCode;
  final String? reasonNote;
  final int outstandingBalanceUgxAtRelease;
  final String? clearancePolicyModeAtRelease;
  final DateTime? expiresAt;
  final String? createdByName;
  final DateTime? createdAt;
  final String? authorisedByName;
  final DateTime? authorisedAt;
  final DateTime? consumedAt;
  final String? renewedFromExceptionId;
  final String? supersededByExceptionId;
  final List<ExceptionAuditEntry> auditTrail;

  const ReportReleaseException({
    required this.id,
    required this.status,
    required this.reasonCode,
    this.reasonNote,
    this.outstandingBalanceUgxAtRelease = 0,
    this.clearancePolicyModeAtRelease,
    this.expiresAt,
    this.createdByName,
    this.createdAt,
    this.authorisedByName,
    this.authorisedAt,
    this.consumedAt,
    this.renewedFromExceptionId,
    this.supersededByExceptionId,
    this.auditTrail = const [],
  });

  bool get isConsumed => consumedAt != null;

  factory ReportReleaseException.fromMap(Map<String, dynamic> m) =>
      ReportReleaseException(
        id: m['id'] as String? ?? '',
        status: m['status'] as String? ?? 'active',
        reasonCode: ExceptionReasonCode.fromId(m['reasonCode'] as String?),
        reasonNote: m['reasonNote'] as String?,
        outstandingBalanceUgxAtRelease:
            (m['outstandingBalanceUgxAtRelease'] as num?)?.toInt() ?? 0,
        clearancePolicyModeAtRelease:
            m['clearancePolicyModeAtRelease'] as String?,
        expiresAt: _millis(m['expiresAt']),
        createdByName: m['createdByName'] as String?,
        createdAt: _millis(m['createdAt']),
        authorisedByName: m['authorisedByName'] as String?,
        authorisedAt: _millis(m['authorisedAt']),
        consumedAt: _millis(m['consumedAt']),
        renewedFromExceptionId: m['renewedFromExceptionId'] as String?,
        supersededByExceptionId: m['supersededByExceptionId'] as String?,
        auditTrail: ((m['auditTrail'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => ExceptionAuditEntry.fromMap(e.cast<String, dynamic>()))
            .toList(),
      );

  @override
  List<Object?> get props => [
    id,
    status,
    reasonCode,
    reasonNote,
    outstandingBalanceUgxAtRelease,
    expiresAt,
    createdByName,
    createdAt,
    authorisedByName,
    authorisedAt,
    consumedAt,
    renewedFromExceptionId,
    supersededByExceptionId,
    auditTrail,
  ];
}

/// The server-computed clearance result for one learner/period.
class ClearanceResult extends Equatable {
  final bool cleared;
  final String mode; // fullBalance | selectedCategories | minimumPercentage
  final int balanceUgx;
  final double? percentPaid;
  final int billCount;

  const ClearanceResult({
    required this.cleared,
    required this.mode,
    required this.balanceUgx,
    this.percentPaid,
    this.billCount = 0,
  });

  factory ClearanceResult.fromMap(Map<String, dynamic> m) => ClearanceResult(
    cleared: m['cleared'] as bool? ?? false,
    mode: m['mode'] as String? ?? 'fullBalance',
    balanceUgx: (m['balanceUgx'] as num?)?.toInt() ?? 0,
    percentPaid: (m['percentPaid'] as num?)?.toDouble(),
    billCount: (m['billCount'] as num?)?.toInt() ?? 0,
  );

  String get summary => switch (mode) {
    'minimumPercentage' =>
      '${percentPaid?.toStringAsFixed(0) ?? '0'}% paid'
          '${cleared ? ' · meets policy' : ' · below policy'}',
    'selectedCategories' =>
      cleared ? 'Selected fees cleared' : 'Selected fees outstanding',
    _ => cleared ? 'Full balance cleared' : 'Balance outstanding',
  };

  @override
  List<Object?> get props => [
    cleared,
    mode,
    balanceUgx,
    percentPaid,
    billCount,
  ];
}

/// One row of the Bursar Report Card Releases list.
class ReportReleaseEligibilityRow extends Equatable {
  final String reportCardId;
  final String studentId;
  final String studentName;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final String termId;
  final int version;
  final String financialAccessStatus; // held | released | revoked
  final String financialAccessSource; // auto | exception | bursar
  final ReportReleaseUiStatus uiStatus;
  final int balanceUgx;
  final ClearanceResult clearance;
  final String restrictionMessage;
  final ReportReleaseException? exception;

  const ReportReleaseEligibilityRow({
    required this.reportCardId,
    required this.studentId,
    required this.studentName,
    required this.classId,
    this.streamId,
    required this.academicYearId,
    required this.termId,
    this.version = 1,
    required this.financialAccessStatus,
    required this.financialAccessSource,
    required this.uiStatus,
    required this.balanceUgx,
    required this.clearance,
    this.restrictionMessage = '',
    this.exception,
  });

  bool get isBursarOverride => financialAccessSource == 'bursar';

  String get periodLabel => 'Term $termId · $academicYearId';

  factory ReportReleaseEligibilityRow.fromMap(Map<String, dynamic> m) =>
      ReportReleaseEligibilityRow(
        reportCardId: m['reportCardId'] as String? ?? '',
        studentId: m['studentId'] as String? ?? '',
        studentName: m['studentName'] as String? ?? 'Learner',
        classId: m['classId'] as String? ?? '',
        streamId: m['streamId'] as String?,
        academicYearId: m['academicYearId'] as String? ?? '',
        termId: m['termId'] as String? ?? '',
        version: (m['version'] as num?)?.toInt() ?? 1,
        financialAccessStatus: m['financialAccessStatus'] as String? ?? 'held',
        financialAccessSource: m['financialAccessSource'] as String? ?? 'auto',
        uiStatus: ReportReleaseUiStatus.fromId(m['uiStatus'] as String?),
        balanceUgx: (m['balanceUgx'] as num?)?.toInt() ?? 0,
        clearance: ClearanceResult.fromMap(
          (m['clearance'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        restrictionMessage: m['restrictionMessage'] as String? ?? '',
        exception: (m['exception'] as Map?) != null
            ? ReportReleaseException.fromMap(
                (m['exception'] as Map).cast<String, dynamic>(),
              )
            : null,
      );

  @override
  List<Object?> get props => [
    reportCardId,
    studentId,
    studentName,
    classId,
    streamId,
    academicYearId,
    termId,
    version,
    financialAccessStatus,
    financialAccessSource,
    uiStatus,
    balanceUgx,
    clearance,
    restrictionMessage,
    exception,
  ];
}

DateTime? _millis(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
  return null;
}
