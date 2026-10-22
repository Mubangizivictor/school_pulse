import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';

void main() {
  test('saveGradingSystemWithBands writes the system and every band atomically', () async {
    final firestore = FakeFirebaseFirestore();
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore);

    const system = GradingSystemDef(
      id: 'sys-1',
      schoolId: 'school-a',
      name: 'Primary standard',
      levelIds: ['level-1'],
      maximumMark: 100,
    );
    const bands = [
      GradeBand(id: 'b1', schoolId: 'school-a', gradingSystemId: 'sys-1', grade: 'D1', minScore: 80, maxScore: 100, order: 0),
      GradeBand(id: 'b2', schoolId: 'school-a', gradingSystemId: 'sys-1', grade: 'F9', minScore: 0, maxScore: 79, order: 1),
    ];

    await dataSource.saveGradingSystemWithBands(system, bands);

    final systemDoc = await firestore.collection('structure_grading_systems').doc('sys-1').get();
    expect(systemDoc.exists, isTrue);
    expect(systemDoc.data()?['name'], 'Primary standard');

    final bandDocs = await firestore
        .collection('grade_bands')
        .where('gradingSystemId', isEqualTo: 'sys-1')
        .get();
    expect(bandDocs.docs, hasLength(2));
  });

  test('saveGradingSystemWithBands atomically unsets the previous default for the same scope', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('structure_grading_systems').doc('old-default').set({
      'schoolId': 'school-a',
      'name': 'Old default',
      'isDefault': true,
      'appliesTo': 'levels',
      'levelIds': ['level-1'],
      'classIds': <String>[],
      'academicYearIds': <String>[],
      'maximumMark': 100,
    });
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore);

    const newSystem = GradingSystemDef(
      id: 'new-default',
      schoolId: 'school-a',
      name: 'New default',
      isDefault: true,
      appliesTo: 'levels',
      levelIds: ['level-1'],
      maximumMark: 100,
    );

    await dataSource.saveGradingSystemWithBands(newSystem, const []);

    final oldDoc = await firestore.collection('structure_grading_systems').doc('old-default').get();
    final newDoc = await firestore.collection('structure_grading_systems').doc('new-default').get();
    expect(oldDoc.data()?['isDefault'], isFalse);
    expect(newDoc.data()?['isDefault'], isTrue);
  });

  test('does not unset a default grading system belonging to a different level', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('structure_grading_systems').doc('other-level-default').set({
      'schoolId': 'school-a',
      'name': 'Secondary default',
      'isDefault': true,
      'appliesTo': 'levels',
      'levelIds': ['level-2'],
      'classIds': <String>[],
      'academicYearIds': <String>[],
      'maximumMark': 100,
    });
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore);

    const newSystem = GradingSystemDef(
      id: 'new-default',
      schoolId: 'school-a',
      name: 'Primary default',
      isDefault: true,
      appliesTo: 'levels',
      levelIds: ['level-1'],
      maximumMark: 100,
    );

    await dataSource.saveGradingSystemWithBands(newSystem, const []);

    final otherLevelDoc =
        await firestore.collection('structure_grading_systems').doc('other-level-default').get();
    expect(otherLevelDoc.data()?['isDefault'], isTrue);
  });

  test('countAssessmentsUsingGradingSystem counts only this school\'s matching assessments', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore
        .collection('schools')
        .doc('school-a')
        .collection('subject_assessments')
        .doc('a1')
        .set({'gradingSystemId': 'sys-1'});
    await firestore
        .collection('schools')
        .doc('school-a')
        .collection('subject_assessments')
        .doc('a2')
        .set({'gradingSystemId': 'sys-2'});
    await firestore
        .collection('schools')
        .doc('school-b')
        .collection('subject_assessments')
        .doc('a3')
        .set({'gradingSystemId': 'sys-1'});

    final service = StructureDependencyService(firestore: firestore);
    final count = await service.countAssessmentsUsingGradingSystem('school-a', 'sys-1');

    expect(count, 1);
  });
}
