import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'package:school_pulse/features/teacher/domain/entities/homework.dart';
import 'package:school_pulse/features/teacher/domain/entities/report_comment.dart';
import 'package:school_pulse/features/teacher/domain/entities/competency_rating.dart';
import 'package:school_pulse/features/teacher/data/datasources/teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/teacher_dashboard_stats.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_attendance_history.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;

  TeacherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TeacherStudent>>> getStudentsByClass(
    String className,
  ) async {
    try {
      final students = await remoteDataSource.getStudentsByClass(className);
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitAttendance({
    required String schoolId,
    required String className,
    required DateTime date,
    required Map<String, StudentStatus> attendance,
  }) async {
    try {
      await remoteDataSource.submitAttendance(
        schoolId: schoolId,
        className: className,
        date: date,
        attendance: attendance.map((key, value) => MapEntry(key, value.name)),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitMarks({
    required String className,
    required String subject,
    required String assessment,
    required String term,
    required String year,
    required Map<String, double> marks,
  }) async {
    try {
      await remoteDataSource.submitMarks(
        className: className,
        subject: subject,
        assessment: assessment,
        term: term,
        year: year,
        marks: marks,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceHistoryRecord>>> getAttendanceHistory(
    String teacherId,
  ) async {
    try {
      final history = await remoteDataSource.getAttendanceHistory(teacherId);
      return Right(history);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TeacherDashboardStats>> getTeacherDashboardStats(
    String teacherId,
  ) async {
    try {
      final stats = await remoteDataSource.getTeacherDashboardStats(teacherId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Homework>>> getHomework(
    String schoolId,
    String teacherId,
  ) async {
    try {
      final homeworkList = await remoteDataSource.getHomework(
        schoolId,
        teacherId,
      );
      return Right(homeworkList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createHomework(Homework homework) async {
    try {
      await remoteDataSource.createHomework(homework);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateHomework(Homework homework) async {
    try {
      await remoteDataSource.updateHomework(homework);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHomework(String homeworkId) async {
    try {
      await remoteDataSource.deleteHomework(homeworkId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportComment>>> getReportComments({
    required String className,
    required String term,
    required String year,
  }) async {
    try {
      final comments = await remoteDataSource.getReportComments(
        className: className,
        term: term,
        year: year,
      );
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveReportComment(ReportComment comment) async {
    try {
      await remoteDataSource.saveReportComment(comment);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetencyRating>>> getCompetencyRatings({
    required String className,
    required String term,
    required String year,
    required String competency,
  }) async {
    try {
      final ratings = await remoteDataSource.getCompetencyRatings(
        className: className,
        term: term,
        year: year,
        competency: competency,
      );
      return Right(ratings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveCompetencyRating(
    CompetencyRating rating,
  ) async {
    try {
      await remoteDataSource.saveCompetencyRating(rating);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> generateReports({
    required String className,
    required String term,
    required String year,
    required List<String> studentIds,
    required List<String> enabledSections,
  }) async {
    try {
      await remoteDataSource.generateReports(
        className: className,
        term: term,
        year: year,
        studentIds: studentIds,
        enabledSections: enabledSections,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
