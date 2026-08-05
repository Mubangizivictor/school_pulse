import '../entities/assessment_mark.dart';
import '../entities/assessment_type.dart';
import '../entities/grading_system.dart';
import '../entities/subject_result.dart';

/// Automatically calculates totals, percentage, grade and grade point from
/// a student's raw AssessmentMarks - no manual calculation, ever. The same
/// engine works for percentage, letter-grade, competency-based, grade-point
/// or pass/fail schools because grading is fully data-driven via
/// [GradingSystem].
class CalculationEngine {
  static SubjectResult calculateSubjectResult({
    required String subjectId,
    required String subjectName,
    required List<AssessmentMark> marks,
    required List<AssessmentType> assessmentTypes,
    required GradingSystem gradingSystem,
    required String teacherName,
    String? teacherSignatureUrl,
    int? subjectPosition,
  }) {
    double totalWeightedMark = 0;
    Map<String, double> assessmentScores = {};

    for (var type in assessmentTypes) {
      AssessmentMark? mark;
      for (final m in marks) {
        if (m.assessmentTypeId == type.id) {
          mark = m;
          break;
        }
      }

      double score = mark?.score ?? 0;
      assessmentScores[type.id] = score;

      // Contribution to final mark based on weight: (score / maxMark) * weight
      if (type.maxMark > 0) {
        totalWeightedMark += (score / type.maxMark) * type.weight;
      }
    }

    final gradeRange = _getGradeRange(totalWeightedMark, gradingSystem);

    return SubjectResult(
      subjectId: subjectId,
      subjectName: subjectName,
      assessmentScores: assessmentScores,
      totalMark: totalWeightedMark, // This is the weighted total
      percentage: totalWeightedMark, // Assuming assessment weights sum to 100
      grade: gradeRange.grade,
      gradePoint: gradeRange.gradePoint,
      remarks: gradeRange.remarks,
      subjectPosition: subjectPosition,
      teacherName: teacherName,
      teacherSignatureUrl: teacherSignatureUrl,
    );
  }

  static GradeRange _getGradeRange(double score, GradingSystem gradingSystem) {
    for (var range in gradingSystem.ranges) {
      if (score >= range.minScore && score <= range.maxScore) {
        return range;
      }
    }
    return const GradeRange(
      grade: 'Ungraded',
      minScore: 0,
      maxScore: 0,
      remarks: 'No matching grade range configured',
    );
  }

  static double calculateOverallAverage(List<SubjectResult> results) {
    if (results.isEmpty) return 0;
    double sum = results.fold(0, (prev, element) => prev + element.percentage);
    return sum / results.length;
  }
}
