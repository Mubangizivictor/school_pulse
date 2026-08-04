import 'package:firebase_storage/firebase_storage.dart';

import '../models/add_staff_draft.dart';

/// Uploads documents staged during the wizard, only called after Step 11's
/// Confirm succeeds and a uid exists (the staff account doesn't exist
/// before then). Mirrors the Storage pattern used in
/// messages_repository_impl.dart. Best-effort per-file: one failed upload
/// doesn't roll back the staff account that was already created.
class StaffDocumentsUploader {
  final FirebaseStorage storage;

  StaffDocumentsUploader({FirebaseStorage? storage})
    : storage = storage ?? FirebaseStorage.instance;

  /// Returns the filenames of any documents that failed to upload, so the
  /// caller can show a non-blocking warning.
  Future<List<String>> uploadAll({
    required String schoolId,
    required String uid,
    required List<StagedDocument> documents,
  }) async {
    final failed = <String>[];
    for (final doc in documents) {
      try {
        final ref = storage.ref(
          'schools/$schoolId/staff/$uid/documents/${doc.type.name}_${DateTime.now().millisecondsSinceEpoch}_${doc.fileName}',
        );
        await ref.putFile(doc.file);
      } catch (_) {
        failed.add(doc.fileName);
      }
    }
    return failed;
  }
}
