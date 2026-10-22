import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';

void main() {
  test('saveDepartmentWithSubjects writes the department and reassigns subjects atomically', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('subjects').doc('eng').set({
      'schoolId': 'school-a',
      'name': 'English',
      'departmentId': '',
    });
    await firestore.collection('subjects').doc('mat').set({
      'schoolId': 'school-a',
      'name': 'Mathematics',
      'departmentId': 'old-dept',
    });
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore);

    const department = Department(id: 'dept-1', schoolId: 'school-a', name: 'Languages');
    await dataSource.saveDepartmentWithSubjects(
      department,
      const [Subject(id: 'eng', schoolId: 'school-a', name: 'English')],
      const [],
    );

    final deptDoc = await firestore.collection('departments').doc('dept-1').get();
    expect(deptDoc.exists, isTrue);
    expect(deptDoc.data()?['name'], 'Languages');

    final engDoc = await firestore.collection('subjects').doc('eng').get();
    expect(engDoc.data()?['departmentId'], 'dept-1');

    final matDoc = await firestore.collection('subjects').doc('mat').get();
    expect(matDoc.data()?['departmentId'], 'old-dept', reason: 'not touched by this save');
  });

  test('saveDepartmentWithSubjects removes departmentId from subjects taken out of the group', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('subjects').doc('lit').set({
      'schoolId': 'school-a',
      'name': 'Literature',
      'departmentId': 'dept-1',
    });
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore);

    const department = Department(id: 'dept-1', schoolId: 'school-a', name: 'Languages');
    await dataSource.saveDepartmentWithSubjects(
      department,
      const [],
      const [Subject(id: 'lit', schoolId: 'school-a', name: 'Literature')],
    );

    final litDoc = await firestore.collection('subjects').doc('lit').get();
    expect(litDoc.data()?['departmentId'], '');
  });

  test('reads are isolated per school (watchDepartments does not leak across tenants)', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('departments').doc('dept-a').set({
      'schoolId': 'school-a',
      'name': 'Languages',
      'isActive': true,
    });
    await firestore.collection('departments').doc('dept-b').set({
      'schoolId': 'school-b',
      'name': 'Sciences',
      'isActive': true,
    });
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore);

    final departmentsForA = await dataSource.watchDepartments('school-a').first;

    expect(departmentsForA, hasLength(1));
    expect(departmentsForA.single.name, 'Languages');
  });
}
