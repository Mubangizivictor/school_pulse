import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/admin/data/models/system_config.dart';
import 'package:school_pulse/features/admin/data/repositories/system_config_repository.dart';
import 'package:school_pulse/features/student/domain/entities/student_portal_config.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockFirebaseAuth auth;
  late SystemConfigRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('admin-a');
    await firestore.collection('users').doc('admin-a').set({
      'schoolId': 'school-a',
    });
    repository = SystemConfigRepository(
      firestore: firestore,
      auth: auth,
      storage: _MockFirebaseStorage(),
    );
  });

  test(
    'persists configuration only in the authenticated school namespace',
    () async {
      final config = SystemConfig(
        schoolName: 'School A',
        schoolMotto: 'Learn',
        currentTerm: 'Term 2',
        academicYear: '2026',
        termStart: DateTime(2026, 5, 1),
        termEnd: DateTime(2026, 8, 1),
        mfaEnabled: false,
        smsGatewayStatus: 'Disconnected',
        smsCredits: 0,
        studentPortalConfig: StudentPortalConfig(),
      );

      await repository.updateConfig(config);

      expect(
        (await firestore
                .collection('schools')
                .doc('school-a')
                .collection('config')
                .doc('institution_profile')
                .get())
            .data()?['name'],
        'School A',
      );
      expect(
        (await firestore
                .collection('schools')
                .doc('school-a')
                .collection('config')
                .doc('system')
                .get())
            .data()
            ?.containsKey('schoolName'),
        false,
      );
      expect(
        (await firestore.collection('config').doc('system').get()).exists,
        false,
      );
    },
  );

  test('archives term changes within the same school only', () async {
    final initial = await repository.getConfig();
    await repository.updateConfig(initial.copyWith(currentTerm: 'Term 2'));
    await repository.updateConfig(initial.copyWith(currentTerm: 'Term 3'));

    final history = await firestore
        .collection('schools')
        .doc('school-a')
        .collection('config')
        .doc('system')
        .collection('history')
        .get();
    expect(history.docs, hasLength(1));
  });

  test(
    'reads institution identity from the canonical profile document',
    () async {
      await firestore
          .collection('schools')
          .doc('school-a')
          .collection('config')
          .doc('system')
          .set({
            'schoolName': 'Stale name',
            'schoolMotto': 'Stale motto',
            'currentTerm': 'Term 1',
            'academicYear': '2026',
            'termStart': DateTime(2026, 1, 1).toIso8601String(),
            'termEnd': DateTime(2026, 4, 1).toIso8601String(),
          });
      await firestore
          .collection('schools')
          .doc('school-a')
          .collection('config')
          .doc('institution_profile')
          .set({
            'name': 'Canonical Academy',
            'motto': 'One source of truth',
            'logoUrl': 'https://example.test/logo.png',
            'colors': ['4278190335', '4294901760'],
          });

      final config = await repository.getConfig();

      expect(config.schoolName, 'Canonical Academy');
      expect(config.schoolMotto, 'One source of truth');
      expect(config.schoolLogoUrl, 'https://example.test/logo.png');
      expect(config.primaryColor, '4278190335');
      expect(config.secondaryColor, '4294901760');
    },
  );
}
