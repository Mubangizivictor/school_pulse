import '../entities/school_setup_draft.dart';

abstract class SchoolOnboardingRepository {
  Stream<SchoolSetupDraft> watchDraft();
  Future<void> saveDraft(SchoolSetupDraft draft);
}
