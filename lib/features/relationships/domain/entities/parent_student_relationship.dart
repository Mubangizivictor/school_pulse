import 'package:equatable/equatable.dart';
import 'relationship_enums.dart';

/// Institution-scoped record of one parent/guardian's access to one
/// student. Replaces the bare `studentIds: List<String>` array that used
/// to be the only link (duplicated independently on both
/// `parent_access_codes.studentIds` and `users/{uid}.studentIds`, with no
/// per-relationship metadata) with a real, lockable, auditable record.
///
/// `userId` is nullable because a relationship can exist before the parent
/// has activated a portal account - it's created at admission time off a
/// ParentAccessCode, and backfilled once the parent signs in.
class ParentStudentRelationship extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String? userId;
  final String? parentCode;
  final RelationshipType type;
  final bool isLegalGuardian;
  final bool isPrimaryGuardian;

  // Access flags. Not consumed by any module yet - cheap, forward-compatible
  // schema stubs future Finance/Academic/Health modules can start reading
  // without another migration, mirroring how staff_role_assignments'
  // permissionScope already carries fields no current caller reads.
  final bool financialAccess;
  final bool academicAccess;
  final bool attendanceAccess;
  final bool medicalAccess;
  final bool emergencyContactAccess;
  final bool pickupAuthorized;
  final bool communicationPermission;

  final RelationshipStatus status;
  final String createdBy;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime? supersededAt;
  final String? supersededBy;
  final String? supersessionReason;

  /// Links to the doc this one replaced, if it was created via
  /// reallocation rather than as a fresh link.
  final String? previousRelationshipId;

  const ParentStudentRelationship({
    required this.id,
    required this.schoolId,
    required this.studentId,
    this.userId,
    this.parentCode,
    required this.type,
    this.isLegalGuardian = false,
    this.isPrimaryGuardian = false,
    this.financialAccess = false,
    this.academicAccess = true,
    this.attendanceAccess = true,
    this.medicalAccess = false,
    this.emergencyContactAccess = true,
    this.pickupAuthorized = false,
    this.communicationPermission = true,
    this.status = RelationshipStatus.active,
    required this.createdBy,
    this.approvedBy,
    required this.createdAt,
    this.supersededAt,
    this.supersededBy,
    this.supersessionReason,
    this.previousRelationshipId,
  });

  bool get isActive => status == RelationshipStatus.active;

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    userId,
    parentCode,
    type,
    isLegalGuardian,
    isPrimaryGuardian,
    financialAccess,
    academicAccess,
    attendanceAccess,
    medicalAccess,
    emergencyContactAccess,
    pickupAuthorized,
    communicationPermission,
    status,
    createdBy,
    approvedBy,
    createdAt,
    supersededAt,
    supersededBy,
    supersessionReason,
    previousRelationshipId,
  ];
}
