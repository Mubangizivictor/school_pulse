import '../entities/class_resource.dart';

enum ResourceRefusal {
  nameRequired,
  unsafeFileType,
  fileTooLarge,
  storageQuotaExceeded,
  invalidLink,
  notOwner,
  notInThisClass,
}

class ResourceDecision {
  final bool isAllowed;
  final ResourceRefusal? refusal;
  final String? message;

  const ResourceDecision.allowed()
      : isAllowed = true,
        refusal = null,
        message = null;

  const ResourceDecision.refused(this.refusal, this.message) : isAllowed = false;
}

/// What may be uploaded to a class folder, and what deleting one means.
///
/// The allow-list is the important half. Refusing known-bad extensions is the
/// wrong shape - the list of dangerous types is open-ended and grows - so
/// anything the app cannot positively identify as a document, image, audio or
/// video is refused, and an executable therefore never needs naming.
class ClassResourcePolicy {
  const ClassResourcePolicy._();

  /// Per-file ceiling. Generous enough for a scanned worksheet or a short
  /// recording, small enough that one upload cannot exhaust a school's quota.
  static const int maxFileBytes = 25 * 1024 * 1024;

  /// Video gets more room, because a lesson recording is legitimately larger
  /// than a worksheet.
  static const int maxVideoBytes = 200 * 1024 * 1024;

  /// The kinds a class folder accepts. [ClassResourceKind.other] is
  /// deliberately absent: unrecognised means refused.
  static const Set<ClassResourceKind> allowedKinds = {
    ClassResourceKind.document,
    ClassResourceKind.spreadsheet,
    ClassResourceKind.presentation,
    ClassResourceKind.image,
    ClassResourceKind.audio,
    ClassResourceKind.video,
  };

  static int limitFor(ClassResourceKind kind) =>
      kind == ClassResourceKind.video ? maxVideoBytes : maxFileBytes;

  static ResourceDecision canUpload({
    required String fileName,
    required int sizeBytes,
    required int currentUsageBytes,
    required int quotaBytes,
  }) {
    if (fileName.trim().isEmpty) {
      return const ResourceDecision.refused(
        ResourceRefusal.nameRequired,
        'The file needs a name.',
      );
    }

    final extension = _extensionOf(fileName);
    final kind = ClassResourceKind.fromExtension(extension);

    if (!allowedKinds.contains(kind)) {
      return ResourceDecision.refused(
        ResourceRefusal.unsafeFileType,
        extension.isEmpty
            ? 'Files need a recognised extension.'
            : '.$extension files cannot be shared with a class.',
      );
    }

    final limit = limitFor(kind);
    if (sizeBytes > limit) {
      return ResourceDecision.refused(
        ResourceRefusal.fileTooLarge,
        'That file is larger than the ${(limit / (1024 * 1024)).round()} MB '
        'limit.',
      );
    }

    if (quotaBytes > 0 && currentUsageBytes + sizeBytes > quotaBytes) {
      return const ResourceDecision.refused(
        ResourceRefusal.storageQuotaExceeded,
        'Your school has run out of storage. Ask your administrator.',
      );
    }

    return const ResourceDecision.allowed();
  }

  /// Links get a narrower check than files, but still a check: a link is the
  /// obvious way round an upload guard.
  static ResourceDecision canAddLink({
    required String name,
    required String url,
  }) {
    if (name.trim().length < 2) {
      return const ResourceDecision.refused(
        ResourceRefusal.nameRequired,
        'Give the link a name.',
      );
    }

    final parsed = Uri.tryParse(url.trim());
    if (parsed == null ||
        !parsed.hasAuthority ||
        !(parsed.scheme == 'http' || parsed.scheme == 'https')) {
      return const ResourceDecision.refused(
        ResourceRefusal.invalidLink,
        'Enter a full web address starting with https://',
      );
    }

    return const ResourceDecision.allowed();
  }

  /// Whether this teacher may remove the resource from the class, and whether
  /// doing so should delete the stored file.
  ///
  /// The distinction matters: detaching the school library's copy of a
  /// textbook from one class must not delete it for the whole school.
  static ResourceDeletion canDelete({
    required ClassResource resource,
    required String userId,
    required String classId,
  }) {
    if (resource.classId != classId) {
      return const ResourceDeletion(
        decision: ResourceDecision.refused(
          ResourceRefusal.notInThisClass,
          'That resource belongs to another class.',
        ),
        removesStoredFile: false,
      );
    }

    if (resource.origin == ClassResourceOrigin.ownUpload &&
        resource.uploadedByUserId != userId) {
      return const ResourceDeletion(
        decision: ResourceDecision.refused(
          ResourceRefusal.notOwner,
          'Another staff member uploaded this. You can remove it from your '
          'class, but not delete it.',
        ),
        removesStoredFile: false,
      );
    }

    return ResourceDeletion(
      decision: const ResourceDecision.allowed(),
      removesStoredFile: resource.deleteRemovesFile,
    );
  }

  static String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}

/// A deletion outcome: whether it is permitted, and whether the stored file
/// goes with it.
class ResourceDeletion {
  final ResourceDecision decision;
  final bool removesStoredFile;

  const ResourceDeletion({
    required this.decision,
    required this.removesStoredFile,
  });

  bool get isAllowed => decision.isAllowed;
}
