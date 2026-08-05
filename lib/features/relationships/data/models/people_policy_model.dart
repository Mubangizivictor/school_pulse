import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/people_policy.dart';

class PeoplePolicyModel extends PeoplePolicy {
  const PeoplePolicyModel({
    required super.schoolId,
    super.maxStandardGuardians,
    super.allowAdditionalEmergencyContacts,
    super.sponsorsGetFinanceAccess,
    super.updatedAt,
    super.updatedBy,
  });

  factory PeoplePolicyModel.fromMap(String schoolId, Map<String, dynamic> map) {
    return PeoplePolicyModel(
      schoolId: schoolId,
      maxStandardGuardians: map['maxStandardGuardians'] ?? 2,
      allowAdditionalEmergencyContacts:
          map['allowAdditionalEmergencyContacts'] ?? true,
      sponsorsGetFinanceAccess: map['sponsorsGetFinanceAccess'] ?? false,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'maxStandardGuardians': maxStandardGuardians,
      'allowAdditionalEmergencyContacts': allowAdditionalEmergencyContacts,
      'sponsorsGetFinanceAccess': sponsorsGetFinanceAccess,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
    };
  }
}
