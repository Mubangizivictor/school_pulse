import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_resource.dart' show ClassResourceAudience;
import '../entities/subject_resource.dart';
import 'class_resource_repository.dart' show StorageUsage;

/// The subject's resource area for one class/stream.
///
/// Mirrors [ClassResourceRepository] exactly - same guard-then-act shape,
/// same offline-cache fallback, same upload/link/folder/share/remove/download
/// operations - scoped by subject+class+stream instead of by class alone.
abstract class SubjectResourceRepository {
  Future<Either<Failure, List<SubjectResource>>> getResources({
    required ActiveResponsibilityContext context,
    String? folderId,
  });

  Future<Either<Failure, StorageUsage>> getStorageUsage({
    required ActiveResponsibilityContext context,
  });

  Future<Either<Failure, SubjectResource>> uploadFile({
    required ActiveResponsibilityContext context,
    required String fileName,
    required Uint8List bytes,
    String? folderId,
    String? description,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  });

  Future<Either<Failure, SubjectResource>> addLink({
    required ActiveResponsibilityContext context,
    required String name,
    required String url,
    String? folderId,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  });

  Future<Either<Failure, SubjectResource>> createFolder({
    required ActiveResponsibilityContext context,
    required String name,
    String? parentFolderId,
  });

  Future<Either<Failure, SubjectResource>> share({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
    required ClassResourceAudience audience,
  });

  Future<Either<Failure, void>> remove({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
  });

  Future<Either<Failure, void>> downloadForOffline({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
  });

  Future<Either<Failure, void>> removeDownload({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
  });

  Future<bool> isDownloaded(String resourceId);
}
