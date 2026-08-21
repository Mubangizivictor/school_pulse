import 'package:isar/isar.dart';
import '../../domain/entities/class_announcement.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/class_behaviour.dart';
import '../../domain/entities/class_homework.dart';
import '../../domain/entities/class_performance.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/entities/class_dashboard_summary.dart';
import '../../domain/entities/class_task.dart';
import '../models/class_teacher_isar_models.dart';
import 'class_teacher_local_data_source.dart';

ClassTeacherLocalDataSource create({dynamic isar, dynamic remote}) =>
    ClassTeacherLocalDataSourceImpl(isar: isar as Isar);

class ClassTeacherLocalDataSourceImpl implements ClassTeacherLocalDataSource {
  final Isar isar;

  ClassTeacherLocalDataSourceImpl({required this.isar});

  @override
  Future<List<ClassStudentSummary>> getClassStudents({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    final rows = await isar.classStudentIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .classIdEqualTo(classId)
        .academicYearIdEqualTo(academicYearId)
        .findAll();

    final filtered = (streamId == null || streamId.isEmpty)
        ? rows
        : rows.where((r) => r.streamId == streamId).toList();
    return filtered.map((r) => r.toEntity()).toList();
  }

  @override
  Future<ClassStudentSummary?> getClassStudent(String studentId) async {
    final row = await isar.classStudentIsars
        .filter()
        .studentIdEqualTo(studentId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheClassStudents(
    List<ClassStudentSummary> students, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.classStudentIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .classIdEqualTo(classId)
          .academicYearIdEqualTo(academicYearId)
          .findAll();

      final stale = existing
          .where(
            (r) =>
                streamId == null || streamId.isEmpty || r.streamId == streamId,
          )
          .map((r) => r.isarId)
          .toList();

      if (stale.isNotEmpty) await isar.classStudentIsars.deleteAll(stale);
      await isar.classStudentIsars.putAll(
        students.map(ClassStudentIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<ClassDashboardSummary?> getDashboard({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    // cacheKey is class+stream+year, not globally unique - schoolId is
    // filtered in the query itself so a colliding row cached for another
    // school (e.g. both schools have their own "primary-5") is never
    // fetched, not merely discarded after the fact.
    final row = await isar.classDashboardCacheIsars
        .filter()
        .cacheKeyEqualTo(
          dashboardCacheKey(
            classId: classId,
            streamId: streamId,
            academicYearId: academicYearId,
          ),
        )
        .and()
        .schoolIdEqualTo(schoolId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheDashboard(
    ClassDashboardSummary dashboard, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    await isar.writeTxn(() async {
      await isar.classDashboardCacheIsars.put(
        ClassDashboardCacheIsar.fromEntity(
          dashboard,
          schoolId: schoolId,
          classId: classId,
          streamId: streamId,
          academicYearId: academicYearId,
        ),
      );
    });
  }

  @override
  Future<ClassAttendanceSession?> getAttendanceDraft(
    String sessionId, {
    required String schoolId,
  }) async {
    // sessionId is class+stream+day, not globally unique - two schools can
    // land on the identical string for their own "Primary 5" class. schoolId
    // is filtered in the query itself, not checked after the read, so a
    // colliding row from another school is never even fetched.
    final row = await isar.classAttendanceDraftIsars
        .filter()
        .sessionIdEqualTo(sessionId)
        .and()
        .schoolIdEqualTo(schoolId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> saveAttendanceDraft(ClassAttendanceSession session) async {
    await isar.writeTxn(() async {
      await isar.classAttendanceDraftIsars.put(
        ClassAttendanceDraftIsar.fromEntity(session),
      );
    });
  }

  @override
  Future<List<ClassTask>> getTasks({
    required String schoolId,
    required String ownerUserId,
  }) async {
    final rows = await isar.classTaskIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .ownerUserIdEqualTo(ownerUserId)
        .findAll();
    final tasks = rows.map((r) => r.toEntity()).toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return tasks;
  }

  @override
  Future<ClassTask?> getTask(String taskId) async {
    final row = await isar.classTaskIsars
        .filter()
        .taskIdEqualTo(taskId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheTasks(
    List<ClassTask> tasks, {
    required String schoolId,
    required String ownerUserId,
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.classTaskIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .and()
          .ownerUserIdEqualTo(ownerUserId)
          .findAll();
      if (existing.isNotEmpty) {
        await isar.classTaskIsars.deleteAll(
          existing.map((r) => r.isarId).toList(),
        );
      }
      await isar.classTaskIsars.putAll(
        tasks.map(ClassTaskIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> saveTaskLocal(ClassTask task) async {
    await isar.writeTxn(() async {
      await isar.classTaskIsars.put(ClassTaskIsar.fromEntity(task));
    });
  }

  @override
  Future<void> deleteTaskLocal(String taskId) async {
    await isar.writeTxn(() async {
      final row = await isar.classTaskIsars
          .filter()
          .taskIdEqualTo(taskId)
          .findFirst();
      if (row != null) await isar.classTaskIsars.delete(row.isarId);
    });
  }

  @override
  Future<List<ClassHomework>> getHomework({
    required String schoolId,
    required String classId,
  }) async {
    final rows = await isar.classHomeworkIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .classIdEqualTo(classId)
        .findAll();
    final homework = rows.map((r) => r.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return homework;
  }

  @override
  Future<ClassHomework?> getHomeworkItem(String homeworkId) async {
    final row = await isar.classHomeworkIsars
        .filter()
        .homeworkIdEqualTo(homeworkId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheHomework(
    List<ClassHomework> homework, {
    required String schoolId,
    required String classId,
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.classHomeworkIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .and()
          .classIdEqualTo(classId)
          .findAll();
      if (existing.isNotEmpty) {
        await isar.classHomeworkIsars.deleteAll(
          existing.map((r) => r.isarId).toList(),
        );
      }
      await isar.classHomeworkIsars.putAll(
        homework.map(ClassHomeworkIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> saveHomeworkLocal(ClassHomework homework) async {
    await isar.writeTxn(() async {
      await isar.classHomeworkIsars.put(ClassHomeworkIsar.fromEntity(homework));
    });
  }

  @override
  Future<List<ClassBehaviourRecord>> getBehaviourRecords({
    required String schoolId,
    required String classId,
  }) async {
    final rows = await isar.classBehaviourRecordIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .classIdEqualTo(classId)
        .findAll();
    final records = rows.map((r) => r.toEntity()).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return records;
  }

  @override
  Future<ClassBehaviourRecord?> getBehaviourRecord(String recordId) async {
    final row = await isar.classBehaviourRecordIsars
        .filter()
        .recordIdEqualTo(recordId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheBehaviourRecords(
    List<ClassBehaviourRecord> records, {
    required String schoolId,
    required String classId,
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.classBehaviourRecordIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .and()
          .classIdEqualTo(classId)
          .findAll();
      if (existing.isNotEmpty) {
        await isar.classBehaviourRecordIsars.deleteAll(
          existing.map((r) => r.isarId).toList(),
        );
      }
      await isar.classBehaviourRecordIsars.putAll(
        records.map(ClassBehaviourRecordIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> saveBehaviourRecordLocal(ClassBehaviourRecord record) async {
    await isar.writeTxn(() async {
      await isar.classBehaviourRecordIsars.put(
        ClassBehaviourRecordIsar.fromEntity(record),
      );
    });
  }

  @override
  Future<List<ClassAnnouncement>> getAnnouncements({
    required String schoolId,
    required String classId,
  }) async {
    final rows = await isar.classAnnouncementIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .classIdEqualTo(classId)
        .findAll();
    final announcements = rows.map((r) => r.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return announcements;
  }

  @override
  Future<ClassAnnouncement?> getAnnouncement(String announcementId) async {
    final row = await isar.classAnnouncementIsars
        .filter()
        .announcementIdEqualTo(announcementId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheAnnouncements(
    List<ClassAnnouncement> announcements, {
    required String schoolId,
    required String classId,
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.classAnnouncementIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .and()
          .classIdEqualTo(classId)
          .findAll();
      if (existing.isNotEmpty) {
        await isar.classAnnouncementIsars.deleteAll(
          existing.map((r) => r.isarId).toList(),
        );
      }
      await isar.classAnnouncementIsars.putAll(
        announcements.map(ClassAnnouncementIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> saveAnnouncementLocal(ClassAnnouncement announcement) async {
    await isar.writeTxn(() async {
      await isar.classAnnouncementIsars.put(
        ClassAnnouncementIsar.fromEntity(announcement),
      );
    });
  }

  @override
  Future<ClassPerformanceSummary?> getPerformance({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    String? streamId,
  }) async {
    final row = await isar.classPerformanceCacheIsars
        .filter()
        .cacheKeyEqualTo(
          performanceCacheKey(
            classId: classId,
            streamId: streamId,
            academicYearId: academicYearId,
            termId: termId,
          ),
        )
        .and()
        .schoolIdEqualTo(schoolId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cachePerformance(
    ClassPerformanceSummary summary, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    String? streamId,
  }) async {
    await isar.writeTxn(() async {
      await isar.classPerformanceCacheIsars.put(
        ClassPerformanceCacheIsar.fromEntity(
          summary,
          schoolId: schoolId,
          cacheKey: performanceCacheKey(
            classId: classId,
            streamId: streamId,
            academicYearId: academicYearId,
            termId: termId,
          ),
        ),
      );
    });
  }

  @override
  Future<void> clear({String? schoolId}) async {
    await isar.writeTxn(() async {
      if (schoolId == null) {
        await isar.classStudentIsars.clear();
        await isar.classDashboardCacheIsars.clear();
        await isar.classAttendanceDraftIsars.clear();
        await isar.classTaskIsars.clear();
        await isar.classHomeworkIsars.clear();
        await isar.classBehaviourRecordIsars.clear();
        await isar.classAnnouncementIsars.clear();
        await isar.classPerformanceCacheIsars.clear();
        return;
      }

      final drafts = await isar.classAttendanceDraftIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classAttendanceDraftIsars.deleteAll(
        drafts.map((r) => r.isarId).toList(),
      );

      final students = await isar.classStudentIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classStudentIsars.deleteAll(
        students.map((r) => r.isarId).toList(),
      );

      final dashboards = await isar.classDashboardCacheIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classDashboardCacheIsars.deleteAll(
        dashboards.map((r) => r.isarId).toList(),
      );

      final homework = await isar.classHomeworkIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classHomeworkIsars.deleteAll(
        homework.map((r) => r.isarId).toList(),
      );

      final behaviour = await isar.classBehaviourRecordIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classBehaviourRecordIsars.deleteAll(
        behaviour.map((r) => r.isarId).toList(),
      );

      final announcements = await isar.classAnnouncementIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classAnnouncementIsars.deleteAll(
        announcements.map((r) => r.isarId).toList(),
      );

      final performance = await isar.classPerformanceCacheIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classPerformanceCacheIsars.deleteAll(
        performance.map((r) => r.isarId).toList(),
      );
    });
  }
}
