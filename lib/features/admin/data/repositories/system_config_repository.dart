import 'dart:async';
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

  Future<
    ({
      DocumentReference<Map<String, dynamic>> system,
      DocumentReference<Map<String, dynamic>> profile,
    })
  >
  _configDocs() async {
    final schoolId = await _requireSchoolId();
    final config = _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('config');
    return (
      system: config.doc('system'),
      profile: config.doc('institution_profile'),
    );
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
    final docs = await _configDocs();
    final snapshots = await Future.wait([
      docs.system.get(),
      docs.profile.get(),
    ]);
    return _configFromMaps(snapshots[0].data(), snapshots[1].data());
  }

  Future<void> updateConfig(SystemConfig config) async {
    final docs = await _configDocs();
    final existing = await docs.system.get();
    if (existing.exists) {
      final old = SystemConfig.fromMap(existing.data()!);
      if (old.currentTerm != config.currentTerm ||
          old.academicYear != config.academicYear) {
        await docs.system.collection('history').add({
          ...old.toMap(),
          'archivedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    final batch = _firestore.batch();
    // Institution identity is canonical in institution_profile. The System
    // Configuration screen intentionally remains available, but writes its
    // overlapping identity fields there rather than maintaining a second
    // competing source of truth.
    batch.set(docs.system, _operationalConfigMap(config));
    batch.set(
      docs.profile,
      _institutionProfileMap(config),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Stream<SystemConfig> watchConfig() async* {
    final docs = await _configDocs();
    final controller = StreamController<SystemConfig>();
    Map<String, dynamic>? system;
    Map<String, dynamic>? profile;

    void publish() {
      if (system != null && profile != null && !controller.isClosed) {
        controller.add(_configFromMaps(system, profile));
      }
    }

    final systemSubscription = docs.system.snapshots().listen((snapshot) {
      system = snapshot.data() ?? const <String, dynamic>{};
      publish();
    }, onError: controller.addError);
    final profileSubscription = docs.profile.snapshots().listen((snapshot) {
      profile = snapshot.data() ?? const <String, dynamic>{};
      publish();
    }, onError: controller.addError);

    try {
      yield* controller.stream;
    } finally {
      await systemSubscription.cancel();
      await profileSubscription.cancel();
      await controller.close();
    }
  }

  Stream<List<Map<String, dynamic>>> watchPastSessions() async* {
    final docs = await _configDocs();
    yield* docs.system
        .collection('history')
        .orderBy('archivedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  SystemConfig _configFromMaps(
    Map<String, dynamic>? system,
    Map<String, dynamic>? profile,
  ) {
    final data = <String, dynamic>{..._defaultConfig().toMap(), ...?system};
    final identity = profile ?? const <String, dynamic>{};
    String? nonEmpty(Object? value) {
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    }

    void overlay(String target, String source) {
      final value = nonEmpty(identity[source]);
      if (value != null) data[target] = value;
    }

    overlay('schoolName', 'name');
    overlay('schoolCode', 'shortName');
    overlay('schoolMotto', 'motto');
    overlay('schoolLogoUrl', 'logoUrl');
    overlay('schoolAddress', 'address');
    overlay('schoolEmail', 'email');
    overlay('schoolPhone', 'phone');
    final colors = List<String>.from(identity['colors'] ?? const <String>[]);
    if (colors.isNotEmpty) data['primaryColor'] = colors.first;
    if (colors.length > 1) data['secondaryColor'] = colors[1];
    return SystemConfig.fromMap(data);
  }

  Map<String, dynamic> _operationalConfigMap(SystemConfig config) {
    final data = config.toMap();
    data.removeWhere(
      (key, _) => <String>{
        'schoolName',
        'schoolCode',
        'schoolMotto',
        'schoolLogoUrl',
        'schoolAddress',
        'schoolEmail',
        'schoolPhone',
        'primaryColor',
        'secondaryColor',
      }.contains(key),
    );
    return data;
  }

  Map<String, dynamic> _institutionProfileMap(SystemConfig config) => {
    'name': config.schoolName.trim(),
    'shortName': config.schoolCode?.trim() ?? '',
    'motto': config.schoolMotto.trim(),
    'logoUrl': config.schoolLogoUrl?.trim() ?? '',
    'address': config.schoolAddress?.trim() ?? '',
    'email': config.schoolEmail?.trim() ?? '',
    'phone': config.schoolPhone?.trim() ?? '',
    'colors': [
      if (config.primaryColor?.trim().isNotEmpty ?? false) config.primaryColor,
      if (config.secondaryColor?.trim().isNotEmpty ?? false)
        config.secondaryColor,
    ],
  };

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
