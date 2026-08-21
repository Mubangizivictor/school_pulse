import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_resource.dart';
import '../../domain/entities/staff_role_assignment.dart' show AssignmentStatus;
import '../../domain/entities/subject_resource.dart';
import '../../domain/policies/class_resource_policy.dart';
import '../../domain/repositories/class_resource_repository.dart' show StorageUsage;
import '../../domain/repositories/subject_resource_repository.dart';
import '../../domain/services/subject_audit_service.dart';
import '../datasources/subject_resource_local_data_source.dart';

/// Mirrors [ClassResourceRepositoryImpl] exactly - same guard-then-act shape,
/// same offline-cache fallback - scoped by subject+class instead of class
/// alone. There is no `SubjectTeacherAssignmentService` equivalent to
/// `ClassTeacherAssignmentService`: subject-role authorization goes straight
/// through `ActiveResponsibilityContext.can(...)`, which is what `context.can`
/// below calls.
class SubjectResourceRepositoryImpl implements SubjectResourceRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final SubjectResourceLocalDataSource localDataSource;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final Uuid uuid;
  final http.Client httpClient;

  SubjectResourceRepositoryImpl({
    required this.firestore,
    required this.storage,
    required this.localDataSource,
    required this.auditService,
    required this.networkInfo,
    Uuid? uuid,
    http.Client? httpClient,
  }) : uuid = uuid ?? const Uuid(),
       httpClient = httpClient ?? http.Client();

  CollectionReference<Map<String, dynamic>> _resources(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('subject_resources');

  Either<Failure, void> _authorize(
    ActiveResponsibilityContext context,
    String permission,
  ) {
    if (context.assignmentStatus != AssignmentStatus.active) {
      return const Left(AssignmentInvalidFailure('This responsibility is no longer active.'));
    }
    if (!context.can(
      permission,
      subjectId: context.subjectId,
      classId: context.classId,
      streamId: context.streamId,
      academicYearId: context.academicYearId,
    )) {
      return const Left(PermissionDeniedFailure());
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<SubjectResource>>> getResources({
    required ActiveResponsibilityContext context,
    String? folderId,
  }) async {
    final guard = _authorize(context, Permission.subjectResourceUpload);
    if (guard.isLeft()) return guard.fold(Left.new, (_) => const Right([]));

    final subjectId = context.subjectId;
    final classId = context.classId;
    if (subjectId == null ||
        subjectId.isEmpty ||
        classId == null ||
        classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a subject and class.'),
      );
    }

    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getResources(
        schoolId: context.schoolId,
        subjectId: subjectId,
        classId: classId,
        academicYearId: context.academicYearId,
      );
      return Right(cached.where((r) => r.folderId == folderId).toList());
    }

    try {
      final snapshot = await _resources(context.schoolId)
          .where('subjectId', isEqualTo: subjectId)
          .where('classId', isEqualTo: classId)
          .where('academicYearId', isEqualTo: context.academicYearId)
          .orderBy('uploadedAt', descending: true)
          .get();

      final all = snapshot.docs
          .map((d) => _fromDoc(d.id, context.schoolId, d.data()))
          .toList();

      await localDataSource.cacheResources(
        all,
        schoolId: context.schoolId,
        subjectId: subjectId,
        classId: classId,
        academicYearId: context.academicYearId,
      );

      return Right(all.where((r) => r.folderId == folderId).toList());
    } catch (_) {
      final cached = await localDataSource.getResources(
        schoolId: context.schoolId,
        subjectId: subjectId,
        classId: classId,
        academicYearId: context.academicYearId,
      );
      if (cached.isNotEmpty) {
        return Right(cached.where((r) => r.folderId == folderId).toList());
      }
      return const Left(
        ServerFailure('Could not load resources. Pull down to retry.'),
      );
    }
  }

  @override
  Future<Either<Failure, StorageUsage>> getStorageUsage({
    required ActiveResponsibilityContext context,
  }) async {
    try {
      final snapshot = await _resources(context.schoolId)
          .where('subjectId', isEqualTo: context.subjectId)
          .where('classId', isEqualTo: context.classId)
          .get();

      var used = 0;
      var files = 0;
      for (final doc in snapshot.docs) {
        final size = (doc.data()['sizeBytes'] as num?)?.toInt();
        if (size == null) continue;
        used += size;
        files++;
      }

      final configDoc = await firestore
          .collection('schools')
          .doc(context.schoolId)
          .collection('configs')
          .doc('storage')
          .get();
      final quota = (configDoc.data()?['quotaBytes'] as num?)?.toInt() ?? 0;

      return Right(
        StorageUsage(usedBytes: used, quotaBytes: quota, fileCount: files),
      );
    } catch (_) {
      return const Right(StorageUsage());
    }
  }

  @override
  Future<Either<Failure, SubjectResource>> uploadFile({
    required ActiveResponsibilityContext context,
    required String fileName,
    required Uint8List bytes,
    String? folderId,
    String? description,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  }) async {
    final guard = _authorize(context, Permission.subjectResourceUpload);
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final usage = await getStorageUsage(context: context);
    final current = usage.getOrElse(() => const StorageUsage());

    final decision = ClassResourcePolicy.canUpload(
      fileName: fileName,
      sizeBytes: bytes.length,
      currentUsageBytes: current.usedBytes,
      quotaBytes: current.quotaBytes,
    );
    if (!decision.isAllowed) {
      return Left(ValidationFailure(decision.message!));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure('Uploading needs an internet connection.'),
      );
    }

    final id = uuid.v4();
    final kind = ClassResourceKind.fromExtension(_extensionOf(fileName));
    // Rooted at the school, subject and class so a stray path cannot write
    // into another tenant's or subject's area.
    final path =
        'subject_resources/${context.schoolId}/${context.subjectId}/${context.classId}/$id-$fileName';

    try {
      final ref = storage.ref(path);
      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      final resource = SubjectResource(
        id: id,
        schoolId: context.schoolId,
        campusId: context.campusId,
        subjectId: context.subjectId ?? '',
        classId: context.classId ?? '',
        streamId: context.streamId,
        academicYearId: context.academicYearId,
        termId: context.termId,
        name: fileName,
        description: description,
        kind: kind,
        audience: audience,
        storagePath: path,
        downloadUrl: url,
        sizeBytes: bytes.length,
        folderId: folderId,
        uploadedByUserId: context.userId,
        uploadedAt: DateTime.now(),
        roleAssignmentId: context.roleAssignmentId,
      );

      await _save(resource);
      await auditService.record(
        context: context,
        action: 'resource.uploaded',
        entityType: 'subject_resource',
        entityId: id,
        newValue: {'name': fileName, 'sizeBytes': bytes.length},
      );

      return Right(resource);
    } catch (_) {
      return const Left(ServerFailure('Could not upload this file.'));
    }
  }

  @override
  Future<Either<Failure, SubjectResource>> addLink({
    required ActiveResponsibilityContext context,
    required String name,
    required String url,
    String? folderId,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  }) async {
    final guard = _authorize(context, Permission.subjectResourceUpload);
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final decision = ClassResourcePolicy.canAddLink(name: name, url: url);
    if (!decision.isAllowed) {
      return Left(ValidationFailure(decision.message!));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure('Adding a link needs an internet connection.'),
      );
    }

    final resource = SubjectResource(
      id: uuid.v4(),
      schoolId: context.schoolId,
      campusId: context.campusId,
      subjectId: context.subjectId ?? '',
      classId: context.classId ?? '',
      streamId: context.streamId,
      academicYearId: context.academicYearId,
      termId: context.termId,
      name: name.trim(),
      kind: ClassResourceKind.link,
      audience: audience,
      externalUrl: url.trim(),
      folderId: folderId,
      uploadedByUserId: context.userId,
      uploadedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await _save(resource);
      await auditService.record(
        context: context,
        action: 'resource.uploaded',
        entityType: 'subject_resource',
        entityId: resource.id,
        newValue: {'name': resource.name, 'kind': 'link'},
      );
      return Right(resource);
    } catch (_) {
      return const Left(ServerFailure('Could not add this link.'));
    }
  }

  @override
  Future<Either<Failure, SubjectResource>> createFolder({
    required ActiveResponsibilityContext context,
    required String name,
    String? parentFolderId,
  }) async {
    final guard = _authorize(context, Permission.subjectResourceUpload);
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    if (name.trim().length < 2) {
      return const Left(ValidationFailure('Give the folder a name.'));
    }

    final folder = SubjectResource(
      id: uuid.v4(),
      schoolId: context.schoolId,
      campusId: context.campusId,
      subjectId: context.subjectId ?? '',
      classId: context.classId ?? '',
      streamId: context.streamId,
      academicYearId: context.academicYearId,
      termId: context.termId,
      name: name.trim(),
      kind: ClassResourceKind.folder,
      folderId: parentFolderId,
      uploadedByUserId: context.userId,
      uploadedAt: DateTime.now(),
      roleAssignmentId: context.roleAssignmentId,
    );

    try {
      await _save(folder);
      return Right(folder);
    } catch (_) {
      return const Left(ServerFailure('Could not create this folder.'));
    }
  }

  @override
  Future<Either<Failure, SubjectResource>> share({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
    required ClassResourceAudience audience,
  }) async {
    final guard = _authorize(context, Permission.subjectResourceShare);
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure('Sharing needs an internet connection.'),
      );
    }

    final shared = resource.copyWith(audience: audience);

    try {
      await _save(shared);
      await auditService.record(
        context: context,
        action: 'resource.shared',
        entityType: 'subject_resource',
        entityId: resource.id,
        previousValue: {'audience': resource.audience.name},
        newValue: {'audience': audience.name},
      );
      return Right(shared);
    } catch (_) {
      return const Left(ServerFailure('Could not share this resource.'));
    }
  }

  @override
  Future<Either<Failure, void>> remove({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
  }) async {
    if (resource.classId != context.classId ||
        resource.subjectId != context.subjectId) {
      return const Left(
        PermissionDeniedFailure('That resource belongs to another subject or class.'),
      );
    }
    if (resource.origin == ClassResourceOrigin.ownUpload &&
        resource.uploadedByUserId != context.userId) {
      return const Left(
        PermissionDeniedFailure(
          'Another staff member uploaded this. You can remove it from your '
          'subject, but not delete it.',
        ),
      );
    }
    final removesStoredFile = resource.deleteRemovesFile;

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Removing a resource needs an internet connection.',
        ),
      );
    }

    try {
      await _resources(context.schoolId).doc(resource.id).delete();

      if (removesStoredFile && resource.storagePath != null) {
        try {
          await storage.ref(resource.storagePath!).delete();
        } catch (_) {
          // The row is already gone; a stranded blob is a storage cleanup
          // matter, not a reason to fail the teacher's action.
        }
      }

      await localDataSource.deleteResourceLocal(resource.id);

      await auditService.record(
        context: context,
        action: removesStoredFile ? 'resource.deleted' : 'resource.detached',
        entityType: 'subject_resource',
        entityId: resource.id,
        previousValue: {'name': resource.name},
      );

      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Could not remove this resource.'));
    }
  }

  @override
  Future<Either<Failure, void>> downloadForOffline({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
  }) async {
    if (resource.isFolder) {
      return const Left(
        ValidationFailure('A folder cannot be downloaded, only its files.'),
      );
    }

    final url = resource.downloadUrl;
    if (url == null) {
      return const Left(
        ValidationFailure('This resource has no file to download.'),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        OfflineNotAllowedFailure(
          'Downloading needs a connection - there is nothing to save '
          'without one.',
        ),
      );
    }

    try {
      final response = await httpClient.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return const Left(ServerFailure('Could not download this file.'));
      }

      await localDataSource.downloadForOffline(
        resource.copyWith(availableOffline: true),
        response.bodyBytes,
      );
      await _save(resource.copyWith(availableOffline: true));

      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Could not download this file.'));
    }
  }

  @override
  Future<Either<Failure, void>> removeDownload({
    required ActiveResponsibilityContext context,
    required SubjectResource resource,
  }) async {
    await localDataSource.removeDownload(resource.id);

    if (await networkInfo.isConnected) {
      try {
        await _save(resource.copyWith(availableOffline: false));
      } catch (_) {
        // The on-device copy is already gone, which is the part the teacher
        // asked for.
      }
    }

    return const Right(null);
  }

  @override
  Future<bool> isDownloaded(String resourceId) async {
    return await localDataSource.getLocalFilePath(resourceId) != null;
  }

  Future<void> _save(SubjectResource resource) async {
    await localDataSource.saveResourceLocal(resource);
    return _resources(resource.schoolId).doc(resource.id).set({
      'schoolId': resource.schoolId,
      'campusId': resource.campusId,
      'subjectId': resource.subjectId,
      'classId': resource.classId,
      'streamId': resource.streamId,
      'academicYearId': resource.academicYearId,
      'termId': resource.termId,
      'name': resource.name,
      'description': resource.description,
      'kind': resource.kind.name,
      'origin': resource.origin.name,
      'audience': resource.audience.name,
      'storagePath': resource.storagePath,
      'downloadUrl': resource.downloadUrl,
      'externalUrl': resource.externalUrl,
      'sizeBytes': resource.sizeBytes,
      'mimeType': resource.mimeType,
      'folderId': resource.folderId,
      'sourceResourceId': resource.sourceResourceId,
      'availableOffline': resource.availableOffline,
      'uploadedByUserId': resource.uploadedByUserId,
      'uploadedAt': Timestamp.fromDate(resource.uploadedAt),
      'roleAssignmentId': resource.roleAssignmentId,
      'downloadCount': resource.downloadCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  SubjectResource _fromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    return SubjectResource(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String?,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      kind: ClassResourceKind.fromId(data['kind'] as String?),
      origin: ClassResourceOrigin.fromId(data['origin'] as String?),
      audience: ClassResourceAudience.fromId(data['audience'] as String?),
      storagePath: data['storagePath'] as String?,
      downloadUrl: data['downloadUrl'] as String?,
      externalUrl: data['externalUrl'] as String?,
      sizeBytes: (data['sizeBytes'] as num?)?.toInt(),
      mimeType: data['mimeType'] as String?,
      folderId: data['folderId'] as String?,
      sourceResourceId: data['sourceResourceId'] as String?,
      availableOffline: data['availableOffline'] as bool? ?? false,
      uploadedByUserId: data['uploadedByUserId'] as String? ?? '',
      uploadedAt:
          (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
      downloadCount: (data['downloadCount'] as num?)?.toInt() ?? 0,
    );
  }

  static String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}
