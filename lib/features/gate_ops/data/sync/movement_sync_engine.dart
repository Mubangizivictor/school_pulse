import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:school_pulse/core/network/network_info.dart';

/// One reusable class both `GateOpsRepositoryImpl` and the visitor
/// check-in/checkout paths call into, generalizing the
/// `VerificationEventRecorderImpl`/`NfcCredentialRepositoryImpl` shape. See
/// plan section 6 for the full per-record algorithm.
class MovementSyncEngine {
  final NetworkInfo networkInfo;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  MovementSyncEngine({
    required this.networkInfo,
    required this.firestore,
    required this.storage,
  });

  // Isar-first write already happened by the time this is called. Attempts
  // the push and reports success; never throws - a failed push is a normal
  // offline case, not an error.
  Future<bool> tryPush(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    if (!await networkInfo.isConnected) return false;
    try {
      await firestore.doc('$collectionPath/$docId').set({
        ...data,
        'serverTimestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // Sweeps caller-supplied pending rows, invoking onSynced per success so
  // the caller marks it synced in Isar. Used by a periodic timer and by
  // pull-to-refresh.
  Future<void> syncPending<T>({
    required List<T> pending,
    required String Function(T) idOf,
    required String Function(T) collectionPathOf,
    required Map<String, dynamic> Function(T) toFirestoreMap,
    required Future<void> Function(String id) onSynced,
  }) async {
    if (!await networkInfo.isConnected) return;
    for (final row in pending) {
      final pushed = await tryPush(
        collectionPathOf(row),
        idOf(row),
        toFirestoreMap(row),
      );
      if (pushed) await onSynced(idOf(row));
    }
  }

  // The one reusable image-upload helper, replacing VisitorSyncWorker's
  // three near-duplicated blocks. Returns null (not a thrown error) on a
  // missing file or failed upload - callers proceed without blocking sync.
  Future<String?> uploadIfPresent(String? localPath, String storagePath) async {
    if (localPath == null) return null;
    final file = File(localPath);
    if (!await file.exists()) return null;
    try {
      final ref = storage.ref().child(storagePath);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
