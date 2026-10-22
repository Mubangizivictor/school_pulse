/// Deterministic offline-duplicate-detection id: one boarder can only have
/// one attendance record per (school, dormitory, session type, day) - the
/// same identity Firestore should enforce, mirroring
/// `attendance_hub`'s `buildAttendanceRecordId` pattern.
///
/// Deliberately kept in its own file with zero Isar dependency: it used to
/// live in `boarding_attendance_isar.dart` alongside the `@collection`
/// class, and Patron/Matron's remote data sources imported it with a
/// `show` clause thinking that limited what got compiled - it doesn't.
/// `show`/`hide` only filter visible identifiers, not what the compiler
/// has to parse, so importing anything from that file (even just this
/// function) dragged the whole Isar-generated `.g.dart` part - including
/// its 64-bit schema-id literals that dart2js cannot represent - into any
/// web build that transitively reached Patron/Matron. This file has no
/// such dependency, so it compiles for web without issue.
String buildBoardingAttendanceRecordId({
  required String schoolId,
  required String dormitoryId,
  required String type,
  required DateTime date,
  required String studentId,
}) {
  final day =
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  return '$schoolId|$dormitoryId|$type|$day|$studentId';
}
