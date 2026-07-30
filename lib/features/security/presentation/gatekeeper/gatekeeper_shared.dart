import 'package:school_pulse/features/security/domain/entities/security_entities.dart';

/// Suggests the next movement direction for a student based on their most
/// recent movement recorded today, per the "smart action detection" spec: a
/// student currently marked outside should be suggested ENTER, one marked
/// inside should be suggested LEAVE. Defaults to entering if nothing was
/// recorded today. The proposed action is always shown, never applied
/// automatically - the guard still taps ENTER/LEAVE to confirm.
String suggestStudentDirection(List<StudentMovement> todayMovements, String studentId) {
  final mine = todayMovements.where((m) => m.studentId == studentId).toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  if (mine.isEmpty) return 'In';
  return mine.first.direction == 'In' ? 'Out' : 'In';
}

/// Same smart-action heuristic as [suggestStudentDirection], for staff.
String suggestStaffDirection(List<StaffMovement> todayMovements, String staffId) {
  final mine = todayMovements.where((m) => m.staffId == staffId).toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  if (mine.isEmpty) return 'In';
  return mine.first.direction == 'In' ? 'Out' : 'In';
}

/// Arrival/Late Arrival on the way in, Departure/Early Departure on the way
/// out, computed from the gate's configured operating hours (falls back to a
/// plain Arrival/Departure if the gate has none set). A standalone copy of
/// VerificationWorkflow's private _computeMovementType (Reception mode) -
/// kept separate rather than sharing that State class's private logic.
String computeMovementType(Gate gate, String direction) {
  final hours = gate.operatingHours;
  final open = _parseTimeToday(hours['open'] as String?);
  final close = _parseTimeToday(hours['close'] as String?);
  final now = DateTime.now();

  if (direction == 'In') {
    if (open != null && now.isAfter(open.add(const Duration(minutes: 15)))) return 'Late Arrival';
    return 'Arrival';
  } else {
    if (close != null && now.isBefore(close)) return 'Early Departure';
    return 'Departure';
  }
}

/// Formats a visit duration as e.g. "1h 20m" or "45m", matching the format
/// VisitorScannerScreen already uses for checkout.
String formatVisitDuration(DateTime start, DateTime end) {
  final diff = end.difference(start);
  final hours = diff.inHours;
  final minutes = diff.inMinutes % 60;
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}

DateTime? _parseTimeToday(String? hhmm) {
  if (hhmm == null || !hhmm.contains(':')) return null;
  final parts = hhmm.split(':');
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}
