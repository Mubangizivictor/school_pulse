import 'package:isar/isar.dart';

import '../../domain/entities/class_resource.dart';
import '../../domain/entities/subject_resource.dart';

part 'subject_resource_isar_models.g.dart';

/// The cached subject resource area - mirrors [ClassResourceIsar] in
/// class_teacher_isar_models.dart exactly, scoped by subject+class instead
/// of class alone. Kept in its own file/part rather than added to the
/// already-large class models file.
@collection
class SubjectResourceIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String resourceId;

  @Index()
  late String schoolId;

  @Index()
  late String subjectId;

  @Index()
  late String classId;

  String? streamId;
  late String academicYearId;
  String? termId;
  late String campusId;

  late String name;
  String? description;
  late String kind;
  late String origin;
  late String audience;
  String? storagePath;
  String? downloadUrl;
  String? externalUrl;
  int? sizeBytes;
  String? mimeType;
  String? folderId;
  String? sourceResourceId;
  late bool availableOffline;
  late String uploadedByUserId;
  late DateTime uploadedAt;
  late String roleAssignmentId;
  late int downloadCount;

  /// Where the downloaded bytes live on this device, or null if this row is
  /// metadata only.
  String? localFilePath;

  late DateTime cachedAt;

  SubjectResource toEntity() => SubjectResource(
    id: resourceId,
    schoolId: schoolId,
    campusId: campusId,
    subjectId: subjectId,
    classId: classId,
    streamId: streamId,
    academicYearId: academicYearId,
    termId: termId,
    name: name,
    description: description,
    kind: ClassResourceKind.fromId(kind),
    origin: ClassResourceOrigin.fromId(origin),
    audience: ClassResourceAudience.fromId(audience),
    storagePath: storagePath,
    downloadUrl: downloadUrl,
    externalUrl: externalUrl,
    sizeBytes: sizeBytes,
    mimeType: mimeType,
    folderId: folderId,
    sourceResourceId: sourceResourceId,
    availableOffline: availableOffline,
    uploadedByUserId: uploadedByUserId,
    uploadedAt: uploadedAt,
    roleAssignmentId: roleAssignmentId,
    downloadCount: downloadCount,
  );

  static SubjectResourceIsar fromEntity(
    SubjectResource resource, {
    String? localFilePath,
  }) {
    return SubjectResourceIsar()
      ..resourceId = resource.id
      ..schoolId = resource.schoolId
      ..subjectId = resource.subjectId
      ..classId = resource.classId
      ..streamId = resource.streamId
      ..academicYearId = resource.academicYearId
      ..termId = resource.termId
      ..campusId = resource.campusId
      ..name = resource.name
      ..description = resource.description
      ..kind = resource.kind.name
      ..origin = resource.origin.name
      ..audience = resource.audience.name
      ..storagePath = resource.storagePath
      ..downloadUrl = resource.downloadUrl
      ..externalUrl = resource.externalUrl
      ..sizeBytes = resource.sizeBytes
      ..mimeType = resource.mimeType
      ..folderId = resource.folderId
      ..sourceResourceId = resource.sourceResourceId
      ..availableOffline = resource.availableOffline
      ..uploadedByUserId = resource.uploadedByUserId
      ..uploadedAt = resource.uploadedAt
      ..roleAssignmentId = resource.roleAssignmentId
      ..downloadCount = resource.downloadCount
      ..localFilePath = localFilePath
      ..cachedAt = DateTime.now();
  }
}
