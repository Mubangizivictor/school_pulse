import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads a supporting document for a direct-enrolment draft to
///
///   schools/{schoolId}/students/{studentId}/documents/{docId}
///
/// This is the draft-first path storage.rules already anticipates (the
/// draft's studentId is minted client-side before the student doc exists;
/// the school id in the path keeps the write tenant-scoped even though no
/// student doc exists yet). Metadata is only attached to a real student
/// record by `directEnrolLearner` after it validates the draft.
///
/// Client-side validation mirrors the tenant's configured requirement
/// (`allowedTypes`/`maxSizeMb` on `enrolmentPolicy.documentRequirements`)
/// so a rejected file never reaches Storage — the server-side content-type
/// allowlist in storage.rules is the actual security boundary, this is UX.

typedef PutStudentDocumentBytes =
    Future<void> Function(
      String objectPath,
      Uint8List bytes,
      String contentType,
    );

class DocumentValidationResult {
  final bool allowed;
  final String? reason;
  const DocumentValidationResult.ok() : allowed = true, reason = null;
  const DocumentValidationResult.rejected(this.reason) : allowed = false;
}

class StudentDocumentUploader {
  final PutStudentDocumentBytes _put;

  static const int defaultMaxSizeMb = 25;
  static const List<String> defaultAllowedTypes = ['pdf', 'jpg', 'jpeg', 'png'];

  StudentDocumentUploader({
    FirebaseStorage? storage,
    PutStudentDocumentBytes? put,
  }) : _put =
           put ??
           ((objectPath, bytes, contentType) async {
             await (storage ?? FirebaseStorage.instance)
                 .ref(objectPath)
                 .putData(bytes, SettableMetadata(contentType: contentType));
           });

  DocumentValidationResult validate({
    required String fileName,
    required int sizeBytes,
    List<String>? allowedTypes,
    int? maxSizeMb,
  }) {
    final types = (allowedTypes == null || allowedTypes.isEmpty)
        ? defaultAllowedTypes
        : allowedTypes.map((t) => t.toLowerCase().trim()).toList();
    final limitBytes = (maxSizeMb ?? defaultMaxSizeMb) * 1024 * 1024;
    if (sizeBytes <= 0) {
      return const DocumentValidationResult.rejected('The file is empty.');
    }
    if (sizeBytes > limitBytes) {
      return DocumentValidationResult.rejected(
        'File exceeds the ${maxSizeMb ?? defaultMaxSizeMb} MB limit for this document.',
      );
    }
    final parts = fileName.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : '';
    if (ext.isEmpty || !types.contains(ext)) {
      return DocumentValidationResult.rejected(
        'Accepted formats: ${types.join(', ').toUpperCase()}.',
      );
    }
    return const DocumentValidationResult.ok();
  }

  String _contentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String> upload({
    required String schoolId,
    required String studentId,
    required String docId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ext = fileName.contains('.') ? fileName.split('.').last : '';
    final objectPath = 'schools/$schoolId/students/$studentId/documents/$docId';
    await _put(objectPath, bytes, _contentType(ext));
    return objectPath;
  }
}
