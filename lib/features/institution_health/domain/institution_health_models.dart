import 'package:cloud_firestore/cloud_firestore.dart';

enum HealthSeverity { informational, low, medium, high, critical }

enum HealthCheckStatus {
  passed,
  warning,
  failed,
  unknown,
  notApplicable,
  checking,
  stale,
}

enum HealthResolutionState {
  open,
  acknowledged,
  inProgress,
  resolved,
  ignored,
  recurring,
}

enum InstitutionHealthStatus {
  excellent,
  good,
  needsAttention,
  atRisk,
  critical,
  unknown,
}

HealthSeverity healthSeverityFromValue(String? value) =>
    HealthSeverity.values.firstWhere(
      (item) => item.name == value,
      orElse: () => HealthSeverity.informational,
    );

HealthCheckStatus healthCheckStatusFromValue(String? value) =>
    HealthCheckStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => HealthCheckStatus.unknown,
    );

HealthResolutionState healthResolutionStateFromValue(String? value) =>
    HealthResolutionState.values.firstWhere(
      (item) => item.name == value,
      orElse: () => HealthResolutionState.open,
    );

InstitutionHealthStatus institutionHealthStatusFromScore(int? score) {
  if (score == null) return InstitutionHealthStatus.unknown;
  if (score >= 90) return InstitutionHealthStatus.excellent;
  if (score >= 75) return InstitutionHealthStatus.good;
  if (score >= 55) return InstitutionHealthStatus.needsAttention;
  if (score >= 30) return InstitutionHealthStatus.atRisk;
  return InstitutionHealthStatus.critical;
}

DateTime? healthDate(dynamic value) => switch (value) {
  Timestamp timestamp => timestamp.toDate(),
  DateTime date => date,
  _ => null,
};

/// Server-written aggregate. Scores are never fabricated in the UI: a missing
/// aggregate remains [unknown], which keeps stale/offline data honest.
class InstitutionHealthScore {
  const InstitutionHealthScore({
    required this.institutionId,
    required this.overallScore,
    required this.readinessScore,
    required this.securityScore,
    required this.dataQualityScore,
    required this.integrationScore,
    required this.syncScore,
    required this.subscriptionScore,
    required this.academicSetupScore,
    required this.calculatedAt,
    required this.scoreVersion,
    required this.sourceVersions,
  });

  final String institutionId;
  final int? overallScore;
  final int? readinessScore;
  final int? securityScore;
  final int? dataQualityScore;
  final int? integrationScore;
  final int? syncScore;
  final int? subscriptionScore;
  final int? academicSetupScore;
  final DateTime? calculatedAt;
  final String scoreVersion;
  final Map<String, dynamic> sourceVersions;

  InstitutionHealthStatus get status =>
      institutionHealthStatusFromScore(overallScore);

  bool get isStale =>
      calculatedAt == null ||
      DateTime.now().difference(calculatedAt!).inHours >= 24;

  factory InstitutionHealthScore.fromMap(
    String institutionId,
    Map<String, dynamic> data,
  ) => InstitutionHealthScore(
    institutionId: institutionId,
    overallScore: (data['overallScore'] as num?)?.round(),
    readinessScore: (data['readinessScore'] as num?)?.round(),
    securityScore: (data['securityScore'] as num?)?.round(),
    dataQualityScore: (data['dataQualityScore'] as num?)?.round(),
    integrationScore: (data['integrationScore'] as num?)?.round(),
    syncScore: (data['syncScore'] as num?)?.round(),
    subscriptionScore: (data['subscriptionScore'] as num?)?.round(),
    academicSetupScore: (data['academicSetupScore'] as num?)?.round(),
    calculatedAt: healthDate(data['calculatedAt']),
    scoreVersion: data['scoreVersion'] as String? ?? '',
    sourceVersions: Map<String, dynamic>.from(
      data['sourceVersions'] as Map? ?? const {},
    ),
  );
}

class HealthCheckResult {
  const HealthCheckResult({
    required this.id,
    required this.checkKey,
    required this.institutionId,
    required this.category,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.affectedModule,
    required this.affectedScope,
    required this.affectedCount,
    required this.lastCheckedAt,
    required this.sourceVersion,
    required this.remediationRoute,
    required this.canAutoFix,
    required this.requiresPermission,
    required this.details,
    required this.correlationId,
    required this.resolutionState,
    required this.priority,
  });
  final String id,
      checkKey,
      institutionId,
      category,
      title,
      description,
      affectedModule,
      affectedScope,
      sourceVersion,
      remediationRoute,
      requiresPermission,
      correlationId;
  final HealthSeverity severity;
  final HealthCheckStatus status;
  final int affectedCount;
  final DateTime? lastCheckedAt;
  final bool canAutoFix;
  final Map<String, dynamic> details;
  final HealthResolutionState resolutionState;
  final int priority;

  bool get actionable =>
      status == HealthCheckStatus.failed ||
      status == HealthCheckStatus.warning ||
      status == HealthCheckStatus.stale;

  factory HealthCheckResult.fromMap(String id, Map<String, dynamic> data) =>
      HealthCheckResult(
        id: id,
        checkKey: data['checkKey'] as String? ?? id,
        institutionId: data['institutionId'] as String? ?? '',
        category: data['category'] as String? ?? 'Operations',
        title: data['title'] as String? ?? 'Health check',
        description: data['description'] as String? ?? '',
        severity: healthSeverityFromValue(data['severity'] as String?),
        status: healthCheckStatusFromValue(data['status'] as String?),
        affectedModule: data['affectedModule'] as String? ?? '',
        affectedScope: data['affectedScope'] as String? ?? '',
        affectedCount: (data['affectedCount'] as num?)?.round() ?? 0,
        lastCheckedAt: healthDate(data['lastCheckedAt']),
        sourceVersion: data['sourceVersion'] as String? ?? '',
        remediationRoute: data['remediationRoute'] as String? ?? '',
        canAutoFix: data['canAutoFix'] == true,
        requiresPermission: data['requiresPermission'] as String? ?? '',
        details: Map<String, dynamic>.from(data['details'] as Map? ?? const {}),
        correlationId: data['correlationId'] as String? ?? '',
        resolutionState: healthResolutionStateFromValue(
          data['resolutionState'] as String?,
        ),
        priority: (data['priority'] as num?)?.round() ?? 0,
      );
}
