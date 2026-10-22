import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/subject_resource.dart';
import '../models/subject_resource_isar_models.dart';
import 'subject_resource_local_data_source.dart';

SubjectResourceLocalDataSource create({dynamic isar, dynamic remote}) =>
    SubjectResourceLocalDataSourceImpl(isar: isar as Isar);

class SubjectResourceLocalDataSourceImpl
    implements SubjectResourceLocalDataSource {
  final Isar isar;

  SubjectResourceLocalDataSourceImpl({required this.isar});

  @override
  Future<List<SubjectResource>> getResources({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
  }) async {
    final rows = await isar.subjectResourceIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .subjectIdEqualTo(subjectId)
        .and()
        .classIdEqualTo(classId)
        .and()
        .academicYearIdEqualTo(academicYearId)
        .findAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<SubjectResource?> getResource(String resourceId) async {
    final row = await isar.subjectResourceIsars
        .filter()
        .resourceIdEqualTo(resourceId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheResources(
    List<SubjectResource> resources, {
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.subjectResourceIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .and()
          .subjectIdEqualTo(subjectId)
          .and()
          .classIdEqualTo(classId)
          .and()
          .academicYearIdEqualTo(academicYearId)
          .findAll();

      // A row already carrying a downloaded file keeps its local path - a
      // metadata refresh must not orphan bytes already on disk.
      final downloadedPaths = {
        for (final row in existing)
          if (row.localFilePath != null) row.resourceId: row.localFilePath,
      };

      if (existing.isNotEmpty) {
        await isar.subjectResourceIsars.deleteAll(
          existing.map((r) => r.isarId).toList(),
        );
      }

      await isar.subjectResourceIsars.putAll(
        resources
            .map(
              (r) => SubjectResourceIsar.fromEntity(
                r,
                localFilePath: downloadedPaths[r.id],
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> saveResourceLocal(SubjectResource resource) async {
    await isar.writeTxn(() async {
      final existing = await isar.subjectResourceIsars
          .filter()
          .resourceIdEqualTo(resource.id)
          .findFirst();
      await isar.subjectResourceIsars.put(
        SubjectResourceIsar.fromEntity(
          resource,
          localFilePath: existing?.localFilePath,
        ),
      );
    });
  }

  @override
  Future<void> deleteResourceLocal(String resourceId) async {
    await isar.writeTxn(() async {
      final existing = await isar.subjectResourceIsars
          .filter()
          .resourceIdEqualTo(resourceId)
          .findFirst();
      if (existing == null) return;
      final path = existing.localFilePath;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      await isar.subjectResourceIsars.delete(existing.isarId);
    });
  }

  @override
  Future<String?> getLocalFilePath(String resourceId) async {
    final row = await isar.subjectResourceIsars
        .filter()
        .resourceIdEqualTo(resourceId)
        .findFirst();
    return row?.localFilePath;
  }

  @override
  Future<String> downloadForOffline(
    SubjectResource resource,
    List<int> bytes,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final resourceDir = Directory('${dir.path}/subject_resources');
    if (!await resourceDir.exists()) {
      await resourceDir.create(recursive: true);
    }

    final safeName = resource.name.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final file = File('${resourceDir.path}/${resource.id}_$safeName');
    await file.writeAsBytes(bytes);

    await isar.writeTxn(() async {
      final existing = await isar.subjectResourceIsars
          .filter()
          .resourceIdEqualTo(resource.id)
          .findFirst();
      if (existing != null) {
        existing.localFilePath = file.path;
        await isar.subjectResourceIsars.put(existing);
      }
    });

    return file.path;
  }

  @override
  Future<void> removeDownload(String resourceId) async {
    await isar.writeTxn(() async {
      final existing = await isar.subjectResourceIsars
          .filter()
          .resourceIdEqualTo(resourceId)
          .findFirst();
      if (existing == null) return;
      final path = existing.localFilePath;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      existing.localFilePath = null;
      await isar.subjectResourceIsars.put(existing);
    });
  }

  @override
  Future<void> clear({String? schoolId}) async {
    await isar.writeTxn(() async {
      if (schoolId == null) {
        await isar.subjectResourceIsars.clear();
        return;
      }
      final rows = await isar.subjectResourceIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .findAll();
      await isar.subjectResourceIsars.deleteAll(
        rows.map((r) => r.isarId).toList(),
      );
    });
  }
}
