import '../../domain/entities/class_resource.dart';
import 'class_resource_local_data_source.dart';

ClassResourceLocalDataSource create({dynamic isar, dynamic remote}) =>
    ClassResourceLocalDataSourceWeb();

/// No local database or filesystem on web - resource caching and on-device
/// downloads are mobile-only (documented difference, not a bug): a web
/// teacher always reads the class area live, and "available offline" simply
/// does not apply to a browser tab.
class ClassResourceLocalDataSourceWeb implements ClassResourceLocalDataSource {
  @override
  Future<List<ClassResource>> getResources({
    required String schoolId,
    required String classId,
    required String academicYearId,
  }) async => [];

  @override
  Future<ClassResource?> getResource(String resourceId) async => null;

  @override
  Future<void> cacheResources(
    List<ClassResource> resources, {
    required String schoolId,
    required String classId,
    required String academicYearId,
  }) async {}

  @override
  Future<void> saveResourceLocal(ClassResource resource) async {}

  @override
  Future<void> deleteResourceLocal(String resourceId) async {}

  @override
  Future<String?> getLocalFilePath(String resourceId) async => null;

  @override
  Future<String> downloadForOffline(
    ClassResource resource,
    List<int> bytes,
  ) async => throw UnsupportedError(
    'Offline downloads are not available on web.',
  );

  @override
  Future<void> removeDownload(String resourceId) async {}

  @override
  Future<void> clear({String? schoolId}) async {}
}
