import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

import '../models/add_staff_draft.dart';

/// Uploads documents staged during the wizard, only called after Step 11's
/// Confirm succeeds and a uid exists (the staff account doesn't exist
/// before then). Mirrors the Storage pattern used in
/// messages_repository_impl.dart. Best-effort per-file: one failed upload
/// doesn't roll back the staff account that was already created.
class StaffDocumentsUploader {
  final FirebaseStorage storage;
  final FirebaseFirestore firestore;

  StaffDocumentsUploader({
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
  }) : storage = storage ?? FirebaseStorage.instance,
       firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the filenames of any documents that failed to upload, so the
  /// caller can show a non-blocking warning. Successful uploads are also
  /// merged onto users/{uid}.documents so they can be listed back later.
  Future<List<String>> uploadAll({
    required String schoolId,
    required String uid,
    required List<StagedDocument> documents,
  }) async {
    final failed = <String>[];
    final uploaded = <StaffDocumentRef>[];
    for (final doc in documents) {
      try {
        final storagePath =
            'schools/$schoolId/staff/$uid/documents/${doc.type.name}_${DateTime.now().millisecondsSinceEpoch}_${doc.fileName}';
        await storage.ref(storagePath).putFile(doc.file);
        uploaded.add(
          StaffDocumentRef(
            type: doc.type.name,
            fileName: doc.fileName,
            storagePath: storagePath,
            uploadedAt: DateTime.now(),
          ),
        );
      } catch (_) {
        failed.add(doc.fileName);
      }
    }
    if (uploaded.isNotEmpty) {
      try {
        await firestore.collection('users').doc(uid).update({
          'documents': FieldValue.arrayUnion(
            uploaded.map((e) => e.toJson()).toList(),
          ),
        });
      } catch (_) {
        // Storage upload already succeeded; a failed Firestore merge here
        // just means the doc won't be listable until re-synced, not lost.
      }
    }
    return failed;
  }

  /// Uploads the staged profile photo, mirroring the
  /// `profile_photos/$uid/profile.jpg` convention used by
  /// edit_profile_screen.dart, then merges the resulting URL onto
  /// users/{uid}.photoUrl. Best-effort: a failure here doesn't affect the
  /// already-created staff account.
  Future<bool> uploadPhoto({
    required String schoolId,
    required String uid,
    required File photo,
  }) async {
    try {
      final reference = storage.ref(
        'schools/$schoolId/staff/$uid/profile/profile.jpg',
      );
      await reference.putFile(
        photo,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await reference.getDownloadURL();
      await firestore.collection('users').doc(uid).update({'photoUrl': url});
      return true;
    } catch (_) {
      return false;
    }
  }
}
