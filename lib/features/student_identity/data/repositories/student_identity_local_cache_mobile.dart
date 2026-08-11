import 'package:isar/isar.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_enums.dart';
import '../models/student_cache_isar.dart';
import '../models/student_identity_model.dart';
import 'student_identity_local_cache.dart';

StudentIdentityLocalCache create({dynamic isar}) =>
    StudentIdentityLocalCacheMobile(isar as Isar);

class StudentIdentityLocalCacheMobile implements StudentIdentityLocalCache {
  final Isar isar;

  StudentIdentityLocalCacheMobile(this.isar);

  @override
  Future<void> save({
    required Student student,
    required StudentIdentityModel identity,
  }) async {
    await isar.writeTxn(() async {
      final cache = StudentCacheIsar()
        ..studentId = student.id
        ..uniqueSystemId = identity.uniqueSystemId
        ..name = student.name
        ..photoUrl = student.photoUrl
        ..className = student.className
        ..schoolStudentId = identity.schoolStudentId
        ..schoolId = student.schoolId;

      await isar.studentCacheIsars.put(cache);
    });
  }

  @override
  Future<Student?> findByUniqueSystemId(String uniqueSystemId) async {
    final cached = await isar.studentCacheIsars
        .filter()
        .uniqueSystemIdEqualTo(uniqueSystemId)
        .findFirst();
    if (cached == null) return null;

    return Student(
      id: cached.studentId,
      schoolId: cached.schoolId,
      name: cached.name,
      photoUrl: cached.photoUrl,
      studentCode: cached.schoolStudentId,
      admissionNumber: '',
      dateOfBirth: DateTime(2000),
      gender: Gender.male,
      classId: cached.className,
      academicYearId: '',
      status: StudentStatus.active,
      level: EducationLevel.primary,
    );
  }
}
