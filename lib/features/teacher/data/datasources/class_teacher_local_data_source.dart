import 'package:isar/isar.dart';

import '../../domain/entities/class_attendance.dart';
import '../models/class_teacher_isar_models.dart';

/// The Class Teacher panel's on-device store.
///
/// Isar, matching the rest of the app - the roster a teacher marks in a
/// classroom with no signal has to come from somewhere, and it is the same
/// store the Subject Teacher panel and the offline sync queue already use.
abstract class ClassTeacherLocalDataSource {
  Future<List<ClassStudentIsar>> getClassStudents({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<ClassStudentIsar?> getClassStudent(String studentId);

  /// Replaces the cached roster for one class rather than merging into it, so
  /// a student who transferred out disappears from the offline register
  /// instead of lingering as a ghost the teacher can still mark.
  Future<void> cacheClassStudents(
    List<ClassStudentIsar> students, {
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<ClassDashboardCacheIsar?> getDashboard({
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<void> cacheDashboard(ClassDashboardCacheIsar dashboard);

  /// The register held on this device, or null when none has been started.
  Future<ClassAttendanceDraftIsar?> getAttendanceDraft(String sessionId);

  /// Writes the register locally *before* attempting the network, so a
  /// teacher's marks survive the app being killed between the last tap and
  /// the phone finding signal.
  Future<void> saveAttendanceDraft(ClassAttendanceSession session);

  /// Wipes one tenant's cached class data, or all of it when [schoolId] is
  /// null. Called on logout and school switch.
  Future<void> clear({String? schoolId});
}

class ClassTeacherLocalDataSourceImpl implements ClassTeacherLocalDataSource {
  final Isar isar;

  ClassTeacherLocalDataSourceImpl({required this.isar});

  @override
  Future<List<ClassStudentIsar>> getClassStudents({
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

    if (streamId == null || streamId.isEmpty) return rows;
    return rows.where((r) => r.streamId == streamId).toList();
  }

  @override
  Future<ClassStudentIsar?> getClassStudent(String studentId) {
    return isar.classStudentIsars.filter().studentIdEqualTo(studentId).findFirst();
  }

  @override
  Future<void> cacheClassStudents(
    List<ClassStudentIsar> students, {
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
          .where((r) =>
              streamId == null || streamId.isEmpty || r.streamId == streamId)
          .map((r) => r.isarId)
          .toList();

      if (stale.isNotEmpty) await isar.classStudentIsars.deleteAll(stale);
      await isar.classStudentIsars.putAll(students);
    });
  }

  @override
  Future<ClassDashboardCacheIsar?> getDashboard({
    required String classId,
    required String academicYearId,
    String? streamId,
  }) {
    return isar.classDashboardCacheIsars
        .filter()
        .cacheKeyEqualTo(dashboardCacheKey(
          classId: classId,
          streamId: streamId,
          academicYearId: academicYearId,
        ))
        .findFirst();
  }

  @override
  Future<void> cacheDashboard(ClassDashboardCacheIsar dashboard) async {
    await isar.writeTxn(() async {
      await isar.classDashboardCacheIsars.put(dashboard);
    });
  }

  @override
  Future<ClassAttendanceDraftIsar?> getAttendanceDraft(String sessionId) {
    return isar.classAttendanceDraftIsars
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
  }

  @override
  Future<void> saveAttendanceDraft(ClassAttendanceSession session) async {
    await isar.writeTxn(() async {
      await isar.classAttendanceDraftIsars
          .put(ClassAttendanceDraftIsar.fromEntity(session));
    });
  }

  @override
  Future<void> clear({String? schoolId}) async {
    await isar.writeTxn(() async {
      if (schoolId == null) {
        await isar.classStudentIsars.clear();
        await isar.classDashboardCacheIsars.clear();
        await isar.classAttendanceDraftIsars.clear();
        return;
      }

      final drafts = await isar.classAttendanceDraftIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classAttendanceDraftIsars
          .deleteAll(drafts.map((r) => r.isarId).toList());

      final students = await isar.classStudentIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classStudentIsars.deleteAll(students.map((r) => r.isarId).toList());

      final dashboards = await isar.classDashboardCacheIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.classDashboardCacheIsars
          .deleteAll(dashboards.map((r) => r.isarId).toList());
    });
  }
}
