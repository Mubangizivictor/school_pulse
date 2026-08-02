import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_resource.dart';

/// How much of the school's storage allowance is in use.
class StorageUsage {
  final int usedBytes;
  final int quotaBytes;
  final int fileCount;

  const StorageUsage({
    this.usedBytes = 0,
    this.quotaBytes = 0,
    this.fileCount = 0,
  });

  /// Null when the school has no quota set, so the UI shows usage without
  /// implying a limit that does not exist.
  double? get fraction {
    if (quotaBytes <= 0) return null;
    return usedBytes / quotaBytes;
  }
}

/// The class's resource area.
///
/// Two things here are worth more than the CRUD: the upload guard only accepts
/// types it can positively identify, and removing a resource from a class is
/// not the same operation as deleting the underlying file.
abstract class ClassResourceRepository {
  Future<Either<Failure, List<ClassResource>>> getResources({
    required ActiveResponsibilityContext context,
    String? folderId,
  });

  Future<Either<Failure, StorageUsage>> getStorageUsage({
    required ActiveResponsibilityContext context,
  });

  /// Uploads a file to the class area after checking type, size and quota.
  Future<Either<Failure, ClassResource>> uploadFile({
    required ActiveResponsibilityContext context,
    required String fileName,
    required Uint8List bytes,
    String? folderId,
    String? description,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  });

  Future<Either<Failure, ClassResource>> addLink({
    required ActiveResponsibilityContext context,
    required String name,
    required String url,
    String? folderId,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  });

  Future<Either<Failure, ClassResource>> createFolder({
    required ActiveResponsibilityContext context,
    required String name,
    String? parentFolderId,
  });

  /// Changes who inside the class can see it. Never widens beyond the class.
  Future<Either<Failure, ClassResource>> share({
    required ActiveResponsibilityContext context,
    required ClassResource resource,
    required ClassResourceAudience audience,
  });

  /// Removes it from the class. Deletes the stored file only when this class
  /// owns it - detaching a library copy leaves the original intact.
  Future<Either<Failure, void>> remove({
    required ActiveResponsibilityContext context,
    required ClassResource resource,
  });
}
