import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/parent_student_relationship.dart';
import '../../domain/entities/relationship_enums.dart';

class ParentStudentRelationshipModel extends ParentStudentRelationship {
  const ParentStudentRelationshipModel({
    required super.id,
    required super.schoolId,
    required super.studentId,
    super.userId,
    super.parentCode,
    required super.type,
    super.isLegalGuardian,
    super.isPrimaryGuardian,
    super.financialAccess,
    super.academicAccess,
    super.attendanceAccess,
    super.medicalAccess,
    super.emergencyContactAccess,
    super.pickupAuthorized,
    super.communicationPermission,
    super.status,
    required super.createdBy,
    super.approvedBy,
    required super.createdAt,
    super.supersededAt,
    super.supersededBy,
    super.supersessionReason,
    super.previousRelationshipId,
  });

  factory ParentStudentRelationshipModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ParentStudentRelationshipModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      studentId: map['studentId'] ?? '',
      userId: map['userId'],
      parentCode: map['parentCode'],
      type: RelationshipType.values.firstWhere(
        (v) => v.name == (map['type'] ?? '').toString(),
        orElse: () => RelationshipType.parent,
      ),
      isLegalGuardian: map['isLegalGuardian'] ?? false,
      isPrimaryGuardian: map['isPrimaryGuardian'] ?? false,
      financialAccess: map['financialAccess'] ?? false,
      academicAccess: map['academicAccess'] ?? true,
      attendanceAccess: map['attendanceAccess'] ?? true,
      medicalAccess: map['medicalAccess'] ?? false,
      emergencyContactAccess: map['emergencyContactAccess'] ?? true,
      pickupAuthorized: map['pickupAuthorized'] ?? false,
      communicationPermission: map['communicationPermission'] ?? true,
      status: RelationshipStatus.values.firstWhere(
        (v) => v.name == (map['status'] ?? '').toString(),
        orElse: () => RelationshipStatus.active,
      ),
      createdBy: map['createdBy'] ?? '',
      approvedBy: map['approvedBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      supersededAt: (map['supersededAt'] as Timestamp?)?.toDate(),
      supersededBy: map['supersededBy'],
      supersessionReason: map['supersessionReason'],
      previousRelationshipId: map['previousRelationshipId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'studentId': studentId,
      'userId': userId,
      'parentCode': parentCode,
      'type': type.name,
      'isLegalGuardian': isLegalGuardian,
      'isPrimaryGuardian': isPrimaryGuardian,
      'financialAccess': financialAccess,
      'academicAccess': academicAccess,
      'attendanceAccess': attendanceAccess,
      'medicalAccess': medicalAccess,
      'emergencyContactAccess': emergencyContactAccess,
      'pickupAuthorized': pickupAuthorized,
      'communicationPermission': communicationPermission,
      'status': status.name,
      'createdBy': createdBy,
      'approvedBy': approvedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'supersededAt': supersededAt != null
          ? Timestamp.fromDate(supersededAt!)
          : null,
      'supersededBy': supersededBy,
      'supersessionReason': supersessionReason,
      'previousRelationshipId': previousRelationshipId,
    };
  }
}
