import 'package:equatable/equatable.dart';

/// What kind of thing a resource is. Drives the icon and the preview, and -
/// more importantly - what the upload guard will accept.
enum ClassResourceKind {
  document,
  spreadsheet,
  presentation,
  image,
  audio,
  video,
  link,
  folder,
  other;

  static ClassResourceKind fromId(String? id) {
    if (id == null) return ClassResourceKind.other;
    for (final k in ClassResourceKind.values) {
      if (k.name == id) return k;
    }
    return ClassResourceKind.other;
  }

  /// Resolves a kind from a file extension. Anything unrecognised lands on
  /// [other], which the upload guard then refuses - allowing by default is
  /// how an executable gets into a class folder.
  static ClassResourceKind fromExtension(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return switch (ext) {
      'pdf' || 'doc' || 'docx' || 'txt' || 'rtf' || 'odt' =>
        ClassResourceKind.document,
      'xls' || 'xlsx' || 'csv' || 'ods' => ClassResourceKind.spreadsheet,
      'ppt' || 'pptx' || 'odp' => ClassResourceKind.presentation,
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' || 'heic' =>
        ClassResourceKind.image,
      'mp3' || 'wav' || 'm4a' || 'aac' || 'ogg' => ClassResourceKind.audio,
      'mp4' || 'mov' || 'm4v' || 'webm' => ClassResourceKind.video,
      _ => ClassResourceKind.other,
    };
  }
}

/// Where a resource came from, which decides what deleting it means.
enum ClassResourceOrigin {
  /// Uploaded by this teacher for this class. Deleting removes the file.
  ownUpload,

  /// Attached from the school library or another teacher's folder. Deleting
  /// detaches it from this class and leaves the original alone.
  attached;

  static ClassResourceOrigin fromId(String? id) =>
      id == 'attached' ? ClassResourceOrigin.attached : ClassResourceOrigin.ownUpload;
}

/// Who a resource has been shared with. Always inside the class - the options
/// pick which part of it, never a wider audience.
enum ClassResourceAudience {
  teacherOnly,
  students,
  studentsAndGuardians;

  static ClassResourceAudience fromId(String? id) {
    if (id == null) return ClassResourceAudience.teacherOnly;
    for (final a in ClassResourceAudience.values) {
      if (a.name == id) return a;
    }
    return ClassResourceAudience.teacherOnly;
  }

  String get label => switch (this) {
        ClassResourceAudience.teacherOnly => 'Only me',
        ClassResourceAudience.students => 'My class',
        ClassResourceAudience.studentsAndGuardians => 'Class and guardians',
      };
}

/// One file, link or folder in the class's resource area.
class ClassResource extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String classId;
  final String academicYearId;
  final String? termId;

  final String name;
  final String? description;
  final ClassResourceKind kind;
  final ClassResourceOrigin origin;
  final ClassResourceAudience audience;

  /// Storage path for an uploaded file, or the URL for a link. Null for a
  /// folder.
  final String? storagePath;
  final String? downloadUrl;
  final String? externalUrl;

  /// Null for links and folders.
  final int? sizeBytes;
  final String? mimeType;

  /// Parent folder, or null at the root of the class area.
  final String? folderId;

  /// Set when this row points at a file another teacher or the library owns.
  /// Deleting this row must not remove that file.
  final String? sourceResourceId;

  /// Marked for offline use, so the sync engine keeps a copy.
  final bool availableOffline;

  final String uploadedByUserId;
  final DateTime uploadedAt;
  final String roleAssignmentId;
  final int downloadCount;

  const ClassResource({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.classId,
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

  /// Whether removing this row should also remove the stored file. False for
  /// anything attached from elsewhere - tidying one class's folder must not
  /// destroy the library's copy.
  bool get deleteRemovesFile =>
      origin == ClassResourceOrigin.ownUpload && sourceResourceId == null;

  String get sizeLabel {
    final bytes = sizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  ClassResource copyWith({
    String? name,
    String? description,
    ClassResourceAudience? audience,
    String? folderId,
    bool? availableOffline,
    String? downloadUrl,
    int? downloadCount,
    String? roleAssignmentId,
  }) {
    return ClassResource(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
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
        classId,
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
