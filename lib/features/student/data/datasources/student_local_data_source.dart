import '../../domain/entities/student.dart';

/// No Isar/isar-model import here on purpose: this file is imported
/// unconditionally (by the repository and injection_container.dart), and
/// Isar's generated schema code cannot compile for web (see
/// student_local_data_source_mobile.dart for why). The mobile and web
/// implementations are selected at compile time via
/// student_local_data_source_factory.dart's conditional import.
abstract class StudentLocalDataSource {
  Future<void> cacheStudents(List<Student> students);
  Future<void> cacheStudent(Student student);
  Future<List<Student>> getCachedStudents(String schoolId);
  Future<Student?> getCachedStudent(String studentId);
  Future<List<Student>> searchCachedStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? classId,
  });
}
