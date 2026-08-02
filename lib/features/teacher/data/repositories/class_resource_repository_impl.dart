import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_resource.dart';
import '../../domain/policies/class_resource_policy.dart';
import '../../domain/repositories/class_resource_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../../domain/services/subject_audit_service.dart';

class ClassResourceRepositoryImpl implements ClassResourceRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final ClassTeacherAssignmentService assignmentService;
  final SubjectAuditService auditService;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  ClassResourceRepositoryImpl({
    required this.firestore,
    required this.storage,
    required this.assignmentService,
    required this.auditService,
    required this.networkInfo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  CollectionReference<Map<String, dynamic>> _resources(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('class_resources');

  @override
  Future<Either<Failure, List<ClassResource>>> getResources({
    required ActiveResponsibilityContext context,
    String? folderId,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classResourceUpload,
    );
    if (guard.isLeft()) return guard.fold(Left.new, (_) => const Right([]));

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a class.',
      ));
    }

    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'You are offline. Resources need a connection.',
      ));
    }

    try {
      final snapshot = await _resources(context.schoolId)
          .where('classId', isEqualTo: classId)
          .where('academicYearId', isEqualTo: context.academicYearId)
          .orderBy('uploadedAt', descending: true)
          .get();

      final all = snapshot.docs
          .map((d) => _fromDoc(d.id, context.schoolId, d.data()))
          .toList();

      // Folder filtering happens here rather than in the query so the root
      // (folderId == null) does not need a separate index.
      return Right(all.where((r) => r.folderId == folderId).toList());
    } catch (_) {
      return const Left(ServerFailure(
        'Could not load resources. Pull down to retry.',
      ));
    }
  }

  @override
  Future<Either<Failure, StorageUsage>> getStorageUsage({
    required ActiveResponsibilityContext context,
  }) async {
    try {
      final snapshot = await _resources(context.schoolId)
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

      return Right(StorageUsage(
        usedBytes: used,
        quotaBytes: quota,
        fileCount: files,
      ));
    } catch (_) {
      return const Right(StorageUsage());
    }
  }

  @override
  Future<Either<Failure, ClassResource>> uploadFile({
    required ActiveResponsibilityContext context,
    required String fileName,
    required Uint8List bytes,
    String? folderId,
    String? description,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  }) async {
    final fresh = await assignmentService.authorizeFresh(
      permission: Permission.classResourceUpload,
    );
    if (fresh.isLeft()) {
      return fresh.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
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
      return const Left(OfflineNotAllowedFailure(
        'Uploading needs an internet connection.',
      ));
    }

    final id = uuid.v4();
    final kind = ClassResourceKind.fromExtension(_extensionOf(fileName));
    // Rooted at the school and class so a stray path cannot write into
    // another tenant's area.
    final path =
        'class_resources/${context.schoolId}/${context.classId}/$id-$fileName';

    try {
      final ref = storage.ref(path);
      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      final resource = ClassResource(
        id: id,
        schoolId: context.schoolId,
        campusId: context.campusId,
        classId: context.classId ?? '',
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
        entityType: 'class_resource',
        entityId: id,
        newValue: {'name': fileName, 'sizeBytes': bytes.length},
      );

      return Right(resource);
    } catch (_) {
      return const Left(ServerFailure('Could not upload this file.'));
    }
  }

  @override
  Future<Either<Failure, ClassResource>> addLink({
    required ActiveResponsibilityContext context,
    required String name,
    required String url,
    String? folderId,
    ClassResourceAudience audience = ClassResourceAudience.teacherOnly,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classResourceUpload,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    // Links get their own check - an unvalidated one is the obvious way round
    // the upload guard.
    final decision = ClassResourcePolicy.canAddLink(name: name, url: url);
    if (!decision.isAllowed) {
      return Left(ValidationFailure(decision.message!));
    }

    if (!await networkInfo.isConnected) {
      return const Left(OfflineNotAllowedFailure(
        'Adding a link needs an internet connection.',
      ));
    }

    final resource = ClassResource(
      id: uuid.v4(),
      schoolId: context.schoolId,
      campusId: context.campusId,
      classId: context.classId ?? '',
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
        entityType: 'class_resource',
        entityId: resource.id,
        newValue: {'name': resource.name, 'kind': 'link'},
      );
      return Right(resource);
    } catch (_) {
      return const Left(ServerFailure('Could not add this link.'));
    }
  }

  @override
  Future<Either<Failure, ClassResource>> createFolder({
    required ActiveResponsibilityContext context,
    required String name,
    String? parentFolderId,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classResourceUpload,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    if (name.trim().length < 2) {
      return const Left(ValidationFailure('Give the folder a name.'));
    }

    final folder = ClassResource(
      id: uuid.v4(),
      schoolId: context.schoolId,
      campusId: context.campusId,
      classId: context.classId ?? '',
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
  Future<Either<Failure, ClassResource>> share({
    required ActiveResponsibilityContext context,
    required ClassResource resource,
    required ClassResourceAudience audience,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classResourceShare,
      classId: resource.classId,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    if (!await networkInfo.isConnected) {
      return const Left(OfflineNotAllowedFailure(
        'Sharing needs an internet connection.',
      ));
    }

    final shared = resource.copyWith(audience: audience);

    try {
      await _save(shared);
      await auditService.record(
        context: context,
        action: 'resource.shared',
        entityType: 'class_resource',
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
    required ClassResource resource,
  }) async {
    final outcome = ClassResourcePolicy.canDelete(
      resource: resource,
      userId: context.userId,
      classId: context.classId ?? '',
    );
    if (!outcome.isAllowed) {
      return Left(PermissionDeniedFailure(outcome.decision.message!));
    }

    if (!await networkInfo.isConnected) {
      return const Left(OfflineNotAllowedFailure(
        'Removing a resource needs an internet connection.',
      ));
    }

    try {
      await _resources(context.schoolId).doc(resource.id).delete();

      // The stored file goes only when this class owns it. Detaching the
      // library's copy from one class must not delete it for the school.
      if (outcome.removesStoredFile && resource.storagePath != null) {
        try {
          await storage.ref(resource.storagePath!).delete();
        } catch (_) {
          // The row is already gone; a stranded blob is a storage cleanup
          // matter, not a reason to fail the teacher's action.
        }
      }

      await auditService.record(
        context: context,
        action: outcome.removesStoredFile
            ? 'resource.deleted'
            : 'resource.detached',
        entityType: 'class_resource',
        entityId: resource.id,
        previousValue: {'name': resource.name},
      );

      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Could not remove this resource.'));
    }
  }

  Future<void> _save(ClassResource resource) {
    return _resources(resource.schoolId).doc(resource.id).set({
      'schoolId': resource.schoolId,
      'campusId': resource.campusId,
      'classId': resource.classId,
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

  ClassResource _fromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    return ClassResource(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
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
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
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
