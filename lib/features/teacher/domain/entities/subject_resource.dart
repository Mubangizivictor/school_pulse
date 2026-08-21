import 'package:equatable/equatable.dart';

import 'class_resource.dart';

/// One file, link or folder in a subject's resource area for one
/// class/stream.
///
/// Deliberately its own entity rather than widening [ClassResource]:
/// [ClassResource.classId] is required and the two never mix in one query
/// (a class's resource area and a subject's are different Firestore
/// collections with different scope), so a shared entity would need most of
/// its fields nullable-by-role. Kind/origin/audience reuse the class enums
/// unchanged - what a resource *is* does not differ by role, only what it is
/// scoped to.
class SubjectResource extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String subjectId;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final String? termId;

  final String name;
  final String? description;
  final ClassResourceKind kind;
  final ClassResourceOrigin origin;
  final ClassResourceAudience audience;

  final String? storagePath;
  final String? downloadUrl;
  final String? externalUrl;

  final int? sizeBytes;
  final String? mimeType;

  final String? folderId;
  final String? sourceResourceId;

  final bool availableOffline;

  final String uploadedByUserId;
  final DateTime uploadedAt;
  final String roleAssignmentId;
  final int downloadCount;

  const SubjectResource({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.subjectId,
    required this.classId,
    this.streamId,
    required this.academicYearId,
    this.termId,
    required this.name,
    this.description,
    this.kind = ClassResourceKind.other,
    this.origin = ClassResourceOrigin.ownUpload,
    this.audience = ClassResourceAudience.teacherOnly,
    this.storagePath,
    this.downloadUrl,
    this.externalUrl,
    this.sizeBytes,
    this.mimeType,
    this.folderId,
    this.sourceResourceId,
    this.availableOffline = false,
    this.uploadedByUserId = '',
    required this.uploadedAt,
    this.roleAssignmentId = '',
    this.downloadCount = 0,
  });

  bool get isFolder => kind == ClassResourceKind.folder;
  bool get isLink => kind == ClassResourceKind.link;

  bool get deleteRemovesFile =>
      origin == ClassResourceOrigin.ownUpload && sourceResourceId == null;

  String get sizeLabel {
    final bytes = sizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  SubjectResource copyWith({
    String? name,
    String? description,
    ClassResourceAudience? audience,
    String? folderId,
    bool? availableOffline,
    String? downloadUrl,
    int? downloadCount,
    String? roleAssignmentId,
  }) {
    return SubjectResource(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      subjectId: subjectId,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
      name: name ?? this.name,
      description: description ?? this.description,
      kind: kind,
      origin: origin,
      audience: audience ?? this.audience,
      storagePath: storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      externalUrl: externalUrl,
      sizeBytes: sizeBytes,
      mimeType: mimeType,
      folderId: folderId ?? this.folderId,
      sourceResourceId: sourceResourceId,
      availableOffline: availableOffline ?? this.availableOffline,
      uploadedByUserId: uploadedByUserId,
      uploadedAt: uploadedAt,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      downloadCount: downloadCount ?? this.downloadCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    subjectId,
    classId,
    streamId,
    academicYearId,
    termId,
    name,
    description,
    kind,
    origin,
    audience,
    storagePath,
    downloadUrl,
    externalUrl,
    sizeBytes,
    mimeType,
    folderId,
    sourceResourceId,
    availableOffline,
    uploadedByUserId,
    uploadedAt,
    roleAssignmentId,
    downloadCount,
  ];
}
