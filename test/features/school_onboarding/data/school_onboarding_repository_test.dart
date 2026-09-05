import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/school_onboarding/data/repositories/school_onboarding_repository_impl.dart';
import 'package:school_pulse/features/school_onboarding/domain/entities/education_level_selection.dart';
import 'package:school_pulse/features/school_onboarding/domain/entities/school_setup_draft.dart';

void main() {
  test('first watch creates school-owned draft singleton', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = SchoolOnboardingRepositoryImpl(
      firestore: firestore,
      schoolIdOverride: 'school-a',
    );

    final draft = await repository.watchDraft().first;
    final document = await firestore
        .collection('school_onboarding_drafts')
        .doc('school-a')
        .get();

    expect(document.exists, isTrue);
    expect(document.data()?['schoolId'], 'school-a');
    expect(draft.selectedLevels, isEmpty);
    expect(draft.templateId, '');
  });

  test('opening onboarding does not overwrite an existing draft', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('school_onboarding_drafts').doc('school-a').set(
      {'schoolId': 'school-a', 'templateId': 'combined', 'setupVersion': 1},
    );
    final repository = SchoolOnboardingRepositoryImpl(
      firestore: firestore,
      schoolIdOverride: 'school-a',
    );

    final draft = await repository.watchDraft().first;

    expect(draft.templateId, 'combined');
    expect(draft.setupVersion, 1);
  });

  test('selected levels round-trip through save and watch', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = SchoolOnboardingRepositoryImpl(
      firestore: firestore,
      schoolIdOverride: 'school-a',
    );

    const levels = [
      SelectableLevel(
        id: 'ug-primary',
        category: LevelCategory.primary,
        name: 'Primary',
        code: 'PRI',
        order: 0,
        stages: ['P1', 'P2'],
      ),
      SelectableLevel(
        id: 'custom-1',
        category: LevelCategory.international,
        name: 'Cambridge Lower',
        code: 'CAM',
        order: 1,
        isCustom: true,
        internationalProgrammeName: 'Cambridge International',
      ),
    ];

    await repository.saveDraft(
      const SchoolSetupDraft(
        selectedLevels: levels,
        templateId: 'combined',
        isCustomSelection: true,
      ),
    );
    final draft = await repository.watchDraft().first;

    expect(draft.selectedLevels.length, 2);
    expect(draft.selectedLevels[0].name, 'Primary');
    expect(draft.selectedLevels[0].stages, ['P1', 'P2']);
    expect(draft.selectedLevels[1].internationalProgrammeName,
        'Cambridge International');
    expect(draft.isCustomSelection, isTrue);
  });

  test('drafts are isolated per school', () async {
    final firestore = FakeFirebaseFirestore();
    final repositoryA = SchoolOnboardingRepositoryImpl(
      firestore: firestore,
      schoolIdOverride: 'school-a',
    );
    final repositoryB = SchoolOnboardingRepositoryImpl(
      firestore: firestore,
      schoolIdOverride: 'school-b',
    );

    await repositoryA.saveDraft(
      const SchoolSetupDraft(templateId: 'primary'),
    );
    final draftA = await repositoryA.watchDraft().first;
    final draftB = await repositoryB.watchDraft().first;

    expect(draftA.templateId, 'primary');
    expect(draftB.templateId, '');
  });
}
