import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/system_config.dart';
import 'package:school_pulse/features/student/domain/entities/student_portal_config.dart';

import 'package:school_pulse/firebase_options.dart';

class SystemConfigRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Explicitly initialize with the bucket from options to avoid mismatch on hot-restart
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
  );

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
    final doc = await _firestore.collection('config').doc('system').get();
    if (doc.exists) {
      return SystemConfig.fromMap(doc.data()!);
    }
    return _defaultConfig();
  }

  Future<void> updateConfig(SystemConfig config) async {
    final existing = await _firestore.collection('config').doc('system').get();
    if (existing.exists) {
      final old = SystemConfig.fromMap(existing.data()!);
      if (old.currentTerm != config.currentTerm ||
          old.academicYear != config.academicYear) {
        await _firestore
            .collection('config')
            .doc('system')
            .collection('history')
            .add({...old.toMap(), 'archivedAt': FieldValue.serverTimestamp()});
      }
    }
    await _firestore.collection('config').doc('system').set(config.toMap());
  }

  Stream<SystemConfig> watchConfig() {
    return _firestore
        .collection('config')
        .doc('system')
        .snapshots()
        .map(
          (doc) => doc.data() == null
              ? _defaultConfig()
              : SystemConfig.fromMap(doc.data()!),
        );
  }

  Stream<List<Map<String, dynamic>>> watchPastSessions() {
    return _firestore
        .collection('config')
        .doc('system')
        .collection('history')
        .orderBy('archivedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<String> uploadLogo(File file) async {
    try {
      debugPrint('Starting logo upload. File path: ${file.path}');
      if (!await file.exists()) {
        throw 'Local file not found';
      }

      final fileName =
          'school_badge_${DateTime.now().millisecondsSinceEpoch}.png';
      // Explicitly using the default bucket from options
      final ref = _storage.ref().child('school_assets').child(fileName);
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
