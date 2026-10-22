import 'enrollment_setup_draft.dart';
import 'enrollment_setup_draft_local_data_source.dart';

EnrollmentSetupDraftLocalDataSource create({dynamic isar}) =>
    const EnrollmentSetupDraftLocalDataSourceWeb();

/// No local database on web - a wizard session cannot be resumed after the
/// tab is closed there, matching every other Isar-backed cache in this app.
class EnrollmentSetupDraftLocalDataSourceWeb
    implements EnrollmentSetupDraftLocalDataSource {
  const EnrollmentSetupDraftLocalDataSourceWeb();

  @override
  Future<EnrollmentSetupDraft?> getDraft({
    required String schoolId,
    required String studentId,
  }) async => null;

  @override
  Future<void> saveDraft({
    required String schoolId,
    required String studentId,
    String? applicationId,
    required int currentStep,
    required int completedStepsMask,
    required Map<String, dynamic> stateJson,
  }) async {}

  @override
  Future<void> deleteDraft({
    required String schoolId,
    required String studentId,
  }) async {}
}
