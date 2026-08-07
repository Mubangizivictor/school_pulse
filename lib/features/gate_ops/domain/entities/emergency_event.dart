import 'package:equatable/equatable.dart';
import 'movement_event.dart' show SyncStatus;

/// Phase 1 minimal emergency entity for gate_ops. Deliberately smaller than
/// the deleted `security` module's `EmergencyEvent` (no
/// `responseActions`/`involvedPersonIds`) — Phase 1's emergency button only
/// captures type/description and fires an immediate alert.
class EmergencyEvent extends Equatable {
  final String id;
  final String schoolId;
  final String gateId;
  final String type;
  final DateTime startTime;
  final DateTime? endTime;
  final String description;
  final String officerId;
  final String deviceId;
  final String status; // Active, Resolved
  final SyncStatus syncStatus;

  const EmergencyEvent({
    required this.id,
    required this.schoolId,
    required this.gateId,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.description,
    required this.officerId,
    required this.deviceId,
    required this.status,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    gateId,
    type,
    startTime,
    endTime,
    description,
    officerId,
    deviceId,
    status,
    syncStatus,
  ];
}
