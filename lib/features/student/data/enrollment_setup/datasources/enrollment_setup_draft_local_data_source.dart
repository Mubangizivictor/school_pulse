import 'dart:convert';

import 'package:isar/isar.dart';

import '../models/enrollment_setup_draft_isar.dart';

/// Local (Isar) persistence for in-progress Enrollment Setup Wizard drafts.
///
/// Web has no Isar engine (see isar_bootstrap.dart's conditional import),
/// so every method here is a safe no-op / null-return when [isar] is null -
/// the wizard still functions on web, it simply cannot resume a killed
/// session there, matching how every other Isar-backed local cache in this
/// codebase degrades on web.
abstract class EnrollmentSetupDraftLocalDataSource {
  Future<EnrollmentSetupDraftIsar?> getDraft({
    required String schoolId,
    required String studentId,
  });

  Future<void> saveDraft({
    required String schoolId,
    required String studentId,
    String? applicationId,
    required int currentStep,
    required int completedStepsMask,
    required Map<String, dynamic> stateJson,
  });

  Future<void> deleteDraft({
    required String schoolId,
    required String studentId,
  });
}

class EnrollmentSetupDraftLocalDataSourceImpl
    implements EnrollmentSetupDraftLocalDataSource {
  final Isar? isar;

  EnrollmentSetupDraftLocalDataSourceImpl({required this.isar});

  @override
  Future<EnrollmentSetupDraftIsar?> getDraft({
    required String schoolId,
    required String studentId,
  }) async {
    final db = isar;
    if (db == null) return null;
    return db.enrollmentSetupDraftIsars
        .filter()
        .studentIdEqualTo(studentId)
        .and()
        .schoolIdEqualTo(schoolId)
        .findFirst();
  }

  @override
  Future<void> saveDraft({
    required String schoolId,
    required String studentId,
    String? applicationId,
    required int currentStep,
    required int completedStepsMask,
    required Map<String, dynamic> stateJson,
  }) async {
    final db = isar;
    if (db == null) return;
    await db.writeTxn(() async {
      await db.enrollmentSetupDraftIsars.put(
        EnrollmentSetupDraftIsar()
          ..studentId = studentId
          ..schoolId = schoolId
          ..applicationId = applicationId
          ..currentStep = currentStep
          ..completedStepsMask = completedStepsMask
          ..stateJson = jsonEncode(stateJson)
          ..updatedAt = DateTime.now(),
      );
    });
  }

  @override
  Future<void> deleteDraft({
    required String schoolId,
    required String studentId,
  }) async {
    final db = isar;
    if (db == null) return;
    await db.writeTxn(() async {
      final existing = await db.enrollmentSetupDraftIsars
          .filter()
          .studentIdEqualTo(studentId)
          .and()
          .schoolIdEqualTo(schoolId)
          .findFirst();
      if (existing != null) {
        await db.enrollmentSetupDraftIsars.delete(existing.isarId);
      }
    });
  }
}
