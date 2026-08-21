import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/class_resource.dart';
import '../models/class_teacher_isar_models.dart';
import 'class_resource_local_data_source.dart';

ClassResourceLocalDataSource create({dynamic isar, dynamic remote}) =>
    ClassResourceLocalDataSourceImpl(isar: isar as Isar);

class ClassResourceLocalDataSourceImpl implements ClassResourceLocalDataSource {
  final Isar isar;

  ClassResourceLocalDataSourceImpl({required this.isar});

  @override
  Future<List<ClassResource>> getResources({
    required String schoolId,
    required String classId,
    required String academicYearId,
  }) async {
    final rows = await isar.classResourceIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .classIdEqualTo(classId)
        .and()
        .academicYearIdEqualTo(academicYearId)
        .findAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<ClassResource?> getResource(String resourceId) async {
    final row = await isar.classResourceIsars
        .filter()
        .resourceIdEqualTo(resourceId)
        .findFirst();
    return row?.toEntity();
  }

  @override
  Future<void> cacheResources(
    List<ClassResource> resources, {
    required String schoolId,
    required String classId,
    required String academicYearId,
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.classResourceIsars
          .filter()
          .schoolIdEqualTo(schoolId)
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
        await isar.classResourceIsars.deleteAll(
          existing.map((r) => r.isarId).toList(),
        );
      }

      await isar.classResourceIsars.putAll(
        resources
            .map(
              (r) => ClassResourceIsar.fromEntity(
                r,
                localFilePath: downloadedPaths[r.id],
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> saveResourceLocal(ClassResource resource) async {
    await isar.writeTxn(() async {
      final existing = await isar.classResourceIsars
          .filter()
          .resourceIdEqualTo(resource.id)
          .findFirst();
      await isar.classResourceIsars.put(
        ClassResourceIsar.fromEntity(
          resource,
          localFilePath: existing?.localFilePath,
        ),
      );
    });
  }

  @override
  Future<void> deleteResourceLocal(String resourceId) async {
    final row = await isar.classResourceIsars
        .filter()
        .resourceIdEqualTo(resourceId)
        .findFirst();
    if (row?.localFilePath != null) {
      await _deleteFile(row!.localFilePath!);
    }
    await isar.writeTxn(() async {
      if (row != null) await isar.classResourceIsars.delete(row.isarId);
    });
  }

  @override
  Future<String?> getLocalFilePath(String resourceId) async {
    final row = await isar.classResourceIsars
        .filter()
        .resourceIdEqualTo(resourceId)
        .findFirst();
    final path = row?.localFilePath;
    if (path == null) return null;
    // The row can outlive the file - storage cleared by the OS, say - so a
    // stale path is treated as "not downloaded" rather than handed to a
    // caller that will fail trying to open it.
    return File(path).existsSync() ? path : null;
  }

  @override
  Future<String> downloadForOffline(
    ClassResource resource,
    List<int> bytes,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final resourcesDir = Directory('${dir.path}/class_resources');
    if (!await resourcesDir.exists()) {
      await resourcesDir.create(recursive: true);
    }

    final extension = _extensionOf(resource.name);
    final file = File(
      '${resourcesDir.path}/${resource.id}${extension.isEmpty ? '' : '.$extension'}',
    );
    await file.writeAsBytes(bytes);

    await isar.writeTxn(() async {
      await isar.classResourceIsars.put(
        ClassResourceIsar.fromEntity(resource, localFilePath: file.path),
      );
    });

    return file.path;
  }

  @override
  Future<void> removeDownload(String resourceId) async {
    final row = await isar.classResourceIsars
        .filter()
        .resourceIdEqualTo(resourceId)
        .findFirst();
    if (row == null) return;

    if (row.localFilePath != null) await _deleteFile(row.localFilePath!);

    await isar.writeTxn(() async {
      await isar.classResourceIsars.put(row..localFilePath = null);
    });
  }

  @override
  Future<void> clear({String? schoolId}) async {
    final rows = schoolId == null
        ? await isar.classResourceIsars.where().findAll()
        : await isar.classResourceIsars
              .filter()
              .schoolIdEqualTo(schoolId)
              .findAll();

    for (final row in rows) {
      if (row.localFilePath != null) await _deleteFile(row.localFilePath!);
    }

    await isar.writeTxn(() async {
      await isar.classResourceIsars.deleteAll(
        rows.map((r) => r.isarId).toList(),
      );
    });
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A file already gone or a permission hiccup is not worth failing the
      // caller's own operation over - the metadata row is the source of
      // truth, not the blob.
    }
  }

  static String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}
