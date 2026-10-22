import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads a communication's image/attachments to tenant-scoped Storage.
/// Mirrors CalendarAttachmentsUploader's pattern: validate extension/size
/// client-side (Storage rules re-validate server-side), best-effort per
/// file, save is never blocked by one failed upload.
class CommunicationAttachmentsUploader {
  final FirebaseStorage storage;
  static const maxImageBytes = 5 * 1024 * 1024; // 5 MB
  static const maxAttachmentBytes = 15 * 1024 * 1024; // 15 MB
  static const allowedImageExtensions = {'png', 'jpg', 'jpeg', 'webp'};
  static const allowedAttachmentExtensions = {
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'webp',
    'doc',
    'docx',
    'xls',
    'xlsx',
  };

  CommunicationAttachmentsUploader({FirebaseStorage? storage})
    : storage = storage ?? FirebaseStorage.instance;

  String? _extensionOf(String fileName) =>
      fileName.contains('.') ? fileName.split('.').last.toLowerCase() : null;

  bool isImageAllowed(String fileName, int sizeBytes) {
    final ext = _extensionOf(fileName);
    return ext != null &&
        allowedImageExtensions.contains(ext) &&
        sizeBytes <= maxImageBytes;
  }

  bool isAttachmentAllowed(String fileName, int sizeBytes) {
    final ext = _extensionOf(fileName);
    return ext != null &&
        allowedAttachmentExtensions.contains(ext) &&
        sizeBytes <= maxAttachmentBytes;
  }

  Future<String?> uploadImage({
    required String schoolId,
    required String campaignId,
    required File file,
    required String fileName,
    required int sizeBytes,
  }) async {
    if (!isImageAllowed(fileName, sizeBytes)) return null;
    try {
      final ref = storage.ref(
        'schools/$schoolId/communication_campaigns/$campaignId/image_'
        '${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<({List<String> uploadedUrls, List<String> failed})> uploadAttachments({
    required String schoolId,
    required String campaignId,
    required List<({File file, String fileName, int sizeBytes})> staged,
  }) async {
    final uploaded = <String>[];
    final failed = <String>[];
    for (final item in staged) {
      if (!isAttachmentAllowed(item.fileName, item.sizeBytes)) {
        failed.add(item.fileName);
        continue;
      }
      try {
        final ref = storage.ref(
          'schools/$schoolId/communication_campaigns/$campaignId/attachments/'
          '${DateTime.now().millisecondsSinceEpoch}_${item.fileName}',
        );
        await ref.putFile(item.file);
        uploaded.add(await ref.getDownloadURL());
      } catch (_) {
        failed.add(item.fileName);
      }
    }
    return (uploadedUrls: uploaded, failed: failed);
  }
}
