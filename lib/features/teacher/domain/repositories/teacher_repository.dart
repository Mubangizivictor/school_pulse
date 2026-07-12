import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/enums/student_status.dart';
import '../../presentation/bloc/teacher_state.dart';
import '../entities/teacher_dashboard_stats.dart';
import '../usecases/get_attendance_history.dart';

abstract class TeacherRepository {
  Future<Either<Failure, List<TeacherStudent>>> getStudentsByClass(String className);
  
  Future<Either<Failure, void>> submitAttendance({
    required String className,
    required DateTime date,
    required Map<String, StudentStatus> attendance,
  });

  Future<Either<Failure, List<AttendanceHistoryRecord>>> getAttendanceHistory(String teacherId);

  Future<Either<Failure, TeacherDashboardStats>> getTeacherDashboardStats(String teacherId);
}
