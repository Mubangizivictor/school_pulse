import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/structure_setup_preferences.dart';
import '../../domain/repositories/structure_setup_repository.dart';

class StructureSetupRepositoryImpl implements StructureSetupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth? auth;
  final String? schoolIdOverride;

  StructureSetupRepositoryImpl({
    required this.firestore,
    this.auth,
    this.schoolIdOverride,
  });

  Future<String> _resolveSchoolId() async {
    final override = schoolIdOverride?.trim() ?? '';
    if (override.isNotEmpty) return override;

    final uid = (auth ?? FirebaseAuth.instance).currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError(
        'An authenticated user is required to load Structure setup.',
      );
    }
    final userDoc = await firestore.collection('users').doc(uid).get();
    final schoolId = userDoc.data()?['schoolId']?.toString().trim() ?? '';
    if (schoolId.isEmpty) {
      throw StateError('The authenticated user is not linked to a school.');
    }
    return schoolId;
  }

  @override
  Stream<StructureSetupPreferences> watchPreferences() async* {
    final schoolId = await _resolveSchoolId();
    final doc = firestore
        .collection('structure_setup_preferences')
        .doc(schoolId);

    // Create the tenant-owned singleton before subscribing. Firestore cannot
    // authorize a resource.data-based read for a document that does not yet
    // exist, while create is safely authorized from request.resource.data.
    // Merge keeps every existing answer untouched on subsequent openings.
    await doc.set(
      {
        'schoolId': schoolId,
        'setupVersion': StructureSetupPreferences.currentSetupVersion,
      },
      SetOptions(merge: true),
    );

    yield* doc.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return const StructureSetupPreferences();
      return StructureSetupPreferences(
        departments: StructureUseChoiceX.fromWire(data['departments']),
        streams: StructureUseChoiceX.fromWire(data['streams']),
        rooms: StructureUseChoiceX.fromWire(data['rooms']),
        houses: StructureUseChoiceX.fromWire(data['houses']),
        clubs: StructureUseChoiceX.fromWire(data['clubs']),
        boarding: StructureUseChoiceX.fromWire(data['boarding']),
        transport: StructureUseChoiceX.fromWire(data['transport']),
        onboardingCompleted: data['onboardingCompleted'] == true,
        setupVersion: (data['setupVersion'] as num?)?.toInt() ??
            StructureSetupPreferences.currentSetupVersion,
        lastStepId: data['lastStepId']?.toString() ?? '',
      );
    });
  }

  @override
  Future<void> savePreferences(StructureSetupPreferences preferences) async {
    final schoolId = await _resolveSchoolId();
    final doc = firestore
        .collection('structure_setup_preferences')
        .doc(schoolId);
    await doc.set(
      {
        'schoolId': schoolId,
        'departments': preferences.departments.wireName,
        'streams': preferences.streams.wireName,
        'rooms': preferences.rooms.wireName,
        'houses': preferences.houses.wireName,
        'clubs': preferences.clubs.wireName,
        'boarding': preferences.boarding.wireName,
        'transport': preferences.transport.wireName,
        'onboardingCompleted': preferences.onboardingCompleted,
        'setupVersion': preferences.setupVersion,
        'lastStepId': preferences.lastStepId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
