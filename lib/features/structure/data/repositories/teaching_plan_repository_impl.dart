import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/teaching_plan.dart';
import '../../domain/repositories/teaching_plan_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';

class TeachingPlanRepositoryImpl implements TeachingPlanRepository {
  final FirebaseFirestore firestore;
  final StructureTenantResolver tenantResolver;

  TeachingPlanRepositoryImpl({
    required this.firestore,
    required this.tenantResolver,
  });

  CollectionReference<Map<String, dynamic>> get _plans =>
      firestore.collection('structure_teaching_plans');
  CollectionReference<Map<String, dynamic>> get _planSubjects =>
      firestore.collection('structure_teaching_plan_subjects');
  CollectionReference<Map<String, dynamic>> get _overrides =>
      firestore.collection('structure_class_plan_overrides');
  CollectionReference<Map<String, dynamic>> get _curriculumAssignments =>
      firestore.collection('structure_curriculum_assignments');
  CollectionReference<Map<String, dynamic>> get _classes =>
      firestore.collection('classes');

  @override
  Stream<List<TeachingPlan>> watchPlans() async* {
    final schoolId = await tenantResolver.resolve();
    yield* _plans
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _planFromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Stream<List<TeachingPlanSubject>> watchPlanSubjects(String planId) async* {
    final schoolId = await tenantResolver.resolve();
    yield* _planSubjects
        .where('schoolId', isEqualTo: schoolId)
        .where('planId', isEqualTo: planId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _subjectFromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Stream<List<ClassPlanOverride>> watchClassOverrides(String planId) async* {
    final schoolId = await tenantResolver.resolve();
    yield* _overrides
        .where('schoolId', isEqualTo: schoolId)
        .where('planId', isEqualTo: planId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _overrideFromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> savePlan(TeachingPlan plan) async {
    final schoolId = await tenantResolver.resolve();
    if (plan.educationLevelId.isEmpty || plan.academicYearId.isEmpty) {
      throw StateError(
        'An education level and academic year are required for a teaching plan.',
      );
    }
    final existingForLevel = await _plans
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: plan.academicYearId)
        .where('educationLevelId', isEqualTo: plan.educationLevelId)
        .where('isActive', isEqualTo: true)
        .get();
    if (existingForLevel.docs.any((doc) => doc.id != plan.id)) {
      throw StateError(
        'This education level already has a teaching plan for the selected academic year.',
      );
    }
    await _plans.doc(plan.id).set({
      'schoolId': schoolId,
      'educationLevelId': plan.educationLevelId,
      'academicYearId': plan.academicYearId,
      'templateSourceId': plan.templateSourceId,
      'templateVersion': plan.templateVersion,
      'isActive': plan.isActive,
      'createdBy': plan.createdBy,
      'createdAt': plan.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(plan.createdAt!),
      'updatedBy': plan.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveSubject(TeachingPlanSubject subject) =>
      saveSubjects([subject]);

  @override
  Future<void> saveSubjects(List<TeachingPlanSubject> subjects) async {
    if (subjects.isEmpty) return;
    final schoolId = await tenantResolver.resolve();
    final planId = subjects.first.planId;
    if (subjects.any((item) => item.planId != planId)) {
      throw ArgumentError(
        'All subjects in a bulk write must belong to one plan.',
      );
    }
    if (subjects.any((item) => item.weeklyLessons != null && item.weeklyLessons! <= 0)) {
      throw StateError('Weekly lessons must be a positive number when set.');
    }

    final planSnap = await _plans.doc(planId).get();
    final planData = planSnap.data();
    if (!snapshotBelongsToSchool(planSnap.exists, planData, schoolId)) {
      throw StateError('Teaching plan not found in the active school.');
    }

    final existing = await _planSubjects
        .where('schoolId', isEqualTo: schoolId)
        .where('planId', isEqualTo: planId)
        .where('isActive', isEqualTo: true)
        .get();
    final existingBySubject = <String, String>{
      for (final doc in existing.docs)
        (doc.data()['subjectId']?.toString() ?? ''): doc.id,
    };
    final seen = <String>{};
    for (final subject in subjects) {
      if (!seen.add(subject.subjectId)) {
        throw StateError('A subject can only appear once per teaching plan.');
      }
      final existingId = existingBySubject[subject.subjectId];
      if (existingId != null && existingId != subject.id) {
        throw StateError(
          'This subject is already in this teaching plan.',
        );
      }
    }

    final batch = firestore.batch();
    for (final subject in subjects) {
      batch.set(_planSubjects.doc(subject.id), {
        'schoolId': schoolId,
        'planId': planId,
        'subjectId': subject.subjectId,
        'isCore': subject.isCore,
        'weeklyLessons': subject.weeklyLessons,
        'order': subject.order,
        'isActive': subject.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    batch.update(_plans.doc(planId), {
      'templateVersion': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    await _syncCurriculumAssignments(
      schoolId: schoolId,
      planId: planId,
      planData: planData!,
      subjects: subjects,
    );
  }

  @override
  Future<void> removeSubject(String planId, String subjectId) async {
    final schoolId = await tenantResolver.resolve();
    final existing = await _planSubjects
        .where('schoolId', isEqualTo: schoolId)
        .where('planId', isEqualTo: planId)
        .where('subjectId', isEqualTo: subjectId)
        .where('isActive', isEqualTo: true)
        .get();
    if (existing.docs.isEmpty) return;
    final batch = firestore.batch();
    for (final doc in existing.docs) {
      batch.update(doc.reference, {
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    batch.update(_plans.doc(planId), {
      'templateVersion': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    final matching = await _curriculumAssignments
        .where('schoolId', isEqualTo: schoolId)
        .where('subjectId', isEqualTo: subjectId)
        .where('isActive', isEqualTo: true)
        .get();
    final classIdsInPlan = await _classIdsForPlan(schoolId, planId);
    final deactivate = firestore.batch();
    for (final doc in matching.docs) {
      if (classIdsInPlan.contains(doc.data()['classId'])) {
        deactivate.update(doc.reference, {
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await deactivate.commit();
  }

  @override
  Future<void> saveClassOverride(ClassPlanOverride override) async {
    final schoolId = await tenantResolver.resolve();
    if (override.classId.isEmpty || override.subjectId.isEmpty) {
      throw StateError('A class and subject are required for an override.');
    }
    if (override.weeklyLessons != null && override.weeklyLessons! <= 0) {
      throw StateError('Weekly lessons must be a positive number when set.');
    }
    await _overrides.doc(override.id).set({
      'schoolId': schoolId,
      'planId': override.planId,
      'classId': override.classId,
      'subjectId': override.subjectId,
      'action': override.action.name,
      'isCore': override.isCore,
      'weeklyLessons': override.weeklyLessons,
      'isActive': override.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteClassOverride(String overrideId) async {
    final schoolId = await tenantResolver.resolve();
    final ref = _overrides.doc(overrideId);
    final snapshot = await ref.get();
    if (!snapshotBelongsToSchool(snapshot.exists, snapshot.data(), schoolId)) {
      throw StateError('Class override not found in the active school.');
    }
    await ref.update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> resetClassToInherited(String planId, String classId) async {
    final schoolId = await tenantResolver.resolve();
    final existing = await _overrides
        .where('schoolId', isEqualTo: schoolId)
        .where('planId', isEqualTo: planId)
        .where('classId', isEqualTo: classId)
        .where('isActive', isEqualTo: true)
        .get();
    if (existing.docs.isEmpty) return;
    final batch = firestore.batch();
    for (final doc in existing.docs) {
      batch.update(doc.reference, {
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Keeps `structure_curriculum_assignments` populated with one row per
  /// (class, subject) resolved from this plan, purely so existing consumers
  /// - `TeachingAssignmentRepositoryImpl`'s Subject Teacher gate and
  /// `StructureSetupEngine`'s completeness check - keep working unchanged.
  /// Teaching plans are the source of truth; this is a write-through, never
  /// read back by this repository.
  Future<void> _syncCurriculumAssignments({
    required String schoolId,
    required String planId,
    required Map<String, dynamic> planData,
    required List<TeachingPlanSubject> subjects,
  }) async {
    final academicYearId = planData['academicYearId']?.toString() ?? '';
    final levelId = planData['educationLevelId']?.toString() ?? '';
    if (academicYearId.isEmpty || levelId.isEmpty) return;
    final classIds = await _classIdsForPlan(schoolId, planId, levelId: levelId);
    if (classIds.isEmpty) return;

    final batch = firestore.batch();
    for (final classId in classIds) {
      for (final subject in subjects) {
        final id = 'plan:$planId:$classId:${subject.subjectId}';
        batch.set(_curriculumAssignments.doc(id), {
          'schoolId': schoolId,
          'academicYearId': academicYearId,
          'levelId': levelId,
          'classId': classId,
          'streamId': '',
          'subjectId': subject.subjectId,
          'isCompulsory': subject.isCore,
          'periodsPerWeek': subject.weeklyLessons ?? 0,
          'displayOrder': subject.order,
          'isActive': subject.isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
    await batch.commit();
  }

  Future<List<String>> _classIdsForPlan(
    String schoolId,
    String planId, {
    String? levelId,
  }) async {
    var resolvedLevelId = levelId;
    if (resolvedLevelId == null) {
      final planSnap = await _plans.doc(planId).get();
      resolvedLevelId = planSnap.data()?['educationLevelId']?.toString() ?? '';
    }
    if (resolvedLevelId.isEmpty) return const [];
    final snapshot = await _classes
        .where('schoolId', isEqualTo: schoolId)
        .where('levelId', isEqualTo: resolvedLevelId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList(growable: false);
  }

  bool snapshotBelongsToSchool(
    bool exists,
    Map<String, dynamic>? data,
    String schoolId,
  ) => exists && data?['schoolId'] == schoolId;

  TeachingPlan _planFromMap(String id, Map<String, dynamic> map) =>
      TeachingPlan(
        id: id,
        schoolId: map['schoolId']?.toString() ?? '',
        educationLevelId: map['educationLevelId']?.toString() ?? '',
        academicYearId: map['academicYearId']?.toString() ?? '',
        templateSourceId: map['templateSourceId']?.toString() ?? '',
        templateVersion: (map['templateVersion'] as num?)?.toInt() ?? 1,
        isActive: map['isActive'] != false,
        createdBy: map['createdBy']?.toString() ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
        updatedBy: map['updatedBy']?.toString() ?? '',
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      );

  TeachingPlanSubject _subjectFromMap(String id, Map<String, dynamic> map) =>
      TeachingPlanSubject(
        id: id,
        schoolId: map['schoolId']?.toString() ?? '',
        planId: map['planId']?.toString() ?? '',
        subjectId: map['subjectId']?.toString() ?? '',
        isCore: map['isCore'] != false,
        weeklyLessons: (map['weeklyLessons'] as num?)?.toInt(),
        order: (map['order'] as num?)?.toInt() ?? 0,
        isActive: map['isActive'] != false,
      );

  ClassPlanOverride _overrideFromMap(String id, Map<String, dynamic> map) =>
      ClassPlanOverride(
        id: id,
        schoolId: map['schoolId']?.toString() ?? '',
        planId: map['planId']?.toString() ?? '',
        classId: map['classId']?.toString() ?? '',
        subjectId: map['subjectId']?.toString() ?? '',
        action: ClassPlanOverrideAction.values.firstWhere(
          (value) => value.name == map['action']?.toString(),
          orElse: () => ClassPlanOverrideAction.modify,
        ),
        isCore: map['isCore'] as bool?,
        weeklyLessons: (map['weeklyLessons'] as num?)?.toInt(),
        isActive: map['isActive'] != false,
      );
}
