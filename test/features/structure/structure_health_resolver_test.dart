import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_health_resolver.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

void main() {
  final resolver = StructureHealthResolver();

  test('hard prerequisites lock class setup until levels exist', () {
    final health = resolver.resolve(
      const StructureState(
        institutionProfile: InstitutionProfile(
          name: 'Pulse',
          schoolType: 'Primary',
        ),
      ),
    );
    expect(health.steps['classes']!.status, SetupStepStatus.locked);
    expect(health.steps['classes']!.blockedBy, contains('levels'));
  });

  test('a current academic year and active level unlock class setup', () {
    final health = resolver.resolve(
      StructureState(
        institutionProfile: const InstitutionProfile(
          name: 'Pulse',
          schoolType: 'Primary',
        ),
        academicYears: [
          AcademicYear(
            id: 'y',
            schoolId: 's',
            name: '2026',
            startDate: DateTime(2026),
            endDate: DateTime(2026, 12),
            isCurrent: true,
          ),
        ],
        levels: const [
          EducationalLevel(id: 'p', schoolId: 's', name: 'Primary'),
        ],
      ),
    );
    expect(health.steps['classes']!.status, SetupStepStatus.available);
  });

  test(
    'disabled optional modules become not applicable and do not affect health',
    () {
      final health = resolver.resolve(
        const StructureState(
          featureToggles: FeatureToggles(
            transport: false,
            boarding: false,
            hostel: false,
          ),
        ),
      );
      expect(health.steps['transport']!.status, SetupStepStatus.notApplicable);
      expect(health.steps['boarding']!.status, SetupStepStatus.notApplicable);
    },
  );
}
