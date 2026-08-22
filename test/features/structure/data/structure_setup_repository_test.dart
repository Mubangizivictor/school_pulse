import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/repositories/structure_setup_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_setup_preferences.dart';

void main() {
  test('first watch creates school-owned preference singleton', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = StructureSetupRepositoryImpl(
      firestore: firestore,
      schoolIdOverride: 'school-a',
    );

    final preferences = await repository.watchPreferences().first;
    final document = await firestore
        .collection('structure_setup_preferences')
        .doc('school-a')
        .get();

    expect(document.exists, isTrue);
    expect(document.data()?['schoolId'], 'school-a');
    expect(preferences.departments, StructureUseChoice.undecided);
  });

  test(
    'opening Structure does not overwrite an existing setup version',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore
          .collection('structure_setup_preferences')
          .doc('school-a')
          .set({
            'schoolId': 'school-a',
            'setupVersion': 1,
            'departments': 'enabled',
          });
      final repository = StructureSetupRepositoryImpl(
        firestore: firestore,
        schoolIdOverride: 'school-a',
      );

      final preferences = await repository.watchPreferences().first;
      final document = await firestore
          .collection('structure_setup_preferences')
          .doc('school-a')
          .get();

      expect(document.data()?['setupVersion'], 1);
      expect(preferences.setupVersion, 1);
      expect(preferences.departments, StructureUseChoice.enabled);
    },
  );
}
