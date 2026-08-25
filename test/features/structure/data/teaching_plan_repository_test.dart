import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/repositories/teaching_plan_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/teaching_plan.dart';
import 'package:school_pulse/features/structure/domain/services/structure_tenant_resolver.dart';

TeachingPlanRepositoryImpl _repo(FakeFirebaseFirestore firestore, String schoolId) =>
    TeachingPlanRepositoryImpl(
      firestore: firestore,
      tenantResolver: StructureTenantResolver(
        firestore: firestore,
        schoolIdOverride: schoolId,
      ),
    );

Future<void> _seedClass(
  FakeFirebaseFirestore firestore, {
  required String id,
  required String schoolId,
  required String levelId,
}) => firestore.collection('classes').doc(id).set({
  'schoolId': schoolId,
  'name': 'Class $id',
  'levelId': levelId,
  'isActive': true,
});

void main() {
  test('saves a plan and rejects a second plan for the same level+year', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = _repo(firestore, 'school-a');
    const plan = TeachingPlan(
      id: 'plan-1',
      schoolId: 'school-a',
      educationLevelId: 'level-1',
      academicYearId: 'year-1',
    );
    await repo.savePlan(plan);

    expect(
      () => repo.savePlan(plan.copyWith(id: 'plan-2')),
      throwsA(isA<StateError>()),
    );
  });

  test('saveSubjects rejects a duplicate subject within the same plan', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = _repo(firestore, 'school-a');
    await repo.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );

    await repo.saveSubjects([
      const TeachingPlanSubject(
        id: 's-1',
        schoolId: 'school-a',
        planId: 'plan-1',
        subjectId: 'subject-eng',
        weeklyLessons: 5,
      ),
    ]);

    await expectLater(
      repo.saveSubjects([
        const TeachingPlanSubject(
          id: 's-2',
          schoolId: 'school-a',
          planId: 'plan-1',
          subjectId: 'subject-eng',
          weeklyLessons: 4,
        ),
      ]),
      throwsA(isA<StateError>()),
    );
  });

  test('saveSubjects rejects a non-positive weekly lesson count', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = _repo(firestore, 'school-a');
    await repo.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );

    expect(
      () => repo.saveSubjects([
        const TeachingPlanSubject(
          id: 's-1',
          schoolId: 'school-a',
          planId: 'plan-1',
          subjectId: 'subject-eng',
          weeklyLessons: 0,
        ),
      ]),
      throwsA(isA<StateError>()),
    );
  });

  test('a null weeklyLessons ("not set") is accepted, never coerced to 0', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = _repo(firestore, 'school-a');
    await repo.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );

    await repo.saveSubjects([
      const TeachingPlanSubject(
        id: 's-1',
        schoolId: 'school-a',
        planId: 'plan-1',
        subjectId: 'subject-eng',
      ),
    ]);

    final subjects = await repo.watchPlanSubjects('plan-1').first;
    expect(subjects.single.weeklyLessons, isNull);
  });

  test('saving subjects bumps the plan templateVersion', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = _repo(firestore, 'school-a');
    await repo.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );

    await repo.saveSubjects([
      const TeachingPlanSubject(
        id: 's-1',
        schoolId: 'school-a',
        planId: 'plan-1',
        subjectId: 'subject-eng',
        weeklyLessons: 5,
      ),
    ]);

    final plans = await repo.watchPlans().first;
    expect(plans.single.templateVersion, 2);
  });

  test('saving plan subjects syncs structure_curriculum_assignments for classes in the level', () async {
    final firestore = FakeFirebaseFirestore();
    await _seedClass(firestore, id: 'class-1', schoolId: 'school-a', levelId: 'level-1');
    await _seedClass(firestore, id: 'class-2', schoolId: 'school-a', levelId: 'level-1');
    final repo = _repo(firestore, 'school-a');
    await repo.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );

    await repo.saveSubjects([
      const TeachingPlanSubject(
        id: 's-1',
        schoolId: 'school-a',
        planId: 'plan-1',
        subjectId: 'subject-eng',
        weeklyLessons: 5,
      ),
    ]);

    final synced = await firestore
        .collection('structure_curriculum_assignments')
        .where('schoolId', isEqualTo: 'school-a')
        .where('subjectId', isEqualTo: 'subject-eng')
        .get();
    expect(synced.docs.length, 2);
    final classIds = synced.docs.map((d) => d.data()['classId']).toSet();
    expect(classIds, {'class-1', 'class-2'});
    expect(synced.docs.first.data()['periodsPerWeek'], 5);
  });

  test('plans and subjects are isolated per school', () async {
    final firestore = FakeFirebaseFirestore();
    final repoA = _repo(firestore, 'school-a');
    final repoB = _repo(firestore, 'school-b');

    await repoA.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );

    final plansForB = await repoB.watchPlans().first;
    expect(plansForB, isEmpty);
  });

  test('removeSubject deactivates the subject row and its curriculum-assignment sync rows', () async {
    final firestore = FakeFirebaseFirestore();
    await _seedClass(firestore, id: 'class-1', schoolId: 'school-a', levelId: 'level-1');
    final repo = _repo(firestore, 'school-a');
    await repo.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );
    await repo.saveSubjects([
      const TeachingPlanSubject(
        id: 's-1',
        schoolId: 'school-a',
        planId: 'plan-1',
        subjectId: 'subject-eng',
        weeklyLessons: 5,
      ),
    ]);

    await repo.removeSubject('plan-1', 'subject-eng');

    final subjects = await repo.watchPlanSubjects('plan-1').first;
    expect(subjects, isEmpty);
  });

  test('class overrides: reset restores full inheritance from the level plan', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = _repo(firestore, 'school-a');
    await repo.savePlan(
      const TeachingPlan(
        id: 'plan-1',
        schoolId: 'school-a',
        educationLevelId: 'level-1',
        academicYearId: 'year-1',
      ),
    );
    await repo.saveClassOverride(
      const ClassPlanOverride(
        id: 'override-1',
        schoolId: 'school-a',
        planId: 'plan-1',
        classId: 'class-1',
        subjectId: 'subject-eng',
        action: ClassPlanOverrideAction.modify,
        weeklyLessons: 8,
      ),
    );

    var overrides = await repo.watchClassOverrides('plan-1').first;
    expect(overrides, hasLength(1));

    await repo.resetClassToInherited('plan-1', 'class-1');

    overrides = await repo.watchClassOverrides('plan-1').first;
    expect(overrides, isEmpty);
  });
}
