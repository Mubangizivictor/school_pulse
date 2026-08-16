import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/institution_health/domain/institution_health_models.dart';
import 'package:school_pulse/features/institution_health/domain/institution_health_score_calculator.dart';

HealthCheckResult check({
  HealthSeverity severity = HealthSeverity.informational,
  HealthCheckStatus status = HealthCheckStatus.passed,
  int affected = 0,
  String category = 'Setup',
}) => HealthCheckResult(
  id: 'id',
  checkKey: 'key',
  institutionId: 'school-a',
  category: category,
  title: 'Check',
  description: '',
  severity: severity,
  status: status,
  affectedModule: '',
  affectedScope: '',
  affectedCount: affected,
  lastCheckedAt: null,
  sourceVersion: '',
  remediationRoute: '',
  canAutoFix: false,
  requiresPermission: '',
  details: const {},
  correlationId: '',
  resolutionState: HealthResolutionState.open,
  priority: 0,
);

void main() {
  group('InstitutionHealthScoreCalculator', () {
    test('does not penalize passed or informational checks', () {
      expect(
        InstitutionHealthScoreCalculator.score([
          check(),
          check(status: HealthCheckStatus.warning),
        ]),
        100,
      );
    });

    test('applies deterministic warning and critical penalties', () {
      expect(
        InstitutionHealthScoreCalculator.score([
          check(
            severity: HealthSeverity.medium,
            status: HealthCheckStatus.warning,
          ),
        ]),
        90,
      );
      expect(
        InstitutionHealthScoreCalculator.score([
          check(
            severity: HealthSeverity.critical,
            status: HealthCheckStatus.failed,
          ),
        ]),
        70,
      );
    });

    test('uses affected count and security impact for priority', () {
      final security = check(
        severity: HealthSeverity.high,
        status: HealthCheckStatus.failed,
        affected: 15,
        category: 'Security',
      );
      expect(InstitutionHealthScoreCalculator.penalty(security), 20);
      expect(InstitutionHealthScoreCalculator.priority(security), 815);
    });

    test('does not count resolved issues', () {
      final resolved = check(
        severity: HealthSeverity.critical,
        status: HealthCheckStatus.failed,
      );
      final result = HealthCheckResult(
        id: resolved.id,
        checkKey: resolved.checkKey,
        institutionId: resolved.institutionId,
        category: resolved.category,
        title: resolved.title,
        description: resolved.description,
        severity: resolved.severity,
        status: resolved.status,
        affectedModule: resolved.affectedModule,
        affectedScope: resolved.affectedScope,
        affectedCount: resolved.affectedCount,
        lastCheckedAt: resolved.lastCheckedAt,
        sourceVersion: resolved.sourceVersion,
        remediationRoute: resolved.remediationRoute,
        canAutoFix: resolved.canAutoFix,
        requiresPermission: resolved.requiresPermission,
        details: resolved.details,
        correlationId: resolved.correlationId,
        resolutionState: HealthResolutionState.resolved,
        priority: resolved.priority,
      );
      expect(InstitutionHealthScoreCalculator.score([result]), 100);
    });
  });
}
