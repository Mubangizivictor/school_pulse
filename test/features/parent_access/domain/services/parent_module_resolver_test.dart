import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/parent_access/domain/entities/parent_module_visibility.dart';
import 'package:school_pulse/features/parent_access/domain/services/parent_module_resolver.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/people_policy.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';

void main() {
  const resolver = ParentModuleResolver();
  const schoolId = 'school-1';
  const studentId = 'student-1';
  final policy = PeoplePolicy.defaultFor(schoolId);

  ParentStudentRelationship buildRelationship({
    RelationshipType type = RelationshipType.parent,
    RelationshipStatus status = RelationshipStatus.active,
    bool financialAccess = false,
    bool academicAccess = true,
    bool attendanceAccess = true,
    bool medicalAccess = false,
    bool communicationPermission = true,
  }) {
    return ParentStudentRelationship(
      id: 'rel-1',
      schoolId: schoolId,
      studentId: studentId,
      type: type,
      status: status,
      financialAccess: financialAccess,
      academicAccess: academicAccess,
      attendanceAccess: attendanceAccess,
      medicalAccess: medicalAccess,
      communicationPermission: communicationPermission,
      createdBy: 'staff-1',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('full-access guardian sees every enabled module', () {
    final visibility = resolver.resolve(
      relationship: buildRelationship(
        type: RelationshipType.guardian,
        financialAccess: true,
        medicalAccess: true,
      ),
      policy: policy,
      featureToggles: const FeatureToggles(),
    );

    expect(visibility.academics, isTrue);
    expect(visibility.fees, isTrue);
    expect(visibility.health, isTrue);
    expect(visibility.attendance, isTrue);
    expect(visibility.messages, isTrue);
    // Always-on self-service surfaces.
    expect(visibility.profile, isTrue);
    expect(visibility.notifications, isTrue);
  });

  test(
    'finance-only sponsor sees fees but not academics/attendance/health',
    () {
      final visibility = resolver.resolve(
        relationship: buildRelationship(
          type: RelationshipType.sponsor,
          academicAccess: false,
          attendanceAccess: false,
          medicalAccess: false,
        ),
        policy: policy.copyWithSponsorFinanceAccess(true),
        featureToggles: const FeatureToggles(),
      );

      expect(visibility.fees, isTrue);
      expect(visibility.academics, isFalse);
      expect(visibility.attendance, isFalse);
      expect(visibility.health, isFalse);
      expect(visibility.reportCard, isFalse);
      expect(visibility.library, isFalse);
      expect(visibility.boarding, isFalse);
      expect(visibility.discipline, isFalse);
    },
  );

  test(
    'sponsor without policy grant and without own financialAccess sees no fees',
    () {
      final visibility = resolver.resolve(
        relationship: buildRelationship(
          type: RelationshipType.sponsor,
          financialAccess: false,
        ),
        policy: policy, // sponsorsGetFinanceAccess defaults to false
        featureToggles: const FeatureToggles(),
      );

      expect(visibility.fees, isFalse);
    },
  );

  test('suspended relationship resolves to no student-scoped access', () {
    final visibility = resolver.resolve(
      relationship: buildRelationship(status: RelationshipStatus.superseded),
      policy: policy,
      featureToggles: const FeatureToggles(),
    );

    expect(visibility, ParentModuleVisibility.none);
    expect(visibility.profile, isTrue); // self-service stays available
  });

  test(
    'institution feature toggle off hides module regardless of access flags',
    () {
      final visibility = resolver.resolve(
        relationship: buildRelationship(medicalAccess: true),
        policy: policy,
        featureToggles: const FeatureToggles(medical: false),
      );

      expect(visibility.health, isFalse);
    },
  );

  test('parentPortal toggle off denies everything', () {
    final visibility = resolver.resolve(
      relationship: buildRelationship(
        financialAccess: true,
        medicalAccess: true,
      ),
      policy: policy,
      featureToggles: const FeatureToggles(parentPortal: false),
    );

    expect(visibility, ParentModuleVisibility.none);
  });

  test('communicationPermission false hides messages and appointments', () {
    final visibility = resolver.resolve(
      relationship: buildRelationship(communicationPermission: false),
      policy: policy,
      featureToggles: const FeatureToggles(),
    );

    expect(visibility.messages, isFalse);
    expect(visibility.appointments, isFalse);
  });
}

extension _PeoplePolicyTestExtension on PeoplePolicy {
  PeoplePolicy copyWithSponsorFinanceAccess(bool value) => PeoplePolicy(
    schoolId: schoolId,
    maxStandardGuardians: maxStandardGuardians,
    allowAdditionalEmergencyContacts: allowAdditionalEmergencyContacts,
    sponsorsGetFinanceAccess: value,
    updatedAt: updatedAt,
    updatedBy: updatedBy,
  );
}
