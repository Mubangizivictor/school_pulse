import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.staffCode,
    required super.name,
    required super.email,
    required super.schoolId,
    super.schoolName,
    super.phoneNumber,
    required super.roles,
    super.photoUrl,
    super.studentIds = const [],
    super.assignedClass,
    super.subjects,
    super.mustChangePassword = false,
    super.isActive = true,
    super.lastActiveAt,
    super.deactivationReason,
    super.mfaEnabled = false,
    super.departmentId,
    super.designationId,
    super.campusId,
    super.employmentType,
    super.dateJoined,
    super.address,
    super.emergencyContact,
    super.nationality,
    super.alternatePhone,
    super.documents,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<UserRole> roles = [];
    if (json['roles'] != null) {
      roles = (json['roles'] as List)
          .map(
            (r) => UserRole.values.firstWhere(
              (e) => e.name == r,
              orElse: () => UserRole.parent,
            ),
          )
          .toList();
    } else if (json['role'] != null) {
      // Handle legacy single role
      roles = [
        UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.parent,
        ),
      ];
    } else {
      roles = [UserRole.parent];
    }

    return UserModel(
      id: json['id'] ?? '',
      staffCode: json['staffCode'],
      // Profiles created by different onboarding versions may hold a display
      // name, split names, or the legacy `name` field. Resolve them once at
      // the data boundary so a UI never has to guess or duplicate a token.
      name: _resolvedName(json),
      email: json['email'] ?? '',
      schoolId: json['schoolId'] ?? '',
      schoolName: json['schoolName'],
      phoneNumber: json['phoneNumber'],
      roles: roles,
      photoUrl: json['photoUrl'],
      studentIds: List<String>.from(json['studentIds'] ?? const []),
      assignedClass: json['assignedClass'],
      subjects: json['subjects'] != null
          ? (json['subjects'] as List)
                .map((i) => SubjectAssignment.fromJson(i))
                .toList()
          : null,
      mustChangePassword: json['mustChangePassword'] ?? false,
      isActive: json['isActive'] ?? true,
      lastActiveAt: _parseDate(json['lastActiveAt']),
      deactivationReason: json['deactivationReason'] as String?,
      mfaEnabled: json['mfaEnabled'] ?? false,
      departmentId: json['departmentId'] as String?,
      designationId: json['designationId'] as String?,
      campusId: json['campusId'] as String?,
      employmentType: json['employmentType'] as String?,
      dateJoined: _parseDate(json['dateJoined']),
      address: json['address'] as String?,
      emergencyContact: json['emergencyContact'] != null
          ? StaffEmergencyContact.fromJson(
              json['emergencyContact'] as Map<String, dynamic>,
            )
          : null,
      nationality: json['nationality'] as String?,
      alternatePhone: json['alternatePhone'] as String?,
      documents: json['documents'] != null
          ? (json['documents'] as List)
                .map(
                  (d) => StaffDocumentRef.fromJson(
                    Map<String, dynamic>.from(d as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }

  static String _resolvedName(Map<String, dynamic> json) {
    String value(dynamic raw) => raw is String ? raw.trim() : '';
    final displayName = value(json['displayName']);
    if (displayName.isNotEmpty) return displayName;
    final firstName = value(json['firstName']);
    final lastName = value(json['lastName']);
    final split = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).toList();
    if (split.isNotEmpty) return split.join(' ');
    final legacy = value(json['name']);
    final words = legacy
        .split(RegExp(r'\\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    // A legacy mapper once produced `Dos Dos` for profiles whose only known
    // token was copied into first and last name. Preserve legitimate names,
    // but collapse adjacent accidental duplicates.
    return words.length == 2 &&
            words.first.toLowerCase() == words.last.toLowerCase()
        ? words.first
        : words.join(' ');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffCode': staffCode,
      'name': name,
      'email': email,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'phoneNumber': phoneNumber,
      // Cloud Functions (e.g. billing role checks) still read the singular
      // 'role' field, so keep it in sync with the primary (first) role.
      'role': roles.isNotEmpty ? roles.first.name : null,
      'roles': roles.map((e) => e.name).toList(),
      'photoUrl': photoUrl,
      'studentIds': studentIds,
      'assignedClass': assignedClass,
      'subjects': subjects?.map((e) => e.toJson()).toList(),
      'mustChangePassword': mustChangePassword,
      'isActive': isActive,
      'deactivationReason': deactivationReason,
      'mfaEnabled': mfaEnabled,
      'departmentId': departmentId,
      'designationId': designationId,
      'campusId': campusId,
      'employmentType': employmentType,
      'dateJoined': dateJoined != null ? Timestamp.fromDate(dateJoined!) : null,
      'address': address,
      'emergencyContact': emergencyContact?.toJson(),
      'nationality': nationality,
      'alternatePhone': alternatePhone,
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      staffCode: entity.staffCode,
      name: entity.name,
      email: entity.email,
      schoolId: entity.schoolId,
      schoolName: entity.schoolName,
      phoneNumber: entity.phoneNumber,
      roles: entity.roles,
      photoUrl: entity.photoUrl,
      studentIds: entity.studentIds,
      assignedClass: entity.assignedClass,
      subjects: entity.subjects,
      mustChangePassword: entity.mustChangePassword,
      isActive: entity.isActive,
      deactivationReason: entity.deactivationReason,
      mfaEnabled: entity.mfaEnabled,
      departmentId: entity.departmentId,
      designationId: entity.designationId,
      campusId: entity.campusId,
      employmentType: entity.employmentType,
      dateJoined: entity.dateJoined,
      address: entity.address,
      emergencyContact: entity.emergencyContact,
      nationality: entity.nationality,
      alternatePhone: entity.alternatePhone,
      documents: entity.documents,
    );
  }
}
