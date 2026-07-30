import 'package:isar/isar.dart';

part 'student_cache_isar.g.dart';

@collection
class StudentCacheIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String studentId; // Firebase Document ID

  @Index(unique: true)
  late String uniqueSystemId; // SP-STUDENT-a82jd92

  late String name;
  late String? photoUrl;
  late String className;
  late String? stream;
  late String schoolStudentId; // MH-2026-000001
  late String schoolId;
}
