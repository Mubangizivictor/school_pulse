import 'institution_policy.dart';

class PolicyResolver {
  const PolicyResolver();
  InstitutionPolicy? resolve(
    Iterable<InstitutionPolicy> policies,
    InstitutionPolicyType type, {
    String? campusId,
    String? divisionId,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final candidates = policies
        .where(
          (p) =>
              p.type == type &&
              p.status == PolicyStatus.active &&
              !p.effectiveFrom.isAfter(now) &&
              (p.effectiveTo == null || p.effectiveTo!.isAfter(now)),
        )
        .where(
          (p) =>
              p.scope.type == PolicyScopeType.institution ||
              (p.scope.type == PolicyScopeType.campus &&
                  p.scope.targetId == campusId) ||
              (p.scope.type == PolicyScopeType.division &&
                  p.scope.targetId == divisionId),
        )
        .toList();
    candidates.sort((a, b) {
      int specificity(InstitutionPolicy p) =>
          p.scope.type == PolicyScopeType.institution ? 0 : 1;
      final result = specificity(b).compareTo(specificity(a));
      return result != 0 ? result : b.version.compareTo(a.version);
    });
    return candidates.isEmpty ? null : candidates.first;
  }
}
