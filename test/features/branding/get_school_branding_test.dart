import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/branding/domain/usecases/get_school_branding.dart';

void main() {
  group('GetSchoolBranding', () {
    test(
      'uses the editable institution profile as the canonical branding source',
      () async {
        final firestore = FakeFirebaseFirestore();
        await firestore.collection('schools').doc('school-a').set({
          'name': 'Legacy Academy',
          'schoolType': 'secondary',
          'branding': {
            'motto': 'Legacy motto',
            'logoUrl': 'https://legacy.example/logo.png',
            'primaryColor': '#111111',
          },
        });
        await firestore
            .collection('schools')
            .doc('school-a')
            .collection('config')
            .doc('institution_profile')
            .set({
              'name': 'School Pulse Academy',
              'shortName': 'SPA',
              'motto': 'Learning without limits',
              'schoolType': 'international',
              'logoUrl': 'https://profile.example/logo.png',
              'badgeUrl': 'https://profile.example/badge.png',
              'colors': ['#123456', '#234567', '#345678'],
            });

        final result = await GetSchoolBranding(firestore)('school-a');
        final branding = result.getOrElse(
          () => throw StateError('Expected school branding'),
        );

        expect(branding.schoolName, 'School Pulse Academy');
        expect(branding.schoolInitials, 'SPA');
        expect(branding.schoolMotto, 'Learning without limits');
        expect(branding.schoolType, 'international');
        expect(branding.logoUrl, 'https://profile.example/logo.png');
        expect(branding.badgeUrl, 'https://profile.example/badge.png');
        expect(branding.primaryColor, '#123456');
        expect(branding.secondaryColor, '#234567');
        expect(branding.accentColor, '#345678');
      },
    );

    test(
      'falls back to legacy branding until an institution profile exists',
      () async {
        final firestore = FakeFirebaseFirestore();
        await firestore.collection('schools').doc('school-a').set({
          'name': 'Legacy Academy',
          'branding': {'motto': 'Legacy motto', 'primaryColor': '#111111'},
        });

        final result = await GetSchoolBranding(firestore)('school-a');
        final branding = result.getOrElse(
          () => throw StateError('Expected school branding'),
        );

        expect(branding.schoolName, 'Legacy Academy');
        expect(branding.schoolMotto, 'Legacy motto');
        expect(branding.primaryColor, '#111111');
      },
    );
  });
}
