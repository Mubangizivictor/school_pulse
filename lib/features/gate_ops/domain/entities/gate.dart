import 'package:equatable/equatable.dart';

/// Relocated unchanged from the deleted `security/domain/entities/
/// security_entities.dart`'s `Gate` class as part of the gate_ops rebuild.
class Gate extends Equatable {
  final String id;
  final String name;
  final String type; // Main, Student, Staff, Boarding, etc.
  final String location;
  final List<String> assignedOfficerIds;
  final Map<String, dynamic> operatingHours;
  final List<String> allowedUserRoles;
  final List<String> requiredVerificationMethods;
  final String schoolId;
  // CCTV integration readiness only (not implemented) - a future camera
  // feed can be associated with this gate without another schema change.
  final String? cameraId;

  const Gate({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.assignedOfficerIds,
    required this.operatingHours,
    required this.allowedUserRoles,
    required this.requiredVerificationMethods,
    required this.schoolId,
    this.cameraId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    location,
    assignedOfficerIds,
    operatingHours,
    allowedUserRoles,
    requiredVerificationMethods,
    schoolId,
    cameraId,
  ];
}
