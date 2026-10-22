import '../../domain/entities/subject_resource.dart';

/// Mirrors [ClassResourceLocalDataSource] exactly, scoped by subject+class
/// instead of class alone. See that file for why this stays a separate
/// interface from the general teacher cache.
abstract class SubjectResourceLocalDataSource {
  Future<List<SubjectResource>> getResources({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
  });

  Future<SubjectResource?> getResource(String resourceId);

  Future<void> cacheResources(
    List<SubjectResource> resources, {
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
  });

  Future<void> saveResourceLocal(SubjectResource resource);

  Future<void> deleteResourceLocal(String resourceId);

  Future<String?> getLocalFilePath(String resourceId);

  Future<String> downloadForOffline(SubjectResource resource, List<int> bytes);

  Future<void> removeDownload(String resourceId);

  Future<void> clear({String? schoolId});
}
