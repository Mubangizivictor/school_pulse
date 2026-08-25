import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockFirebaseAuth auth;

  setUp(() {
    auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('admin-a');
  });

  test('updateFeatureToggles writes to schools/{schoolId}/settings/features', () async {
    final firestore = FakeFirebaseFirestore();
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore, auth: auth);

    await dataSource.updateFeatureToggles(
      const FeatureToggles.allOff().copyWith(transport: true),
      'school-a',
    );

    final doc = await firestore
        .collection('schools')
        .doc('school-a')
        .collection('settings')
        .doc('features')
        .get();
    expect(doc.exists, isTrue);
    expect(doc.data()?['transport'], isTrue);
    expect(doc.data()?['library'], isFalse);
    expect(doc.data()?['updatedBy'], 'admin-a');
  });

  test('feature choices are isolated per school', () async {
    final firestore = FakeFirebaseFirestore();
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore, auth: auth);

    await dataSource.updateFeatureToggles(
      const FeatureToggles.allOff().copyWith(transport: true),
      'school-a',
    );

    final schoolBDoc = await firestore
        .collection('schools')
        .doc('school-b')
        .collection('settings')
        .doc('features')
        .get();
    expect(
      schoolBDoc.exists,
      isFalse,
      reason: 'school-b must not see school-a\'s saved choices',
    );
  });

  test('watchFeatureToggles reflects a saved document immediately', () async {
    final firestore = FakeFirebaseFirestore();
    final dataSource = StructureRemoteDataSourceImpl(firestore: firestore, auth: auth);

    await dataSource.updateFeatureToggles(
      const FeatureToggles.allOff().copyWith(payroll: true, alumni: true),
      'school-a',
    );

    final toggles = await dataSource.watchFeatureToggles('school-a').first;
    expect(toggles.payroll, isTrue);
    expect(toggles.alumni, isTrue);
    expect(toggles.transport, isFalse);
  });
}
