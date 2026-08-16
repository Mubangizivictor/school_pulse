import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/academic_dashboard_stats.dart';
import '../../domain/entities/academic_intervention.dart';
import '../../domain/entities/class_observation.dart';
import '../../domain/entities/curriculum.dart';
import '../../domain/entities/lesson_tracking.dart';
import '../../domain/entities/teacher_workload.dart';
import '../../domain/entities/homework_record.dart';
import '../../domain/entities/assessment_moderation.dart';
import '../../domain/repositories/dean_repository.dart';
import '../datasources/dean_remote_data_source.dart';

class DeanRepositoryImpl implements DeanRepository {
  final DeanRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DeanRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AcademicDashboardStats>>
  getAcademicDashboardStats() async {
    return _callRemote(() => remoteDataSource.getDeanDashboardStats());
  }

  @override
  Future<Either<Failure, List<Curriculum>>> getCurricula() async {
    return _callRemote(() => remoteDataSource.getCurricula());
  }

  @override
  Future<Either<Failure, void>> updateCurriculum(Curriculum curriculum) async {
    return _callRemote(() => remoteDataSource.updateCurriculum(curriculum));
  }

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async {
    return _callRemote(() => remoteDataSource.getSubjects());
  }

  @override
  Future<Either<Failure, void>> updateSubjectAllocation(
    String subjectId,
    List<String> teacherIds,
  ) async {
    return _callRemote(
      () => remoteDataSource.updateSubjectAllocation(subjectId, teacherIds),
    );
  }

  @override
  Future<Either<Failure, List<TeacherWorkload>>> getTeacherWorkloads() async {
    return _callRemote(() => remoteDataSource.getTeacherWorkloads());
  }

  @override
  Future<Either<Failure, TeacherWorkload>> getTeacherWorkloadDetail(
    String teacherId,
  ) async {
    return _callRemote(
      () => remoteDataSource.getTeacherWorkloadDetail(teacherId),
    );
  }

  @override
  Future<Either<Failure, List<LessonRecord>>> getLessonRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? teacherId,
    String? classId,
    LessonStatus? status,
  }) async {
    return _callRemote(
      () => remoteDataSource.getLessonRecords(
        startDate: startDate,
        endDate: endDate,
        teacherId: teacherId,
        classId: classId,
        status: status,
      ),
    );
  }

  @override
  Future<Either<Failure, List<HomeworkRecord>>> getHomeworkRecords({
    String? classId,
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _callRemote(
      () => remoteDataSource.getHomeworkRecords(
        classId: classId,
        teacherId: teacherId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> approveAssessmentMarks(
    String assessmentId,
  ) async {
    return _callRemote(
      () => remoteDataSource.approveAssessmentMarks(assessmentId),
    );
  }

  @override
  Future<Either<Failure, void>> rejectAssessmentMarks(
    String assessmentId,
    String reason,
  ) async {
    return _callRemote(
      () => remoteDataSource.rejectAssessmentMarks(assessmentId, reason),
    );
  }

  @override
  Future<Either<Failure, List<AssessmentModeration>>>
  getPendingModerationAssessments() async {
    return _callRemote(
      () => remoteDataSource.getPendingModerationAssessments(),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceAnalytics({
    required String type,
    String? id,
    String? academicYear,
    String? term,
  }) async {
    return _callRemote(
      () => remoteDataSource.getPerformanceAnalytics(
        type: type,
        id: id,
        academicYear: academicYear,
        term: term,
      ),
    );
  }

  @override
  Future<Either<Failure, List<AcademicIntervention>>> getInterventions() async {
    return _callRemote(() => remoteDataSource.getInterventions());
  }

  @override
  Future<Either<Failure, void>> createIntervention(
    AcademicIntervention intervention,
  ) async {
    return _callRemote(() => remoteDataSource.createIntervention(intervention));
  }

  @override
  Future<Either<Failure, void>> updateInterventionStatus(
    String id,
    InterventionStatus status,
    String outcomes,
  ) async {
    return _callRemote(
      () => remoteDataSource.updateInterventionStatus(id, status, outcomes),
    );
  }

  @override
  Future<Either<Failure, List<ClassObservation>>> getClassObservations() async {
    return _callRemote(() => remoteDataSource.getClassObservations());
  }

  @override
  Future<Either<Failure, void>> recordObservation(
    ClassObservation observation,
  ) async {
    return _callRemote(() => remoteDataSource.recordObservation(observation));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMasterTimetable() async {
    return _callRemote(() => remoteDataSource.getMasterTimetable());
  }

  @override
  Future<Either<Failure, List<dynamic>>> getExaminationSchedules() async {
    return _callRemote(() => remoteDataSource.getExaminationSchedules());
  }

  @override
  Future<Either<Failure, void>> sendAcademicAnnouncement({
    required String title,
    required String message,
    required List<String> targetRoles,
    List<String>? targetIds,
  }) async {
    return _callRemote(
      () => remoteDataSource.sendAcademicAnnouncement(
        title: title,
        message: message,
        targetRoles: targetRoles,
        targetIds: targetIds,
      ),
    );
  }

  Future<Either<Failure, T>> _callRemote<T>(Future<T> Function() call) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
