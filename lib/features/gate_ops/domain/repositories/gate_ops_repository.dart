import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/emergency_event.dart';
import '../entities/gate.dart';
import '../entities/movement_event.dart';
import '../entities/pickup_authorization.dart';
import '../entities/security_incident.dart';
import '../entities/visitor.dart';

/// Aggregate counts for the gate_ops dashboard (gatekeeper home screen and
/// the non-gatekeeper minimal dashboard stub).
class GateOpsDashboardStats extends Equatable {
  final int peopleCurrentlyInside;
  final int visitorsInside;
  final int studentsInside;
  final int staffInside;

  const GateOpsDashboardStats({
    required this.peopleCurrentlyInside,
    required this.visitorsInside,
    required this.studentsInside,
    required this.staffInside,
  });

  @override
  List<Object?> get props => [
    peopleCurrentlyInside,
    visitorsInside,
    studentsInside,
    staffInside,
  ];
}

abstract class GateOpsRepository {
  // Gates
  Stream<List<Gate>> watchGates(String schoolId);

  // Movement events (unified student/staff/visitor/pickup)
  Future<Either<Failure, void>> recordMovementEvent(MovementEvent event);
  Stream<List<MovementEvent>> watchMovementEvents(
    String schoolId, {
    PersonType? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  });

  // Visitors
  Future<Either<Failure, void>> checkInVisitor(Visitor visitor);
  Future<Either<Failure, void>> checkOutVisitor(String visitorId);
  Stream<List<Visitor>> watchVisitors(String schoolId);
  Future<List<Visitor>> getVisitorsOnce(String schoolId);

  // Incidents
  Future<Either<Failure, void>> reportIncident(SecurityIncident incident);

  // Emergency
  Future<Either<Failure, void>> triggerEmergency(EmergencyEvent emergency);
  Future<Either<Failure, void>> resolveEmergency(String emergencyId);
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId);

  // Dashboard
  Future<Either<Failure, GateOpsDashboardStats>> getGateOpsDashboardStats(
    String schoolId,
  );

  // Pickup authorizations (unchanged shape, no Isar cache in Phase 1)
  Future<Either<Failure, List<PickupAuthorization>>> getPickupAuthorizations(
    String schoolId,
    String studentId,
  );
  Future<Either<Failure, void>> addPickupAuthorization(
    PickupAuthorization authorization,
  );
}
