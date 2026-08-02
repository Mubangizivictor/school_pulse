import 'package:isar/isar.dart';

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
  Future<void> clear({String? schoolId}) async {
    await isar.writeTxn(() async {
      if (schoolId == null) {
        await isar.classStudentIsars.clear();
        await isar.classDashboardCacheIsars.clear();
        return;
      }

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
