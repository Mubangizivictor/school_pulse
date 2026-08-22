import 'package:isar/isar.dart';

part 'enrollment_setup_draft_isar.g.dart';

/// Local-only resume-in-progress record for the Enrollment Setup Wizard.
///
/// This is a device-local cache, not a security boundary: Firestore rules
/// remain the real tenant-isolation enforcement for every write the wizard
/// performs. This record only prevents an operator from losing in-progress
/// selections (class/stream override, finance/bursary/boarding/club/parent/
/// identity drafts) if the app is closed, backgrounded, or crashes mid-
/// wizard. It is intentionally keyed by studentId+schoolId, not by auth
/// uid, so the SAME draft is resumable across a logout/login cycle by any
/// operator with wizard access to that student - matching how every other
/// "resume where I left off" cache in this codebase (e.g.
/// [ClassAttendanceDraftIsar]) is scoped by business key, not by session.
///
/// [stateJson] holds the full collected-but-not-yet-committed wizard
/// selections as a single JSON blob rather than one Isar column per field -
/// same "draft blob" precedent as `ClassAttendanceDraftIsar.entriesJson`.
@collection
class EnrollmentSetupDraftIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String studentId;

  @Index()
  late String schoolId;

  String? applicationId;
  late int currentStep;

  /// Bitmask of completed (successfully saved) step indices, 0..7.
  late int completedStepsMask;

  late String stateJson;
  late DateTime updatedAt;

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
