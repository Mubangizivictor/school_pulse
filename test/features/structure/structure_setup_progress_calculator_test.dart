import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/services/structure_setup_progress_calculator.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

void main() {
  final calculator = StructureSetupProgressCalculator();

  test('an empty state has 0% progress and every section pending', () {
    final progress = calculator.calculate(const StructureState());
    expect(progress.configuredCount, 0);
    expect(progress.percentage, 0);
    expect(progress.pendingCount, progress.sections.length);
  });

  test('a section becomes configured once its list is non-empty', () {
    final state = StructureState(
      levels: [
        const EducationalLevel(id: 'l1', schoolId: 's1', name: 'Primary'),
      ],
    );
    final progress = calculator.calculate(state);
    final levelSection = progress.sections.firstWhere(
      (s) => s.title == 'Educational Levels',
    );
    expect(levelSection.isConfigured, true);
    expect(progress.configuredCount, 1);
  });

  test('institution identity is a required setup step', () {
    final incomplete = calculator.calculate(const StructureState());
    expect(
      incomplete.sections.first.title,
      'Institution Profile',
      reason: 'Continue setup must establish school identity before structure',
    );
    expect(incomplete.sections.first.isConfigured, false);

    final complete = calculator.calculate(
      const StructureState(
        institutionProfile: InstitutionProfile(name: 'School Pulse Academy'),
      ),
    );
    expect(complete.sections.first.isConfigured, true);
  });

  test('percentage reflects the ratio of configured to total sections', () {
    final state = StructureState(
      levels: [
        const EducationalLevel(id: 'l1', schoolId: 's1', name: 'Primary'),
      ],
    );
    final progress = calculator.calculate(state);
    expect(progress.ratio, progress.configuredCount / progress.sections.length);
  });

  test('core sections are flagged so the UI can badge them as required', () {
    final progress = calculator.calculate(const StructureState());
    final coreSections = progress.sections.where((s) => s.isCore);
    expect(
      coreSections.map((s) => s.title),
      containsAll([
        'Institution Profile',
        'Educational Levels',
        'Academic Years',
      ]),
    );
  });
}
