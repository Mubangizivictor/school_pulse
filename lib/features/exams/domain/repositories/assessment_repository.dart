import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/assessment_type.dart';
import '../entities/assessment_mark.dart';
import '../entities/report_template.dart';
import '../entities/report_release_policy.dart';

// Grading-system configuration lives solely in
// lib/features/structure/domain/entities/assessment_grading_entities.dart
// (GradingSystemDef/GradeBand) and is resolved via
// lib/features/structure/domain/services/grade_resolver.dart - this
// repository no longer duplicates that model.
abstract class AssessmentRepository {
  // Assessment Configuration
  Future<Either<Failure, List<AssessmentType>>> getAssessmentTypes(
    String schoolId,
  );
  Future<Either<Failure, void>> createAssessmentType(
    String schoolId,
    AssessmentType assessmentType,
  );
  Future<Either<Failure, void>> updateAssessmentType(
    AssessmentType assessmentType,
  );

  // Marks Entry
  Future<Either<Failure, List<AssessmentMark>>> getMarks({
    required String schoolId,
    String? assessmentTypeId,
    String? subjectId,
    String? classId,
    String? studentId,
  });
  Future<Either<Failure, void>> saveMarks(
    String schoolId,
    List<AssessmentMark> marks,
  );
  Future<Either<Failure, void>> submitMarks(List<String> markIds);

  // Moderation & Approval
  Future<Either<Failure, void>> moderateMarks(
    List<String> markIds,
    String moderatorId,
  );
  Future<Either<Failure, void>> approveMarks(
    List<String> markIds,
    String approverId,
  );

  // Report Templates & Policies
  Future<Either<Failure, List<ReportTemplate>>> getReportTemplates(
    String schoolId,
  );
  Future<Either<Failure, void>> saveReportTemplate(ReportTemplate template);
  Future<Either<Failure, ReportReleasePolicy>> getReleasePolicy(
    String schoolId,
  );
  Future<Either<Failure, void>> updateReleasePolicy(ReportReleasePolicy policy);
}
