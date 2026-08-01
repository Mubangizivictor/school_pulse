import 'package:isar/isar.dart';

import '../models/subject_teacher_isar_models.dart';

/// On-device store for the Subject Teacher panel: the assignment cache, the
/// subject-enrollment cache, and the synchronisation queue.
abstract class SubjectTeacherLocalDataSource {
  Future<List<StaffRoleAssignmentIsar>> getAssignments({
    required String userId,
    required String schoolId,
  });
  Future<void> cacheAssignments(List<StaffRoleAssignmentIsar> assignments);

  /// Drops every cached assignment for a user. Used on logout and on school
  /// switch so one tenant's responsibilities can never show up under another.
  Future<void> clearAssignments({String? schoolId});

  Future<List<SubjectEnrollmentIsar>> getEnrollments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });
  Future<void> cacheEnrollments(List<SubjectEnrollmentIsar> enrollments);
  Future<void> clearEnrollments({String? schoolId});

  Future<void> enqueueOperation(SubjectTeacherOfflineOperationIsar operation);
  Future<List<SubjectTeacherOfflineOperationIsar>> getPendingOperations({
    String? schoolId,
  });
  Future<List<SubjectTeacherOfflineOperationIsar>> getOperationsByEntity({
    required String entityType,
    required String entityId,
  });
  Future<void> updateOperation(SubjectTeacherOfflineOperationIsar operation);
  Future<void> deleteOperation(String operationId);

  /// Wipes every Subject Teacher collection. Called on logout so a shared
  /// device does not carry one teacher's register into the next session.
  Future<void> clearAll();
}

class SubjectTeacherLocalDataSourceImpl implements SubjectTeacherLocalDataSource {
  final Isar isar;

  SubjectTeacherLocalDataSourceImpl({required this.isar});

  @override
  Future<List<StaffRoleAssignmentIsar>> getAssignments({
    required String userId,
    required String schoolId,
  }) async {
    return isar.staffRoleAssignmentIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .schoolIdEqualTo(schoolId)
        .findAll();
  }

  @override
  Future<void> cacheAssignments(List<StaffRoleAssignmentIsar> assignments) async {
    await isar.writeTxn(() async {
      await isar.staffRoleAssignmentIsars.putAll(assignments);
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
      await isar.staffRoleAssignmentIsars.deleteAll(stale.map((e) => e.id).toList());
    });
  }

  @override
  Future<List<SubjectEnrollmentIsar>> getEnrollments({
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

    // Stream is filtered in memory: a null streamId on the assignment means
    // "the whole class", so it must not narrow the result.
    if (streamId == null || streamId.isEmpty) return rows;
    return rows.where((e) => e.streamId == null || e.streamId == streamId).toList();
  }

  @override
  Future<void> cacheEnrollments(List<SubjectEnrollmentIsar> enrollments) async {
    await isar.writeTxn(() async {
      await isar.subjectEnrollmentIsars.putAll(enrollments);
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
      await isar.subjectEnrollmentIsars.deleteAll(stale.map((e) => e.id).toList());
    });
  }

  @override
  Future<void> enqueueOperation(SubjectTeacherOfflineOperationIsar operation) async {
    await isar.writeTxn(() async {
      await isar.subjectTeacherOfflineOperationIsars.put(operation);
    });
  }

  @override
  Future<List<SubjectTeacherOfflineOperationIsar>> getPendingOperations({
    String? schoolId,
  }) async {
    final query = isar.subjectTeacherOfflineOperationIsars.filter().statusEqualTo('pending');
    final rows = schoolId == null
        ? await query.findAll()
        : await query.and().schoolIdEqualTo(schoolId).findAll();

    // Oldest first: replaying in creation order is what makes a lesson start
    // land before the attendance that belongs to it.
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return rows;
  }

  @override
  Future<List<SubjectTeacherOfflineOperationIsar>> getOperationsByEntity({
    required String entityType,
    required String entityId,
  }) async {
    return isar.subjectTeacherOfflineOperationIsars
        .filter()
        .entityTypeEqualTo(entityType)
        .and()
        .entityIdEqualTo(entityId)
        .findAll();
  }

  @override
  Future<void> updateOperation(SubjectTeacherOfflineOperationIsar operation) async {
    await isar.writeTxn(() async {
      await isar.subjectTeacherOfflineOperationIsars.put(operation);
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
    });
  }
}
