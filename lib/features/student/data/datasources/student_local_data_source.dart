import 'package:isar/isar.dart';
import '../models/student_isar_models.dart';

abstract class StudentLocalDataSource {
  Future<void> cacheStudents(List<StudentProfileIsar> students);
  Future<void> cacheStudent(StudentProfileIsar student);
  Future<List<StudentProfileIsar>> getCachedStudents(String schoolId);
  Future<StudentProfileIsar?> getCachedStudent(String studentId);
  Future<List<StudentProfileIsar>> searchCachedStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? classId,
  });
}

class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  final Isar isar;

  StudentLocalDataSourceImpl(this.isar);

  @override
  Future<void> cacheStudents(List<StudentProfileIsar> students) async {
    await isar.writeTxn(() async {
      await isar.studentProfileIsars.putAll(students);
    });
  }

  @override
  Future<void> cacheStudent(StudentProfileIsar student) async {
    await isar.writeTxn(() async {
      await isar.studentProfileIsars.put(student);
    });
  }

  @override
  Future<List<StudentProfileIsar>> getCachedStudents(String schoolId) {
    return isar.studentProfileIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
  }

  @override
  Future<StudentProfileIsar?> getCachedStudent(String studentId) {
    return isar.studentProfileIsars
        .filter()
        .studentIdEqualTo(studentId)
        .findFirst();
  }

  @override
  Future<List<StudentProfileIsar>> searchCachedStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? classId,
  }) async {
    var q = isar.studentProfileIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .optional(
          admissionNumber != null && admissionNumber.isNotEmpty,
          (q) => q.studentCodeEqualTo(admissionNumber!),
        )
        .optional(
          classId != null && classId.isNotEmpty,
          (q) => q.classIdEqualTo(classId!),
        );

    final results = await q.findAll();
    if (query == null || query.isEmpty) return results;

    final lowerQuery = query.toLowerCase();
    return results
        .where((s) => s.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
