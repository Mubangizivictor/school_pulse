import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';

export 'package:school_pulse/core/user_roles.dart' show UserRole;

class UserEntity extends Equatable {
  final String id; // Internal System ID (UUID)
  final String? staffCode; // Human-Friendly Code (e.g., SMAC749201)
  final String name;
  final String email;
  final String? phoneNumber;
  final List<UserRole> roles;
  final String? photoUrl;
  final List<String> studentIds; // For Parents
  final String? studentId; // For Student users
  final String? assignedClass; // For Class Teachers
  final List<SubjectAssignment>? subjects; // For Subject Teachers
  final String schoolId;
  final String? schoolName;
  final bool isActive;
  final DateTime? lastActiveAt;
  final String? deactivationReason;
  final bool mustChangePassword;
  final bool mfaEnabled;

  // Staff profile fields, all optional so parent/student UserEntity
  // construction is unaffected. IDs reference the Structure module
  // (Department/StaffDesignation/Campus) rather than free text.
  final String? departmentId;
  final String? designationId;
  final String? campusId;
  final String? employmentType;
  final DateTime? dateJoined;
  final String? address;
  final StaffEmergencyContact? emergencyContact;
  final String? nationality;
  final String? alternatePhone;
  final List<StaffDocumentRef> documents;

  const UserEntity({
    required this.id,
    this.staffCode,
    required this.name,
    required this.email,
    required this.schoolId,
    this.schoolName,
    this.phoneNumber,
    required this.roles,
    this.photoUrl,
    this.studentIds = const [],
    this.studentId,
    this.assignedClass,
    this.subjects,
    this.isActive = true,
    this.lastActiveAt,
    this.deactivationReason,
    this.mustChangePassword = false,
    this.mfaEnabled = false,
    this.departmentId,
    this.designationId,
    this.campusId,
    this.employmentType,
    this.dateJoined,
    this.address,
    this.emergencyContact,
    this.nationality,
    this.alternatePhone,
    this.documents = const [],
  });

  UserRole get role =>
      roles.first; // Temporary helper for backward compatibility

  UserEntity copyWith({
    String? staffCode,
    String? name,
    String? email,
    String? phoneNumber,
    List<UserRole>? roles,
    String? photoUrl,
    List<String>? studentIds,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    bool? isActive,
    DateTime? lastActiveAt,
    String? deactivationReason,
    bool? mustChangePassword,
    bool? mfaEnabled,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
    String? address,
    StaffEmergencyContact? emergencyContact,
    String? nationality,
    String? alternatePhone,
    List<StaffDocumentRef>? documents,
  }) {
    return UserEntity(
      id: id,
      staffCode: staffCode ?? this.staffCode,
      name: name ?? this.name,
      email: email ?? this.email,
      schoolId: schoolId,
      schoolName: schoolName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roles: roles ?? this.roles,
      photoUrl: photoUrl ?? this.photoUrl,
      studentIds: studentIds ?? this.studentIds,
      studentId: studentId,
      assignedClass: assignedClass ?? this.assignedClass,
      subjects: subjects ?? this.subjects,
      isActive: isActive ?? this.isActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      deactivationReason: deactivationReason ?? this.deactivationReason,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      departmentId: departmentId ?? this.departmentId,
      designationId: designationId ?? this.designationId,
      campusId: campusId ?? this.campusId,
      employmentType: employmentType ?? this.employmentType,
      dateJoined: dateJoined ?? this.dateJoined,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      nationality: nationality ?? this.nationality,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      documents: documents ?? this.documents,
    );
  }

  @override
  List<Object?> get props => [
    id,
    staffCode,
    name,
    email,
    schoolId,
    schoolName,
    phoneNumber,
    roles,
    photoUrl,
    studentIds,
    studentId,
    assignedClass,
    subjects,
    mustChangePassword,
    isActive,
    lastActiveAt,
    deactivationReason,
    mfaEnabled,
    departmentId,
    designationId,
    campusId,
    employmentType,
    dateJoined,
    address,
    emergencyContact,
    nationality,
    alternatePhone,
    documents,
  ];
}

/// A reference to a staff document already uploaded to Storage, stored on
/// the user doc so it can be listed/viewed without a separate Storage list
/// call. storagePath matches the layout StaffDocumentsUploader writes to:
/// schools/$schoolId/staff/$uid/documents/...
class StaffDocumentRef extends Equatable {
  final String type;
  final String fileName;
  final String storagePath;
  final DateTime? uploadedAt;

  const StaffDocumentRef({
    required this.type,
    required this.fileName,
    required this.storagePath,
    this.uploadedAt,
  });

  @override
  List<Object?> get props => [type, fileName, storagePath, uploadedAt];

  Map<String, dynamic> toJson() => {
    'type': type,
    'fileName': fileName,
    'storagePath': storagePath,
    'uploadedAt': uploadedAt?.toIso8601String(),
  };

  factory StaffDocumentRef.fromJson(Map<String, dynamic> json) =>
      StaffDocumentRef(
        type: json['type'] ?? '',
        fileName: json['fileName'] ?? '',
        storagePath: json['storagePath'] ?? '',
        uploadedAt: json['uploadedAt'] is String
            ? DateTime.tryParse(json['uploadedAt'] as String)
            : null,
      );
}

class StaffEmergencyContact extends Equatable {
  final String name;
  final String relationship;
  final String phoneNumber;

  const StaffEmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, relationship, phoneNumber];

  Map<String, dynamic> toJson() => {
    'name': name,
    'relationship': relationship,
    'phoneNumber': phoneNumber,
  };

  factory StaffEmergencyContact.fromJson(Map<String, dynamic> json) =>
      StaffEmergencyContact(
        name: json['name'] ?? '',
        relationship: json['relationship'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
      );
}

class SubjectAssignment extends Equatable {
  final String subjectName;
  final String className;

  const SubjectAssignment({required this.subjectName, required this.className});

  @override
  List<Object?> get props => [subjectName, className];

  Map<String, dynamic> toJson() => {
    'subjectName': subjectName,
    'className': className,
  };

  factory SubjectAssignment.fromJson(Map<String, dynamic> json) =>
      SubjectAssignment(
        subjectName: json['subjectName'] ?? '',
        className: json['className'] ?? '',
      );
}
