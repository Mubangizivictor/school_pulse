import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/structure_setup_preferences.dart';
import '../../domain/repositories/structure_setup_repository.dart';

class StructureSetupRepositoryImpl implements StructureSetupRepository {
  final FirebaseFirestore firestore;

  StructureSetupRepositoryImpl({required this.firestore});

  DocumentReference<Map<String, dynamic>> get _doc =>
      firestore.collection('structure_config').doc('setup_preferences');

  @override
  Stream<StructureSetupPreferences> watchPreferences() {
    return _doc.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return const StructureSetupPreferences();
      return StructureSetupPreferences(
        departments: StructureUseChoiceX.fromWire(data['departments']),
        streams: StructureUseChoiceX.fromWire(data['streams']),
        rooms: StructureUseChoiceX.fromWire(data['rooms']),
        houses: StructureUseChoiceX.fromWire(data['houses']),
        clubs: StructureUseChoiceX.fromWire(data['clubs']),
        onboardingCompleted: data['onboardingCompleted'] == true,
        setupVersion: (data['setupVersion'] as num?)?.toInt() ??
            StructureSetupPreferences.currentSetupVersion,
        lastStepId: data['lastStepId']?.toString() ?? '',
      );
    });
  }

  @override
  Future<void> savePreferences(StructureSetupPreferences preferences) {
    return _doc.set(
      {
        'departments': preferences.departments.wireName,
        'streams': preferences.streams.wireName,
        'rooms': preferences.rooms.wireName,
        'houses': preferences.houses.wireName,
        'clubs': preferences.clubs.wireName,
        'onboardingCompleted': preferences.onboardingCompleted,
        'setupVersion': preferences.setupVersion,
        'lastStepId': preferences.lastStepId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
