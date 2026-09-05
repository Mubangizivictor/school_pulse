import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/school_onboarding/domain/services/levels_in_use_checker.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';

void main() {
  test('reports zero counts for a level with no classes', () async {
    final firestore = FakeFirebaseFirestore();
    final checker = LevelsInUseChecker(
      dependencyService: StructureDependencyService(firestore: firestore),
    );

    final reports = await checker.checkLevelsInUse('school-a', ['level-1']);

    expect(reports, hasLength(1));
    expect(reports.single.levelId, 'level-1');
    expect(reports.single.classCount, 0);
    expect(reports.single.studentCount, 0);
    expect(reports.single.isInUse, isFalse);
  });

  test('reports nonzero class count when classes reference the level', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('classes').add({
      'schoolId': 'school-a',
      'levelId': 'level-1',
      'name': 'P1',
    });
    final checker = LevelsInUseChecker(
      dependencyService: StructureDependencyService(firestore: firestore),
    );

    final reports = await checker.checkLevelsInUse('school-a', ['level-1']);

    expect(reports.single.classCount, 1);
    expect(reports.single.isInUse, isTrue);
  });

  test('checks multiple affected levels independently', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('classes').add({
      'schoolId': 'school-a',
      'levelId': 'level-1',
      'name': 'P1',
    });
    final checker = LevelsInUseChecker(
      dependencyService: StructureDependencyService(firestore: firestore),
    );

    final reports = await checker.checkLevelsInUse(
      'school-a',
      ['level-1', 'level-2'],
    );

    expect(reports, hasLength(2));
    expect(reports[0].isInUse, isTrue);
    expect(reports[1].isInUse, isFalse);
  });

  test('an empty affected-ids list returns no reports', () async {
    final firestore = FakeFirebaseFirestore();
    final checker = LevelsInUseChecker(
      dependencyService: StructureDependencyService(firestore: firestore),
    );

    final reports = await checker.checkLevelsInUse('school-a', const []);

    expect(reports, isEmpty);
  });
}
