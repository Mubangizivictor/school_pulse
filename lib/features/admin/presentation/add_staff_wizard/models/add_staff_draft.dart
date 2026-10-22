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

/// How a staff member will be able to sign in. Administrators never create,
/// see, or transmit a password for either path.
enum StaffSignInMethod {
  /// A verified, time-limited Firebase Auth invitation is sent to the
  /// staff member's work email; they set their own password to accept it.
  invite,

  /// Only the staff profile is created; there is no way to sign in until an
  /// authorised administrator later issues an invitation.
  noLogin,
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
  String preferredName = '';
  String gender = 'Prefer not to say';
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
  String? departmentId;
  String? designationId;
  String? campusId;
  DateTime dateJoined = DateTime.now();

  // Compensation choice on the Work details step. Defaults to false ("Set up
  // later") - creating a staff profile must never require pay setup. True
  // only means the admin (restricted to HR/Finance) opted into the secure
  // compensation workflow; no salary/bank/tax fields are ever collected here.
  bool compensationSetUpNow = false;

  // chargeIds of a matched pay structure's optional (non-required)
  // components the admin opted into for this staff member, e.g.
  // responsibility allowance. Required components are always paid and are
  // never part of this set. Populated by the HR/Finance compensation
  // workflow, not by this wizard's Work details step.
  Set<String> selectedPayComponentIds = {};

  // Step 6: Roles & responsibilities
  Set<UserRole> selectedRoles = {};
  Map<UserRole, RoleAssignmentDraft> roleConfigs = {};
  // Responsibility catalogue ids selected in the redesigned Step 3. Kept
  // separate from selectedRoles: responsibilities describe what the person
  // does day to day, while selectedRoles/roleConfigs still drive system
  // access/permissions (set in the Account access step). A responsibility
  // whose catalogue entry has a mappedRole keeps selectedRoles in sync so
  // existing scope-configuration (e.g. Class Teacher) keeps working.
  Set<String> selectedResponsibilityIds = {};

  // Step 4: Account access. Administrators never create, see, or store a
  // staff member's password - 'invite' issues a verified, time-limited
  // Firebase Auth invitation immediately; 'noLogin' creates only the staff
  // profile, with no Auth sign-in ability until an administrator later
  // issues an invitation.
  StaffSignInMethod signInMethod = StaffSignInMethod.invite;

  // Only meaningful once signInMethod is invite and the account has been
  // created; masked recipient email shown as read-only unless changed via
  // an authorized "Change email" action. Defaults to [email].
  String? invitationEmailOverride;

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
      employmentType.trim().isNotEmpty &&
      (campusId?.trim().isNotEmpty ?? false) &&
      (departmentId?.trim().isNotEmpty ?? false) &&
      (designationId?.trim().isNotEmpty ?? false);

  bool get rolesSelected =>
      selectedRoles.isNotEmpty || selectedResponsibilityIds.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'preferredName': preferredName,
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
    'departmentId': departmentId,
    'designationId': designationId,
    'campusId': campusId,
    'dateJoined': dateJoined.toIso8601String(),
    'compensationSetUpNow': compensationSetUpNow,
    'selectedPayComponentIds': selectedPayComponentIds.toList(),
    'selectedRoles': selectedRoles.map((r) => r.name).toList(),
    'roleConfigs': roleConfigs.map((k, v) => MapEntry(k.name, v.toJson())),
    'selectedResponsibilityIds': selectedResponsibilityIds.toList(),
    'signInMethod': signInMethod.name,
    'invitationEmailOverride': invitationEmailOverride,
  };

  static AddStaffDraft fromJson(Map<String, dynamic> json) {
    final draft = AddStaffDraft()
      ..firstName = json['firstName'] as String? ?? ''
      ..middleName = json['middleName'] as String? ?? ''
      ..lastName = json['lastName'] as String? ?? ''
      ..preferredName = json['preferredName'] as String? ?? ''
      ..gender = json['gender'] as String? ?? 'Prefer not to say'
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
      ..departmentId = json['departmentId'] as String?
      ..designationId = json['designationId'] as String?
      ..campusId = json['campusId'] as String?
      ..dateJoined = json['dateJoined'] != null
          ? DateTime.tryParse(json['dateJoined'] as String) ?? DateTime.now()
          : DateTime.now()
      ..compensationSetUpNow = json['compensationSetUpNow'] as bool? ?? false
      ..signInMethod =
          StaffSignInMethod.values
              .where((m) => m.name == json['signInMethod'])
              .firstOrNull ??
          StaffSignInMethod.invite
      ..invitationEmailOverride = json['invitationEmailOverride'] as String?
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

    draft.selectedResponsibilityIds =
        (json['selectedResponsibilityIds'] as List<dynamic>?)
            ?.cast<String>()
            .toSet() ??
        {};

    return draft;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
