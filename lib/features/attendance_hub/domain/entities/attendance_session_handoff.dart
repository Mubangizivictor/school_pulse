import 'attendance_scope.dart';

/// Carries an in-progress attendance session's scope and present-count
/// across the NFC/QR method screens when a teacher switches methods
/// mid-session, so "Present: 24/40" doesn't reset to 0/0 just because the
/// screen changed. The underlying attendance records were never at risk
/// (AttendanceRepository dedupes server-side regardless), this only keeps
/// the on-screen counter honest.
class AttendanceSessionHandoff {
  final AttendanceScope scope;
  final int rosterSize;
  final Set<String> presentPersonIds;

  const AttendanceSessionHandoff({
    required this.scope,
    required this.rosterSize,
    required this.presentPersonIds,
  });
}
