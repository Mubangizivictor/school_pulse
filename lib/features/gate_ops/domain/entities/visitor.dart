import 'package:equatable/equatable.dart';
import 'movement_event.dart' show SyncStatus;

enum VisitorStatus { checkedIn, checkedOut }

/// Lightweight visitor identity/pass entity. Visitor-only fields (purpose,
/// host, pass state) stay off [MovementEvent] because a visitor's stay is a
/// stateful record (checked-in -> checked-out, looked up and mutated in
/// place) rather than an instantaneous event; the visitor screens write here
/// directly and additionally emit one `MovementEvent` per direction change
/// to keep dashboard/audit queries uniform across all person types.
class Visitor extends Equatable {
  final String id;
  final String schoolId;
  final String fullName;
  final String? phone;
  final String? photoLocalPath;
  final String? photoUrl;
  final String purpose; // fixed purpose-icon-grid value
  final String? hostId;
  final String? hostName;
  final String gateId;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final VisitorStatus status;
  final bool isQuickEntry; // "Basic entry / Details pending" flag for a later phase to complete
  final String? badgeNumber; // reserved, nullable - badge printing is a later phase
  final SyncStatus syncStatus;

  const Visitor({
    required this.id,
    required this.schoolId,
    required this.fullName,
    this.phone,
    this.photoLocalPath,
    this.photoUrl,
    required this.purpose,
    this.hostId,
    this.hostName,
    required this.gateId,
    required this.arrivalTime,
    this.departureTime,
    required this.status,
    required this.isQuickEntry,
    this.badgeNumber,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    fullName,
    phone,
    photoLocalPath,
    photoUrl,
    purpose,
    hostId,
    hostName,
    gateId,
    arrivalTime,
    departureTime,
    status,
    isQuickEntry,
    badgeNumber,
    syncStatus,
  ];
}
