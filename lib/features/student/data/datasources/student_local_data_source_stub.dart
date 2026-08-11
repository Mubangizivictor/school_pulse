import '../../domain/entities/student.dart';
import 'student_local_data_source.dart';

/// Selected only if the build target is neither web (dart.library.js_interop)
/// nor mobile/desktop (dart.library.io) - should never happen for this app's
/// supported platforms. Throws loudly rather than silently misbehaving.
StudentLocalDataSource create({dynamic isar, dynamic remote}) =>
    _StudentLocalDataSourceStub();

class _StudentLocalDataSourceStub implements StudentLocalDataSource {
  @override
  Future<void> cacheStudents(List<Student> students) => _unsupported();

  @override
  Future<void> cacheStudent(Student student) => _unsupported();

  @override
  Future<List<Student>> getCachedStudents(String schoolId) => _unsupported();

  @override
  Future<Student?> getCachedStudent(String studentId) => _unsupported();

  @override
  Future<List<Student>> searchCachedStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? classId,
  }) => _unsupported();

  Never _unsupported() =>
      throw UnimplementedError('No StudentLocalDataSource for this platform');
}
