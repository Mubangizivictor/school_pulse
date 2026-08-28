import 'dart:io';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/role_assignment_draft.dart';

enum StaffDocumentType {
  nationalId,
  academicCertificates,
  appointmentLetter,
  contract,
  other,
}

extension StaffDocumentTypeDisplay on StaffDocumentType {
  String get label => switch (this) {
    StaffDocumentType.nationalId => 'National ID / Passport',
    StaffDocumentType.academicCertificates => 'Academic Certificates',
    StaffDocumentType.appointmentLetter => 'Appointment Letter',
    StaffDocumentType.contract => 'Contract',
    StaffDocumentType.other => 'Other Documents',
  };
}

/// A document staged in-memory during the wizard. The staff account doesn't
/// exist yet at Step 10 (Documents), so files are only actually uploaded to
/// Storage after Step 11's Confirm succeeds and a uid is known.
class StagedDocument {
  final StaffDocumentType type;
  final File file;
  final String fileName;

  StagedDocument({
    required this.type,
    required this.file,
    required this.fileName,
  });
}

/// Accumulates every field gathered across the Add Staff wizard's steps.
/// One instance lives for the lifetime of the wizard, held by
/// AddStaffWizardController, and is what gets serialized for draft
/// persistence between app sessions.
class AddStaffDraft {
  // Step 3: Personal Information
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String gender = 'Male';
  File? photo;

  // Step 4: Contact Information
  String email = '';
  String phoneNumber = '';
  String alternatePhone = '';
  String address = '';
  String nationality = '';
  String emergencyContactName = '';
  String emergencyContactRelationship = '';
  String emergencyContactPhone = '';
  String emergencyContactAlternatePhone = '';
  String? idempotencyKey;

  // Step 5: Employment Information
  String employmentType = 'Permanent';
  // department/designation hold the Structure entity's display name (for
  // the Review step and for the Firestore write); departmentId/designationId
  // hold the Structure entity id the name was picked from. Both are set
  // together by the Step 4 picker - never edited as free text.
  String department = '';
  String? departmentId;
  String designation = '';
  String? designationId;
  String? campusId;
  DateTime dateJoined = DateTime.now();

  // Pay Structure step (inserted right after Employment Information, since
  // the matched salary structure is keyed on designationId set there).
  // chargeIds of the matched structure's optional (non-required) pay
  // components the admin opted into for this staff member, e.g.
  // responsibility allowance. Required components are always paid and are
  // never part of this set.
  Set<String> selectedPayComponentIds = {};

  // Step 6: Roles
  Set<UserRole> selectedRoles = {};
  Map<UserRole, RoleAssignmentDraft> roleConfigs = {};

  // Step 9: Login & Security
  bool forcePasswordChange = true;
  bool sendLoginDetailsViaEmail = true;

  // Admin-set initial password. Deliberately NOT serialized to the saved-draft
  // JSON so a plaintext password never lands in local storage - the admin
  // re-enters it if a draft is restored.
  String initialPassword = '';

  // Step 10: Documents (staged only; uploaded post-creation)
  List<StagedDocument> documents = [];

  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((s) => s.trim().isNotEmpty).join(' ');

  bool get personalInfoComplete =>
      firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;

  bool get contactInfoComplete =>
      email.trim().isNotEmpty && phoneNumber.trim().isNotEmpty;

  bool get employmentInfoComplete =>
      (departmentId?.trim().isNotEmpty ?? false) &&
      (designationId?.trim().isNotEmpty ?? false);

  bool get rolesSelected => selectedRoles.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'gender': gender,
    'email': email,
    'phoneNumber': phoneNumber,
    'alternatePhone': alternatePhone,
    'address': address,
    'nationality': nationality,
    'emergencyContactName': emergencyContactName,
    'emergencyContactRelationship': emergencyContactRelationship,
    'emergencyContactPhone': emergencyContactPhone,
    'emergencyContactAlternatePhone': emergencyContactAlternatePhone,
    'idempotencyKey': idempotencyKey,
    'employmentType': employmentType,
    'department': department,
    'departmentId': departmentId,
    'designation': designation,
    'designationId': designationId,
    'campusId': campusId,
    'dateJoined': dateJoined.toIso8601String(),
    'selectedPayComponentIds': selectedPayComponentIds.toList(),
    'selectedRoles': selectedRoles.map((r) => r.name).toList(),
    'roleConfigs': roleConfigs.map((k, v) => MapEntry(k.name, v.toJson())),
    'forcePasswordChange': forcePasswordChange,
    'sendLoginDetailsViaEmail': sendLoginDetailsViaEmail,
  };

  static AddStaffDraft fromJson(Map<String, dynamic> json) {
    final draft = AddStaffDraft()
      ..firstName = json['firstName'] as String? ?? ''
      ..middleName = json['middleName'] as String? ?? ''
      ..lastName = json['lastName'] as String? ?? ''
      ..gender = json['gender'] as String? ?? 'Male'
      ..email = json['email'] as String? ?? ''
      ..phoneNumber = json['phoneNumber'] as String? ?? ''
      ..alternatePhone = json['alternatePhone'] as String? ?? ''
      ..address = json['address'] as String? ?? ''
      ..nationality = json['nationality'] as String? ?? ''
      ..emergencyContactName = json['emergencyContactName'] as String? ?? ''
      ..emergencyContactRelationship =
          json['emergencyContactRelationship'] as String? ?? ''
      ..emergencyContactPhone = json['emergencyContactPhone'] as String? ?? ''
      ..emergencyContactAlternatePhone =
          json['emergencyContactAlternatePhone'] as String? ?? ''
      ..idempotencyKey = json['idempotencyKey'] as String?
      ..employmentType = json['employmentType'] as String? ?? 'Permanent'
      ..department = json['department'] as String? ?? ''
      ..departmentId = json['departmentId'] as String?
      ..designation = json['designation'] as String? ?? ''
      ..designationId = json['designationId'] as String?
      ..campusId = json['campusId'] as String?
      ..dateJoined = json['dateJoined'] != null
          ? DateTime.tryParse(json['dateJoined'] as String) ?? DateTime.now()
          : DateTime.now()
      ..forcePasswordChange = json['forcePasswordChange'] as bool? ?? true
      ..sendLoginDetailsViaEmail =
          json['sendLoginDetailsViaEmail'] as bool? ?? true
      ..selectedPayComponentIds =
          (json['selectedPayComponentIds'] as List<dynamic>?)
              ?.cast<String>()
              .toSet() ??
          {};

    final roleNames =
        (json['selectedRoles'] as List<dynamic>?)?.cast<String>() ?? [];
    draft.selectedRoles = roleNames
        .map((n) => UserRole.values.where((r) => r.name == n).firstOrNull)
        .whereType<UserRole>()
        .toSet();

    final configsJson = json['roleConfigs'] as Map<String, dynamic>? ?? {};
    draft.roleConfigs = configsJson.map(
      (k, v) => MapEntry(
        UserRole.values.firstWhere((r) => r.name == k),
        RoleAssignmentDraft.fromJson(v as Map<String, dynamic>),
      ),
    );

    return draft;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
