import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/assessment_mark.dart';
import '../../domain/entities/assessment_type.dart';
import '../../domain/entities/grading_system.dart';
import '../../domain/entities/report_release_policy.dart';
import '../../domain/entities/report_template.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasources/assessment_remote_data_source.dart';
import '../models/assessment_mark_model.dart';
import '../models/assessment_type_model.dart';
import '../models/grading_system_model.dart';
import '../models/report_release_policy_model.dart';
import '../models/report_template_model.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  final AssessmentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AssessmentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AssessmentType>>> getAssessmentTypes(
    String schoolId,
  ) async {
    try {
      final remoteTypes = await remoteDataSource.getAssessmentTypes(schoolId);
      return Right(remoteTypes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAssessmentType(
    String schoolId,
    AssessmentType assessmentType,
  ) async {
    try {
      await remoteDataSource.createAssessmentType(
        schoolId,
        assessmentType as AssessmentTypeModel,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAssessmentType(
    AssessmentType assessmentType,
  ) async {
    // Implementation...
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<GradingSystem>>> getGradingSystems(
    String schoolId,
  ) async {
    try {
      final systems = await remoteDataSource.getGradingSystems(schoolId);
      return Right(systems);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createGradingSystem(
    GradingSystem gradingSystem,
  ) async {
    try {
      await remoteDataSource.createGradingSystem(
        gradingSystem as GradingSystemModel,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AssessmentMark>>> getMarks({
    required String schoolId,
    String? assessmentTypeId,
    String? subjectId,
    String? classId,
    String? studentId,
  }) async {
    try {
      final marks = await remoteDataSource.getMarks(
        schoolId: schoolId,
        assessmentTypeId: assessmentTypeId,
        subjectId: subjectId,
        classId: classId,
        studentId: studentId,
      );
      return Right(marks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveMarks(
    String schoolId,
    List<AssessmentMark> marks,
  ) async {
    try {
      final markModels = marks.map((m) => m as AssessmentMarkModel).toList();
      await remoteDataSource.saveMarks(schoolId, markModels);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitMarks(List<String> markIds) async {
    try {
      // In a real app, we'd get the current school ID from an Auth service
      // For now, we'll assume markIds are sufficient or we need to pass schoolId
      // Let's assume we update status to 'submitted'
      // We need a way to know which school these belong to,
      // usually it's in the app state.
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> moderateMarks(
    List<String> markIds,
    String moderatorId,
  ) async {
    try {
      // Implementation logic to call remoteDataSource.updateMarkStatus
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveMarks(
    List<String> markIds,
    String approverId,
  ) async {
    try {
      // Implementation logic to call remoteDataSource.updateMarkStatus
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportTemplate>>> getReportTemplates(
    String schoolId,
  ) async {
    try {
      final templates = await remoteDataSource.getReportTemplates(schoolId);
      return Right(templates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveReportTemplate(
    ReportTemplate template,
  ) async {
    try {
      await remoteDataSource.saveReportTemplate(
        template as ReportTemplateModel,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportReleasePolicy>> getReleasePolicy(
    String schoolId,
  ) async {
    try {
      final policy = await remoteDataSource.getReleasePolicy(schoolId);
      return Right(policy);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateReleasePolicy(
    ReportReleasePolicy policy,
  ) async {
    try {
      await remoteDataSource.updateReleasePolicy(
        policy as ReportReleasePolicyModel,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
