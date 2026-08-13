import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/system_config.dart';
import 'package:school_pulse/features/student/domain/entities/student_portal_config.dart';

import 'package:school_pulse/firebase_options.dart';

class SystemConfigRepository {
  SystemConfigRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage =
           storage ??
           FirebaseStorage.instanceFor(
             bucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
           ),
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  Future<String> _requireSchoolId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('An authenticated school context is required.');
    }
    final user = await _firestore.collection('users').doc(uid).get();
    final schoolId = user.data()?['schoolId']?.toString().trim();
    if (schoolId == null || schoolId.isEmpty) {
      throw StateError('Your account is not assigned to a school.');
    }
    return schoolId;
  }

  Future<DocumentReference<Map<String, dynamic>>> _configDoc() async {
    final schoolId = await _requireSchoolId();
    return _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('config')
        .doc('system');
  }

  SystemConfig _defaultConfig() {
    final now = DateTime.now();
    return SystemConfig(
      schoolName: 'School Pulse Academy',
      schoolMotto: 'Precision in Education',
      schoolLogoUrl: null,
      schoolAddress: null,
      schoolEmail: null,
      schoolPhone: null,
      primaryColor: null,
      secondaryColor: null,
      currentTerm: 'Term 1',
      academicYear: '${now.year}/${now.year + 1}',
      termStart: now,
      termEnd: now.add(const Duration(days: 90)),
      mfaEnabled: false,
      smsGatewayStatus: 'Disconnected',
      smsCredits: 0,
      studentPortalConfig: StudentPortalConfig(),
    );
  }

  /// Returns a sane default rather than null when no config document has
  /// been saved yet, so a brand-new school doesn't get stuck on a
  /// permanent "failed to load" screen with no way to create one - the
  /// default is only persisted once the admin hits Save.
  Future<SystemConfig> getConfig() async {
    final doc = await (await _configDoc()).get();
    if (doc.exists) {
      return SystemConfig.fromMap(doc.data()!);
    }
    return _defaultConfig();
  }

  Future<void> updateConfig(SystemConfig config) async {
    final configDoc = await _configDoc();
    final existing = await configDoc.get();
    if (existing.exists) {
      final old = SystemConfig.fromMap(existing.data()!);
      if (old.currentTerm != config.currentTerm ||
          old.academicYear != config.academicYear) {
        await configDoc.collection('history').add({
          ...old.toMap(),
          'archivedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await configDoc.set(config.toMap());
  }

  Stream<SystemConfig> watchConfig() async* {
    final configDoc = await _configDoc();
    yield* configDoc.snapshots().map(
      (doc) => doc.data() == null
          ? _defaultConfig()
          : SystemConfig.fromMap(doc.data()!),
    );
  }

  Stream<List<Map<String, dynamic>>> watchPastSessions() async* {
    final configDoc = await _configDoc();
    yield* configDoc
        .collection('history')
        .orderBy('archivedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<String> uploadLogo(File file) async {
    try {
      final schoolId = await _requireSchoolId();
      debugPrint('Starting logo upload. File path: ${file.path}');
      if (!await file.exists()) {
        throw 'Local file not found';
      }

      final fileName =
          'school_badge_${DateTime.now().millisecondsSinceEpoch}.png';
      // Explicitly using the default bucket from options
      final ref = _storage
          .ref()
          .child('schools')
          .child(schoolId)
          .child('school_assets')
          .child(fileName);
      debugPrint('Uploading to bucket: ${_storage.bucket}');
      debugPrint('Full path: ${ref.fullPath}');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/png'),
      );

      // Listen to progress for better debugging
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        debugPrint(
          'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes} (${snapshot.state})',
        );
      });

      final snapshot = await uploadTask;

      debugPrint('Upload snapshot final state: ${snapshot.state}');
      if (snapshot.state != TaskState.success) {
        throw 'Upload failed with state: ${snapshot.state}';
      }

      debugPrint('Getting download URL...');
      for (int i = 0; i < 6; i++) {
        try {
          final url = await snapshot.ref.getDownloadURL();
          debugPrint('Got download URL: $url');
          return url;
        } on FirebaseException catch (e) {
          debugPrint('getDownloadURL attempt $i failed: ${e.code}');
          if (e.code == 'object-not-found' && i < 5) {
            await Future.delayed(Duration(seconds: 1 << i));
            continue;
          }
          rethrow;
        }
      }
      throw 'Failed to retrieve logo URL after upload';
    } catch (e) {
      debugPrint('Total uploadLogo error: $e');
      if (e is FirebaseException) {
        throw 'Firebase Storage Error: [${e.code}] ${e.message}';
      }
      rethrow;
    }
  }
}
