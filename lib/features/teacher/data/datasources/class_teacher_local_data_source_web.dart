import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/entities/class_dashboard_summary.dart';
import 'class_teacher_local_data_source.dart';
import 'class_teacher_remote_data_source.dart';

ClassTeacherLocalDataSource create({dynamic isar, dynamic remote}) =>
    ClassTeacherLocalDataSourceWeb(remote as ClassTeacherRemoteDataSource);

/// No local database on web. Roster/dashboard get*/cache* are not on any
/// real read path (the repository always calls remote first when
/// connected, which is the only state web has), so get* returns
/// empty/null and cache* is a no-op - mirroring
/// StructureLocalDataSourceWeb's reasoning. There is also no Firestore
/// mirror for attendance drafts (they are mobile-only local-first state
/// by design), so getAttendanceDraft always misses and
/// saveAttendanceDraft is a no-op: a web teacher does not get the
/// "survives app kill mid-lesson" protection mobile has (documented
/// difference, not a bug - the real submission still goes through the
/// normal attendance-submission flow).
class ClassTeacherLocalDataSourceWeb implements ClassTeacherLocalDataSource {
  final ClassTeacherRemoteDataSource remote;

  ClassTeacherLocalDataSourceWeb(this.remote);

  @override
  Future<List<ClassStudentSummary>> getClassStudents({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async => [];

  @override
  Future<ClassStudentSummary?> getClassStudent(String studentId) async => null;

  @override
  Future<void> cacheClassStudents(
    List<ClassStudentSummary> students, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {}

  @override
  Future<ClassDashboardSummary?> getDashboard({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async => null;

  @override
  Future<void> cacheDashboard(
    ClassDashboardSummary dashboard, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {}

  @override
  Future<ClassAttendanceSession?> getAttendanceDraft(
    String sessionId, {
    required String schoolId,
  }) async => null;

  @override
  Future<void> saveAttendanceDraft(ClassAttendanceSession session) async {}

  @override
  Future<void> clear({String? schoolId}) async {}
}
