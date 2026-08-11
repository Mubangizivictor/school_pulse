import '../../domain/entities/student.dart';
import 'student_local_data_source.dart';
import 'student_remote_data_source.dart';

StudentLocalDataSource create({dynamic isar, dynamic remote}) =>
    StudentLocalDataSourceWeb(remote as StudentRemoteDataSource);

/// No local database on web - reads straight from Firestore via the
/// existing remote datasource, which already knows the collection layout
/// and query shape. No caching, no offline behavior.
class StudentLocalDataSourceWeb implements StudentLocalDataSource {
  final StudentRemoteDataSource remote;

  StudentLocalDataSourceWeb(this.remote);

  @override
  Future<void> cacheStudents(List<Student> students) async {}

  @override
  Future<void> cacheStudent(Student student) async {}

  @override
  Future<List<Student>> getCachedStudents(String schoolId) {
    return remote.getAllStudents(schoolId: schoolId);
  }

  @override
  Future<Student?> getCachedStudent(String studentId) async {
    try {
      return await remote.getStudentById(studentId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Student>> searchCachedStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? classId,
  }) {
    return remote.searchStudents(
      schoolId: schoolId,
      query: query,
      admissionNumber: admissionNumber,
      classId: classId,
    );
  }
}
