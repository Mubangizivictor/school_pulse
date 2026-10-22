import 'dart:convert';

import 'package:isar/isar.dart';

import '../models/enrollment_setup_draft_isar.dart';
import 'enrollment_setup_draft.dart';
import 'enrollment_setup_draft_local_data_source.dart';

EnrollmentSetupDraftLocalDataSource create({required dynamic isar}) =>
    EnrollmentSetupDraftLocalDataSourceMobile(isar: isar as Isar?);

class EnrollmentSetupDraftLocalDataSourceMobile
    implements EnrollmentSetupDraftLocalDataSource {
  final Isar? isar;

  EnrollmentSetupDraftLocalDataSourceMobile({required this.isar});

  @override
  Future<EnrollmentSetupDraft?> getDraft({
    required String schoolId,
    required String studentId,
  }) async {
    final db = isar;
    if (db == null) return null;
    final row = await db.enrollmentSetupDraftIsars
        .filter()
        .studentIdEqualTo(studentId)
        .and()
        .schoolIdEqualTo(schoolId)
        .findFirst();
    if (row == null) return null;
    return EnrollmentSetupDraft(
      currentStep: row.currentStep,
      completedStepsMask: row.completedStepsMask,
      stateJson: row.stateJson,
    );
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
