import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/assessment_type.dart';
import '../entities/grading_system.dart';
import '../entities/assessment_mark.dart';
import '../entities/report_template.dart';
import '../entities/report_release_policy.dart';

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

  // Grading Systems
  Future<Either<Failure, List<GradingSystem>>> getGradingSystems(
    String schoolId,
  );
  Future<Either<Failure, void>> createGradingSystem(
    GradingSystem gradingSystem,
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
