import '../entities/assessment_grading_entities.dart';

/// The single deterministic resolver for Structure grading definitions.
/// Numeric bounds are inclusive. Configuration validation prevents overlap,
/// so a score can resolve to at most one level.
class GradeResolver {
  const GradeResolver();

  GradeResolution resolveScore({
    required num score,
    required GradingSystemDef system,
    required Iterable<GradeBand> ranges,
  }) {
    final matching =
        ranges
            .where(
              (range) =>
                  range.gradingSystemId == system.id &&
                  // Defense-in-depth: even if a caller accidentally passes
                  // in an unscoped band list, a cross-tenant gradingSystemId
                  // collision (unlikely with UUIDs, but not structurally
                  // impossible) can never leak another school's grade into
                  // this resolution.
                  range.schoolId == system.schoolId &&
                  range.hasNumericBoundary &&
                  score >= range.minScore &&
                  score <= range.maxScore,
            )
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    if (matching.isEmpty) {
      return GradeResolution.unresolved(score.toDouble());
    }
    final range = matching.first;
    return GradeResolution(
      rawScore: score.toDouble(),
      gradeCode: range.grade,
      gradeLabel: range.label.isEmpty ? range.grade : range.label,
      descriptor: range.remarks,
      gradePoint: range.gradePoint,
      isPassing: range.isPassing,
    );
  }

  GradeResolution resolveDescriptor({
    required String gradeCode,
    required GradingSystemDef system,
    required Iterable<GradeBand> ranges,
  }) {
    final range = ranges
        .where(
          (item) =>
              item.grade == gradeCode &&
              item.gradingSystemId == system.id &&
              item.schoolId == system.schoolId,
        )
        .firstOrNull;
    if (range == null) return GradeResolution.unresolved(null);
    return GradeResolution(
      rawScore: null,
      gradeCode: range.grade,
      gradeLabel: range.label.isEmpty ? range.grade : range.label,
      descriptor: range.remarks,
      gradePoint: range.gradePoint,
      isPassing: range.isPassing,
    );
  }
}

class GradeResolution {
  final double? rawScore;
  final String? gradeCode;
  final String? gradeLabel;
  final String? descriptor;
  final double? gradePoint;
  final bool? isPassing;

  const GradeResolution({
    required this.rawScore,
    required this.gradeCode,
    required this.gradeLabel,
    required this.descriptor,
    required this.gradePoint,
    required this.isPassing,
  });
  factory GradeResolution.unresolved(double? score) => GradeResolution(
    rawScore: score,
    gradeCode: null,
    gradeLabel: null,
    descriptor: null,
    gradePoint: null,
    isPassing: null,
  );
}
