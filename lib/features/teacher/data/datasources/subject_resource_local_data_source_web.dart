import '../../domain/entities/subject_resource.dart';
import 'subject_resource_local_data_source.dart';

SubjectResourceLocalDataSource create({dynamic isar, dynamic remote}) =>
    SubjectResourceLocalDataSourceWeb();

/// No local database or filesystem on web - see
/// ClassResourceLocalDataSourceWeb for why: caching and offline downloads
/// are mobile-only, a web teacher always reads the subject area live.
class SubjectResourceLocalDataSourceWeb
    implements SubjectResourceLocalDataSource {
  @override
  Future<List<SubjectResource>> getResources({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
  }) async => [];

  @override
  Future<SubjectResource?> getResource(String resourceId) async => null;

  @override
  Future<void> cacheResources(
    List<SubjectResource> resources, {
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
  }) async {}

  @override
  Future<void> saveResourceLocal(SubjectResource resource) async {}

  @override
  Future<void> deleteResourceLocal(String resourceId) async {}

  @override
  Future<String?> getLocalFilePath(String resourceId) async => null;

  @override
  Future<String> downloadForOffline(
    SubjectResource resource,
    List<int> bytes,
  ) async =>
      throw UnsupportedError('Offline downloads are not available on web.');

  @override
  Future<void> removeDownload(String resourceId) async {}

  @override
  Future<void> clear({String? schoolId}) async {}
}
