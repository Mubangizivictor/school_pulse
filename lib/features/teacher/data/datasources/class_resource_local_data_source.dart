import '../../domain/entities/class_resource.dart';

/// No Isar/isar-model import here on purpose - see
/// class_resource_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// class_resource_local_data_source_factory.dart's conditional import.
///
/// A separate interface from [ClassTeacherLocalDataSource] rather than an
/// addition to it: this is the one cache in the panel that also owns bytes
/// on disk, not just Firestore-mirrored rows, and keeping that concern in
/// its own file stops the resource area's file-management code leaking into
/// every other feature that touches the shared cache.
abstract class ClassResourceLocalDataSource {
  Future<List<ClassResource>> getResources({
    required String schoolId,
    required String classId,
    required String academicYearId,
  });

  Future<ClassResource?> getResource(String resourceId);

  Future<void> cacheResources(
    List<ClassResource> resources, {
    required String schoolId,
    required String classId,
    required String academicYearId,
  });

  Future<void> saveResourceLocal(ClassResource resource);

  Future<void> deleteResourceLocal(String resourceId);

  /// Path to this resource's bytes on disk, or null if it has not been
  /// downloaded for offline use.
  Future<String?> getLocalFilePath(String resourceId);

  /// Writes [bytes] to disk and records the path against the resource, so a
  /// download survives the app being killed and does not have to repeat.
  Future<String> downloadForOffline(ClassResource resource, List<int> bytes);

  /// Removes the on-disk copy without touching the metadata row - the
  /// resource stays visible, just no longer available with no signal.
  Future<void> removeDownload(String resourceId);

  Future<void> clear({String? schoolId});
}
