import 'institution_health_models.dart';

/// Shared deterministic scoring contract used by server jobs. The app only
/// displays their persisted result, never recomputes from operational data.
class InstitutionHealthScoreCalculator {
  const InstitutionHealthScoreCalculator._();

  static int penalty(HealthCheckResult check) {
    if (!check.actionable ||
        check.resolutionState == HealthResolutionState.resolved) {
      return 0;
    }
    final base = switch (check.severity) {
      HealthSeverity.critical => 30,
      HealthSeverity.high => 18,
      HealthSeverity.medium => 10,
      HealthSeverity.low => 4,
      HealthSeverity.informational => 0,
    };
    return base +
        (check.affectedCount > 50
            ? 4
            : check.affectedCount > 10
            ? 2
            : 0);
  }

  static int score(Iterable<HealthCheckResult> checks) =>
      (100 - checks.fold<int>(0, (total, check) => total + penalty(check)))
          .clamp(0, 100);

  static int priority(HealthCheckResult check) =>
      switch (check.severity) {
        HealthSeverity.critical => 1000,
        HealthSeverity.high => 700,
        HealthSeverity.medium => 400,
        HealthSeverity.low => 150,
        HealthSeverity.informational => 0,
      } +
      (check.affectedCount.clamp(0, 99)) +
      (check.category == 'Security' ? 100 : 0);
}
