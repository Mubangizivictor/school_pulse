import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/enums/student_status.dart';
import '../../presentation/bloc/teacher_state.dart';
import '../entities/teacher_dashboard_stats.dart';
import '../usecases/get_attendance_history.dart';

import '../entities/homework.dart';
import '../entities/report_comment.dart';
import '../entities/competency_rating.dart';

abstract class TeacherRepository {
  Future<Either<Failure, List<TeacherStudent>>> getStudentsByClass(String className);
  
  Future<Either<Failure, void>> submitAttendance({
    required String className,
    required DateTime date,
    required Map<String, StudentStatus> attendance,
  });

  Future<Either<Failure, void>> submitMarks({
    required String className,
    required String subject,
    required String assessment,
    required String term,
    required String year,
    required Map<String, double> marks,
  });

  Future<Either<Failure, List<AttendanceHistoryRecord>>> getAttendanceHistory(String teacherId);

  Future<Either<Failure, TeacherDashboardStats>> getTeacherDashboardStats(String teacherId);

  // Homework
  Future<Either<Failure, List<Homework>>> getHomework(String teacherId);
  Future<Either<Failure, void>> createHomework(Homework homework);
  Future<Either<Failure, void>> updateHomework(Homework homework);
  Future<Either<Failure, void>> deleteHomework(String homeworkId);

  // Report Comments
  Future<Either<Failure, List<ReportComment>>> getReportComments({
    required String className,
    required String term,
    required String year,
  });
  Future<Either<Failure, void>> saveReportComment(ReportComment comment);

  // Competency Ratings
  Future<Either<Failure, List<CompetencyRating>>> getCompetencyRatings({
    required String className,
    required String term,
    required String year,
    required String competency,
  });
  Future<Either<Failure, void>> saveCompetencyRating(CompetencyRating rating);

  // Report Generation
  Future<Either<Failure, void>> generateReports({
    required String className,
    required String term,
    required String year,
    required List<String> studentIds,
    required List<String> enabledSections,
  });
}
