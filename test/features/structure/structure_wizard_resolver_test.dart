import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_wizard_resolver.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

void main() {
  group('StructureWizardResolver.validateAcyclic', () {
    test('the real registry is acyclic and correctly ordered', () {
      expect(
        () => StructureWizardResolver().validateAcyclic(),
        returnsNormally,
      );
    });
  });

  group('StructureWizardResolver.resolve', () {
    const emptyState = StructureState(isLoading: false);

    test('first step is institution-info when nothing is configured', () {
      final resolved = StructureWizardResolver().resolve(emptyState);
      expect(resolved.isComplete, isFalse);
      expect(resolved.currentStep?.definition.id, 'institution-info');
      expect(resolved.currentStepNumber, 1);
    });

    test('advances to the academic year after a complete school identity', () {
      final state = emptyState.copyWith(
        institutionProfile: const InstitutionProfile(
          name: 'Test School',
          schoolType: 'secondary',
          country: 'Uganda',
          timeZone: 'Africa/Kampala',
          currency: 'UGX',
        ),
      );
      final resolved = StructureWizardResolver().resolve(state);
      expect(resolved.currentStep?.definition.id, 'academic-years');
    });

    test('wizard is complete once every wizard-scoped step is satisfied', () {
      final now = DateTime.now();
      final state = emptyState.copyWith(
        institutionProfile: const InstitutionProfile(
          name: 'Test School',
          schoolType: 'secondary',
          country: 'Uganda',
          timeZone: 'Africa/Kampala',
          currency: 'UGX',
        ),
        campuses: const [Campus(id: 'c1', schoolId: 's1', name: 'Main')],
        academicYears: [
          AcademicYear(
            id: 'y1',
            schoolId: 's1',
            name: '2026',
            startDate: now,
            endDate: now.add(const Duration(days: 300)),
            isCurrent: true,
          ),
        ],
        academicTerms: [
          AcademicTerm(
            id: 't1',
            schoolId: 's1',
            academicYearId: 'y1',
            name: 'Term 1',
            startDate: now,
            endDate: now.add(const Duration(days: 90)),
          ),
        ],
        levels: const [
          EducationalLevel(id: 'l1', schoolId: 's1', name: 'Secondary'),
        ],
        classes: const [
          SchoolClass(id: 'cl1', schoolId: 's1', name: 'S1', levelId: 'l1'),
        ],
        subjects: const [
          Subject(
            id: 'sub1',
            schoolId: 's1',
            name: 'Math',
            assignedLevelIds: ['l1'],
            assignedClassIds: ['cl1'],
          ),
        ],
        gradingSystems: const [
          GradingSystemDef(id: 'g1', schoolId: 's1', name: 'Default'),
        ],
      );
      final resolved = StructureWizardResolver().resolve(state);
      expect(
        resolved.isComplete,
        isTrue,
        reason: resolved.currentStep?.definition.id,
      );
    });

    test('optional steps (departments, streams) do not block completion', () {
      final now = DateTime.now();
      final state = emptyState.copyWith(
        institutionProfile: const InstitutionProfile(
          name: 'Test School',
          schoolType: 'primary',
          country: 'Uganda',
          timeZone: 'Africa/Kampala',
          currency: 'UGX',
        ),
        campuses: const [Campus(id: 'c1', schoolId: 's1', name: 'Main')],
        academicYears: [
          AcademicYear(
            id: 'y1',
            schoolId: 's1',
            name: '2026',
            startDate: now,
            endDate: now.add(const Duration(days: 300)),
            isCurrent: true,
          ),
        ],
        academicTerms: [
          AcademicTerm(
            id: 't1',
            schoolId: 's1',
            academicYearId: 'y1',
            name: 'Term 1',
            startDate: now,
            endDate: now.add(const Duration(days: 90)),
          ),
        ],
        levels: const [
          EducationalLevel(id: 'l1', schoolId: 's1', name: 'Primary'),
        ],
        classes: const [
          SchoolClass(id: 'cl1', schoolId: 's1', name: 'P1', levelId: 'l1'),
        ],
        subjects: const [
          Subject(
            id: 'sub1',
            schoolId: 's1',
            name: 'Math',
            assignedLevelIds: ['l1'],
            assignedClassIds: ['cl1'],
          ),
        ],
        gradingSystems: const [
          GradingSystemDef(id: 'g1', schoolId: 's1', name: 'Default'),
        ],
        // No departments, no streams - both optional in the registry.
      );
      final resolved = StructureWizardResolver().resolve(state);
      expect(
        resolved.isComplete,
        isTrue,
        reason: resolved.currentStep?.definition.id,
      );
    });
  });
}
