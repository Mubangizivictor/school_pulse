import 'package:isar/isar.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/entities/class_dashboard_summary.dart';
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
    final row = await isar.classDashboardCacheIsars
        .filter()
        .cacheKeyEqualTo(
          dashboardCacheKey(
            classId: classId,
            streamId: streamId,
            academicYearId: academicYearId,
          ),
        )
        .findFirst();
    if (row == null || row.schoolId != schoolId) return null;
    return row.toEntity();
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
  Future<ClassAttendanceSession?> getAttendanceDraft(String sessionId) async {
    final row = await isar.classAttendanceDraftIsars
        .filter()
        .sessionIdEqualTo(sessionId)
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
    });
  }
}
