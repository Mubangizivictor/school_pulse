import 'package:firebase_storage/firebase_storage.dart';

import '../domain/entities/calendar_event.dart';
import '../presentation/screens/add_event_flow/add_event_draft.dart';

/// Uploads attachments staged during the Add Event wizard, only called
/// after the event document exists (an eventId is required for the
/// tenant-scoped Storage path). Mirrors the Storage pattern used by
/// StaffDocumentsUploader: best-effort per-file, one failed upload does not
/// roll back the event that was already saved.
class CalendarAttachmentsUploader {
  final FirebaseStorage storage;
  static const maxSizeBytes = 10 * 1024 * 1024; // 10 MB per file
  static const allowedExtensions = {
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
    'xls',
    'xlsx',
  };

  CalendarAttachmentsUploader({FirebaseStorage? storage})
    : storage = storage ?? FirebaseStorage.instance;

  bool isAllowed(StagedCalendarAttachment staged) {
    if (staged.sizeBytes > maxSizeBytes) return false;
    final ext = staged.fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(ext);
  }

  /// Uploads all staged attachments and returns the successfully uploaded
  /// ones as [CalendarAttachment]s plus the filenames of any that failed
  /// (either validation or upload), so the caller can show a non-blocking
  /// warning without losing the rest of the save.
  Future<({List<CalendarAttachment> uploaded, List<String> failed})> uploadAll({
    required String schoolId,
    required String eventId,
    required List<StagedCalendarAttachment> staged,
  }) async {
    final uploaded = <CalendarAttachment>[];
    final failed = <String>[];
    for (final item in staged) {
      if (!isAllowed(item)) {
        failed.add(item.fileName);
        continue;
      }
      try {
        final ref = storage.ref(
          'schools/$schoolId/calendar_events/$eventId/attachments/'
          '${DateTime.now().millisecondsSinceEpoch}_${item.fileName}',
        );
        await ref.putFile(item.file);
        final url = await ref.getDownloadURL();
        uploaded.add(
          CalendarAttachment(
            name: item.fileName,
            url: url,
            sizeBytes: item.sizeBytes,
          ),
        );
      } catch (_) {
        failed.add(item.fileName);
      }
    }
    return (uploaded: uploaded, failed: failed);
  }
}
