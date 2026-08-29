import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads a clinic-visit attachment (an injury photo, a scanned referral
/// letter, a lab slip) to the tenant-scoped, clinical-only Storage path
///
///   schools/{schoolId}/clinic_visits/{visitId}/attachments/{uuid}.{ext}
///
/// storage.rules gates that path with `canManageClinicalRecords()` — a nurse
/// or school-leadership role in the SAME school, never a parent, teacher, or
/// student — and forbids delete (an attachment stays with the record; a
/// correction is a new file plus a linked amendment on the visit).
///
/// Only called after the clinic_visits doc exists (a visitId is required for
/// the path). Best-effort per file: one failed upload does not roll back a
/// visit that was already recorded. Returns Storage *paths*, not download
/// URLs — a URL is resolved on demand by an authorised reader and is never
/// persisted on the visit.

/// Seam for tests: performs the actual byte upload to [objectPath] and
/// resolves when it is committed. Production wiring uses FirebaseStorage.
typedef PutClinicFile =
    Future<void> Function(String objectPath, File file, String contentType);

class ClinicAttachmentUploader {
  final PutClinicFile _put;

  /// Matches storage.rules `isSafeClinicalAttachment()`: image or PDF, < 10MB.
  static const int maxSizeBytes = 10 * 1024 * 1024;
  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'pdf',
  };

  ClinicAttachmentUploader({FirebaseStorage? storage, PutClinicFile? put})
    : _put =
          put ??
          ((objectPath, file, contentType) async {
            await (storage ?? FirebaseStorage.instance)
                .ref(objectPath)
                .putFile(file, SettableMetadata(contentType: contentType));
          });

  bool isAllowed({required String fileName, required int sizeBytes}) {
    if (sizeBytes <= 0 || sizeBytes > maxSizeBytes) return false;
    final parts = fileName.split('.');
    if (parts.length < 2) return false;
    return allowedExtensions.contains(parts.last.toLowerCase());
  }

  String _contentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Uploads [files] for one visit. Returns the Storage paths that succeeded
  /// and the source file names that failed (validation or upload), so the
  /// caller can surface a non-blocking warning without losing the rest.
  Future<({List<String> paths, List<String> failed})> uploadForVisit({
    required String schoolId,
    required String visitId,
    required List<({String fileName, int sizeBytes, File file})> files,
  }) async {
    final paths = <String>[];
    final failed = <String>[];
    for (final item in files) {
      if (!isAllowed(fileName: item.fileName, sizeBytes: item.sizeBytes)) {
        failed.add(item.fileName);
        continue;
      }
      final ext = item.fileName.split('.').last.toLowerCase();
      final objectPath =
          'schools/$schoolId/clinic_visits/$visitId/attachments/'
          '${DateTime.now().microsecondsSinceEpoch}.$ext';
      try {
        await _put(objectPath, item.file, _contentType(ext));
        paths.add(objectPath);
      } catch (_) {
        failed.add(item.fileName);
      }
    }
    return (paths: paths, failed: failed);
  }
}
