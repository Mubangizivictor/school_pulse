import 'enrollment_setup_draft.dart';

/// Local (Isar, on mobile/desktop) persistence for in-progress Enrollment
/// Setup Wizard drafts.
///
/// Web has no Isar engine (see isar_bootstrap.dart's conditional import),
/// so every method here is a safe no-op / null-return on web via
/// [EnrollmentSetupDraftLocalDataSourceWeb] - the wizard still functions on
/// web, it simply cannot resume a killed session there, matching how every
/// other Isar-backed local cache in this codebase degrades on web.
///
/// Deliberately has zero Isar import itself, and returns the plain
/// [EnrollmentSetupDraft] rather than the Isar model - see that file's doc
/// comment for why.
abstract class EnrollmentSetupDraftLocalDataSource {
  Future<EnrollmentSetupDraft?> getDraft({
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
