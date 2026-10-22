/// Plain-Dart projection of a persisted enrollment-setup draft - the
/// interface/bloc-facing shape, deliberately independent of the Isar model
/// (`EnrollmentSetupDraftIsar`) that backs it on mobile. Keeping this file
/// free of any Isar import is what lets `flutter build web` compile the
/// interface and its callers (the wizard bloc) without ever parsing the
/// Isar-generated 64-bit schema-id literals that dart2js cannot represent.
class EnrollmentSetupDraft {
  final int currentStep;
  final int completedStepsMask;
  final String stateJson;

  const EnrollmentSetupDraft({
    required this.currentStep,
    required this.completedStepsMask,
    required this.stateJson,
  });

  int get completedStepCount => _popcount(completedStepsMask);

  static int _popcount(int mask) {
    var count = 0;
    var m = mask;
    while (m != 0) {
      count += m & 1;
      m >>= 1;
    }
    return count;
  }
}
