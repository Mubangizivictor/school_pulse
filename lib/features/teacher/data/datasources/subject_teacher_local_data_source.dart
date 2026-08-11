import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/entities/subject_enrollment.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/offline_operation.dart';

/// No Isar/isar-model import here on purpose - see
/// subject_teacher_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// subject_teacher_local_data_source_factory.dart's conditional import.
///
/// Assignment/enrollment/lesson caching is a pure Firestore-mirroring
/// cache on mobile. enqueueOperation/getPendingOperations/etc. are a
/// generic offline-operation replay queue with no web equivalent - web has
/// no offline use case for these workflows, so those become no-ops/empty.
abstract class SubjectTeacherLocalDataSource {
  Future<List<StaffRoleAssignment>> getAssignments({
    required String userId,
    required String schoolId,
  });
  Future<void> cacheAssignments(List<StaffRoleAssignment> assignments);
  Future<void> clearAssignments({String? schoolId});

  Future<List<SubjectEnrollment>> getEnrollments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });
  Future<void> cacheEnrollments(List<SubjectEnrollment> enrollments);
  Future<void> clearEnrollments({String? schoolId});

  Future<List<Lesson>> getLessons({
    required String schoolId,
    required String subjectId,
    required String classId,
    DateTime? from,
    DateTime? to,
  });
  Future<Lesson?> getLesson(String lessonId);
  Future<void> cacheLessons(List<Lesson> lessons);

  Future<LessonAttendance?> getAttendance(String lessonId);
  Future<void> saveAttendance(LessonAttendance attendance);

  Future<void> enqueueOperation(OfflineOperation operation);
  Future<List<OfflineOperation>> getPendingOperations({String? schoolId});
  Future<List<OfflineOperation>> getOperationsByEntity({
    required String entityType,
    required String entityId,
  });
  Future<void> updateOperation(OfflineOperation operation);
  Future<void> deleteOperation(String operationId);

  Future<void> clearAll();
}
