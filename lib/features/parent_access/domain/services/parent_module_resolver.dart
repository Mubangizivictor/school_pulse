import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/people_policy.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import '../entities/parent_module_visibility.dart';

/// Decides which Parent Portal modules a parent may see for one child.
///
/// Visibility is never a property of the *relationship type* alone (e.g.
/// "guardians see everything, sponsors see nothing") - two guardians can
/// carry different access flags, and a sponsor may be granted finance
/// access by [PeoplePolicy.sponsorsGetFinanceAccess]. It's the AND of three
/// independent sources:
///   1. Institution [FeatureToggles] - is the module switched on at all.
///   2. [PeoplePolicy] - does institution policy grant this relationship
///      category extra access (currently: sponsor finance access).
///   3. The specific [ParentStudentRelationship]'s access flags - what this
///      parent was actually granted for this child.
///
/// A module is visible only if all three agree. This mirrors the schema
/// comment on ParentStudentRelationship ("access flags ... cheap,
/// forward-compatible stubs future modules can start reading") - this is
/// that first reader.
class ParentModuleResolver {
  const ParentModuleResolver();

  ParentModuleVisibility resolve({
    required ParentStudentRelationship relationship,
    required PeoplePolicy policy,
    required FeatureToggles featureToggles,
  }) {
    if (!relationship.isActive) return ParentModuleVisibility.none;
    if (!featureToggles.parentPortal) return ParentModuleVisibility.none;

    final hasFinanceAccess =
        relationship.financialAccess ||
        (relationship.type == RelationshipType.sponsor &&
            policy.sponsorsGetFinanceAccess);

    final academicAccess = relationship.academicAccess;

    return ParentModuleVisibility(
      academics: academicAccess,
      reportCard: academicAccess,
      attendance: academicAccess && relationship.attendanceAccess,
      fees: hasFinanceAccess,
      health: featureToggles.medical && relationship.medicalAccess,
      transport: featureToggles.transport && academicAccess,
      library: featureToggles.library && academicAccess,
      discipline: academicAccess,
      boarding: featureToggles.boarding && academicAccess,
      messages: featureToggles.communication && relationship.communicationPermission,
      appointments: featureToggles.communication && relationship.communicationPermission,
      digitalId: featureToggles.digitalIds && academicAccess,
    );
  }
}
