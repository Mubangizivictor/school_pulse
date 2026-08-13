import 'package:isar/isar.dart';
import '../../domain/entities/student.dart';
import '../models/student_isar_models.dart';
import 'student_local_data_source.dart';

StudentLocalDataSource create({dynamic isar, dynamic remote}) =>
    StudentLocalDataSourceImpl(isar as Isar);

class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  final Isar isar;

  StudentLocalDataSourceImpl(this.isar);

  @override
  Future<void> cacheStudents(List<Student> students) async {
    await isar.writeTxn(() async {
      await isar.studentProfileIsars.putAll(
        students.map(StudentProfileIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> cacheStudent(Student student) async {
    await isar.writeTxn(() async {
      await isar.studentProfileIsars.put(
        StudentProfileIsar.fromEntity(student),
      );
    });
  }

  @override
  Future<List<Student>> getCachedStudents(String schoolId) async {
    final cached = await isar.studentProfileIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<Student?> getCachedStudent(String studentId) async {
    final cached = await isar.studentProfileIsars
        .filter()
        .studentIdEqualTo(studentId)
        .findFirst();
    return cached?.toEntity();
  }

  @override
  Future<List<Student>> searchCachedStudents({
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
    var students = results.map((c) => c.toEntity()).toList();
    if (query == null || query.isEmpty) return students;

    final lowerQuery = query.toLowerCase();
    return students
        .where((s) => s.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
