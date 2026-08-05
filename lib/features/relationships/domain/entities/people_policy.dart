import 'package:equatable/equatable.dart';

/// Institution-configurable guardian-linking policy. Default matches the
/// codebase's existing unwritten assumption (two standard parent portal
/// links per student) but an admin may configure a different lawful policy
/// per institution - nothing enforces "2" as a hard rule.
class PeoplePolicy extends Equatable {
  final String schoolId;
  final int maxStandardGuardians;
  final bool allowAdditionalEmergencyContacts;
  final bool sponsorsGetFinanceAccess;
  final DateTime? updatedAt;
  final String? updatedBy;

  const PeoplePolicy({
    required this.schoolId,
    this.maxStandardGuardians = 2,
    this.allowAdditionalEmergencyContacts = true,
    this.sponsorsGetFinanceAccess = false,
    this.updatedAt,
    this.updatedBy,
  });

  factory PeoplePolicy.defaultFor(String schoolId) =>
      PeoplePolicy(schoolId: schoolId);

  @override
  List<Object?> get props => [
    schoolId,
    maxStandardGuardians,
    allowAdditionalEmergencyContacts,
    sponsorsGetFinanceAccess,
    updatedAt,
    updatedBy,
  ];
}
