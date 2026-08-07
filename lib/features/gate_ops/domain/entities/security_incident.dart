import 'package:equatable/equatable.dart';
import 'movement_event.dart' show SyncStatus;

/// Phase 1 minimal quick-incident entity for gate_ops. Deliberately smaller
/// than the deleted `security` module's `SecurityIncident` (no
/// `involvedPersonIds`/`report`/`cameraId`/`location`) — Phase 1's Quick
/// Incident screen only captures type, optional photo, optional text note.
class SecurityIncident extends Equatable {
  final String id;
  final String schoolId;
  final String gateId;
  final String type;
  final String description;
  final DateTime timestamp;
  final List<String> photoUrls;
  final String reportedByOfficerId;
  final String status; // Pending, Investigating, Resolved
  final SyncStatus syncStatus;

  const SecurityIncident({
    required this.id,
    required this.schoolId,
    required this.gateId,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.photoUrls,
    required this.reportedByOfficerId,
    required this.status,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    gateId,
    type,
    description,
    timestamp,
    photoUrls,
    reportedByOfficerId,
    status,
    syncStatus,
  ];
}
