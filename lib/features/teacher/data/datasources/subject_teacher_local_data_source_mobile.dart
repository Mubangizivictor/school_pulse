import 'package:isar/isar.dart';
import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/entities/subject_enrollment.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/offline_operation.dart';
import '../models/subject_teacher_isar_models.dart';
import 'subject_teacher_local_data_source.dart';

SubjectTeacherLocalDataSource create({dynamic isar, dynamic remote}) =>
    SubjectTeacherLocalDataSourceImpl(isar: isar as Isar);

class SubjectTeacherLocalDataSourceImpl
    implements SubjectTeacherLocalDataSource {
  final Isar isar;

  SubjectTeacherLocalDataSourceImpl({required this.isar});

  @override
  Future<List<StaffRoleAssignment>> getAssignments({
    required String userId,
    required String schoolId,
  }) async {
    final rows = await isar.staffRoleAssignmentIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .schoolIdEqualTo(schoolId)
        .findAll();
    return rows.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> cacheAssignments(List<StaffRoleAssignment> assignments) async {
    await isar.writeTxn(() async {
      await isar.staffRoleAssignmentIsars.putAll(
        assignments.map(StaffRoleAssignmentIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> clearAssignments({String? schoolId}) async {
    await isar.writeTxn(() async {
      if (schoolId == null) {
        await isar.staffRoleAssignmentIsars.clear();
        return;
      }
      final stale = await isar.staffRoleAssignmentIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.staffRoleAssignmentIsars.deleteAll(
        stale.map((e) => e.id).toList(),
      );
    });
  }

  @override
  Future<List<SubjectEnrollment>> getEnrollments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    final rows = await isar.subjectEnrollmentIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .subjectIdEqualTo(subjectId)
        .and()
        .classIdEqualTo(classId)
        .and()
        .academicYearIdEqualTo(academicYearId)
        .findAll();

    final filtered = (streamId == null || streamId.isEmpty)
        ? rows
        : rows
              .where((e) => e.streamId == null || e.streamId == streamId)
              .toList();
    return filtered.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> cacheEnrollments(List<SubjectEnrollment> enrollments) async {
    await isar.writeTxn(() async {
      await isar.subjectEnrollmentIsars.putAll(
        enrollments.map(SubjectEnrollmentIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> clearEnrollments({String? schoolId}) async {
    await isar.writeTxn(() async {
      if (schoolId == null) {
        await isar.subjectEnrollmentIsars.clear();
        return;
      }
      final stale = await isar.subjectEnrollmentIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.subjectEnrollmentIsars.deleteAll(
        stale.map((e) => e.id).toList(),
      );
    });
  }

  @override
  Future<List<Lesson>> getLessons({
    required String schoolId,
    required String subjectId,
    required String classId,
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await isar.lessonIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .subjectIdEqualTo(subjectId)
        .and()
        .classIdEqualTo(classId)
        .findAll();

    final filtered = rows.where((l) {
      if (from != null && l.scheduledStart.isBefore(from)) return false;
      if (to != null && l.scheduledStart.isAfter(to)) return false;
      return true;
    }).toList();

    filtered.sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
    return filtered.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Lesson?> getLesson(String lessonId) async {
    final row = await isar.lessonIsars
        .filter()
        .lessonIdEqualTo(lessonId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheLessons(List<Lesson> lessons) async {
    await isar.writeTxn(() async {
      await isar.lessonIsars.putAll(
        lessons.map(LessonIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<LessonAttendance?> getAttendance(String lessonId) async {
    final row = await isar.lessonAttendanceIsars
        .filter()
        .lessonIdEqualTo(lessonId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> saveAttendance(LessonAttendance attendance) async {
    await isar.writeTxn(() async {
      await isar.lessonAttendanceIsars.put(
        LessonAttendanceIsar.fromEntity(attendance),
      );
    });
  }

  @override
  Future<void> enqueueOperation(OfflineOperation operation) async {
    await isar.writeTxn(() async {
      await isar.subjectTeacherOfflineOperationIsars.put(
        SubjectTeacherOfflineOperationIsar.fromEntity(operation),
      );
    });
  }

  @override
  Future<List<OfflineOperation>> getPendingOperations({
    String? schoolId,
  }) async {
    final query = isar.subjectTeacherOfflineOperationIsars
        .filter()
        .statusEqualTo('pending');
    final rows = schoolId == null
        ? await query.findAll()
        : await query.and().schoolIdEqualTo(schoolId).findAll();

    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final now = DateTime.now();
    // A row still inside its backoff window is left in the queue but not
    // handed to the drain loop, so a failing operation doesn't get replayed
    // again on the very next poll.
    return rows
        .map((e) => e.toEntity())
        .where((op) => op.isDueFor(now))
        .toList();
  }

  @override
  Future<List<OfflineOperation>> getOperationsByEntity({
    required String entityType,
    required String entityId,
  }) async {
    final rows = await isar.subjectTeacherOfflineOperationIsars
        .filter()
        .entityTypeEqualTo(entityType)
        .and()
        .entityIdEqualTo(entityId)
        .findAll();
    return rows.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> updateOperation(OfflineOperation operation) async {
    await isar.writeTxn(() async {
      await isar.subjectTeacherOfflineOperationIsars.put(
        SubjectTeacherOfflineOperationIsar.fromEntity(operation),
      );
    });
  }

  @override
  Future<void> deleteOperation(String operationId) async {
    await isar.writeTxn(() async {
      final row = await isar.subjectTeacherOfflineOperationIsars
          .filter()
          .operationIdEqualTo(operationId)
          .findFirst();
      if (row != null) {
        await isar.subjectTeacherOfflineOperationIsars.delete(row.id);
      }
    });
  }

  @override
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.staffRoleAssignmentIsars.clear();
      await isar.subjectEnrollmentIsars.clear();
      await isar.subjectTeacherOfflineOperationIsars.clear();
      await isar.lessonIsars.clear();
      await isar.lessonAttendanceIsars.clear();
    });
  }
}
