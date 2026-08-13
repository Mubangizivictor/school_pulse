import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/entities/subject_enrollment.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/offline_operation.dart';
import 'subject_teacher_local_data_source.dart';

SubjectTeacherLocalDataSource create({dynamic isar, dynamic remote}) =>
    const SubjectTeacherLocalDataSourceWeb();

/// No local database on web. Assignment/enrollment/lesson get* calls are
/// not on any real read path (the repositories always fetch remote first
/// when connected, which is the only state web has - mirroring
/// StructureLocalDataSourceWeb's reasoning), so they return empty and
/// cache* is a no-op. There is no offline use case on web for the generic
/// operation queue, so enqueueOperation/etc. are no-ops/empty too.
class SubjectTeacherLocalDataSourceWeb
    implements SubjectTeacherLocalDataSource {
  const SubjectTeacherLocalDataSourceWeb();

  @override
  Future<List<StaffRoleAssignment>> getAssignments({
    required String userId,
    required String schoolId,
  }) async => [];
  @override
  Future<void> cacheAssignments(List<StaffRoleAssignment> assignments) async {}
  @override
  Future<void> clearAssignments({String? schoolId}) async {}

  @override
  Future<List<SubjectEnrollment>> getEnrollments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async => [];
  @override
  Future<void> cacheEnrollments(List<SubjectEnrollment> enrollments) async {}
  @override
  Future<void> clearEnrollments({String? schoolId}) async {}

  @override
  Future<List<Lesson>> getLessons({
    required String schoolId,
    required String subjectId,
    required String classId,
    DateTime? from,
    DateTime? to,
  }) async => [];
  @override
  Future<Lesson?> getLesson(String lessonId) async => null;
  @override
  Future<void> cacheLessons(List<Lesson> lessons) async {}

  @override
  Future<LessonAttendance?> getAttendance(String lessonId) async => null;
  @override
  Future<void> saveAttendance(LessonAttendance attendance) async {}

  @override
  Future<void> enqueueOperation(OfflineOperation operation) async {}
  @override
  Future<List<OfflineOperation>> getPendingOperations({
    String? schoolId,
  }) async => [];
  @override
  Future<List<OfflineOperation>> getOperationsByEntity({
    required String entityType,
    required String entityId,
  }) async => [];
  @override
  Future<void> updateOperation(OfflineOperation operation) async {}
  @override
  Future<void> deleteOperation(String operationId) async {}

  @override
  Future<void> clearAll() async {}
}
