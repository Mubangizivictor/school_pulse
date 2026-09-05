import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/education_level_selection.dart';
import '../../domain/entities/school_setup_draft.dart';
import '../../domain/repositories/school_onboarding_repository.dart';

class SchoolOnboardingRepositoryImpl implements SchoolOnboardingRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth? auth;
  final String? schoolIdOverride;

  SchoolOnboardingRepositoryImpl({
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
        'An authenticated user is required to load School setup.',
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
  Stream<SchoolSetupDraft> watchDraft() async* {
    final schoolId = await _resolveSchoolId();
    final doc = firestore.collection('school_onboarding_drafts').doc(schoolId);

    // Create the tenant-owned singleton before subscribing - Firestore
    // cannot authorize a resource.data-based read for a document that does
    // not yet exist, while create is safely authorized from
    // request.resource.data. Only schoolId is merged so an existing draft is
    // never overwritten just by opening the wizard.
    await doc.set({'schoolId': schoolId}, SetOptions(merge: true));

    yield* doc.snapshots().map((snapshot) => _fromMap(snapshot.data()));
  }

  @override
  Future<void> saveDraft(SchoolSetupDraft draft) async {
    final schoolId = await _resolveSchoolId();
    final doc = firestore.collection('school_onboarding_drafts').doc(schoolId);
    await doc.set({
      'schoolId': schoolId,
      ..._toMap(draft),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  SchoolSetupDraft _fromMap(Map<String, dynamic>? data) {
    if (data == null) return const SchoolSetupDraft();
    final levels = (data['selectedLevels'] as List<dynamic>? ?? [])
        .map((raw) => _levelFromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
    return SchoolSetupDraft(
      selectedLevels: levels,
      templateId: data['templateId']?.toString() ?? '',
      isCustomSelection: data['isCustomSelection'] == true,
      schoolTypeHint: data['schoolTypeHint']?.toString() ?? '',
      provisionedLevelIds: List<String>.from(
        (data['provisionedLevelIds'] as List<dynamic>? ?? []).map(
          (e) => e.toString(),
        ),
      ),
      stepData: Map<String, dynamic>.from(
        data['stepData'] as Map<dynamic, dynamic>? ?? {},
      ),
      lastStepId: data['lastStepId']?.toString() ?? '',
      onboardingCompleted: data['onboardingCompleted'] == true,
      setupVersion:
          (data['setupVersion'] as num?)?.toInt() ??
          SchoolSetupDraft.currentSetupVersion,
    );
  }

  Map<String, dynamic> _toMap(SchoolSetupDraft draft) => {
    'selectedLevels': draft.selectedLevels.map(_levelToMap).toList(),
    'templateId': draft.templateId,
    'isCustomSelection': draft.isCustomSelection,
    'schoolTypeHint': draft.schoolTypeHint,
    'provisionedLevelIds': draft.provisionedLevelIds,
    'stepData': draft.stepData,
    'lastStepId': draft.lastStepId,
    'onboardingCompleted': draft.onboardingCompleted,
    'setupVersion': draft.setupVersion,
  };

  Map<String, dynamic> _levelToMap(SelectableLevel level) => {
    'id': level.id,
    'category': level.category.name,
    'name': level.name,
    'code': level.code,
    'order': level.order,
    'stages': level.stages,
    'isCustom': level.isCustom,
    'internationalProgrammeName': level.internationalProgrammeName,
  };

  SelectableLevel _levelFromMap(Map<String, dynamic> data) => SelectableLevel(
    id: data['id']?.toString() ?? '',
    category: LevelCategory.values.firstWhere(
      (c) => c.name == data['category']?.toString(),
      orElse: () => LevelCategory.custom,
    ),
    name: data['name']?.toString() ?? '',
    code: data['code']?.toString() ?? '',
    order: (data['order'] as num?)?.toInt() ?? 0,
    stages: List<String>.from(
      (data['stages'] as List<dynamic>? ?? []).map((e) => e.toString()),
    ),
    isCustom: data['isCustom'] == true,
    internationalProgrammeName: data['internationalProgrammeName']
        ?.toString(),
  );
}
