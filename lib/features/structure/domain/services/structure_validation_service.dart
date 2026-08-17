import 'package:equatable/equatable.dart';
import '../../presentation/bloc/structure_state.dart';
import 'capacity_validation_service.dart';

enum ValidationSeverity { warning, error }

class StructureValidationIssue extends Equatable {
  final String category;
  final String message;
  final ValidationSeverity severity;
  final String? fixRoute;

  const StructureValidationIssue({
    required this.category,
    required this.message,
    this.severity = ValidationSeverity.warning,
    this.fixRoute,
  });

  @override
  List<Object?> get props => [category, message, severity, fixRoute];
}

/// Cross-entity consistency checks within Structure's own configuration -
/// distinct from [StructureDependencyService], which checks whether other
/// modules' records reference a given item before archive/delete. These
/// checks only look at data Structure itself owns (never reaching into
/// Teachers/Students/etc.), so they don't cross the module boundary.
class StructureValidationService {
  List<StructureValidationIssue> validate(StructureState state) {
    final issues = <StructureValidationIssue>[];
    issues.addAll(_findOrphanedStreams(state));
    issues.addAll(_findClassesWithoutLevel(state));
    issues.addAll(_findOverlappingGradeBands(state));
    issues.addAll(_findTermsOutsideYearRange(state));
    issues.addAll(_findOverlappingTerms(state));
    issues.addAll(_findStreamCapacityViolations(state));
    return issues;
  }

  List<StructureValidationIssue> _findOrphanedStreams(StructureState state) {
    final activeClassIds = state.classes
        .where((c) => c.isActive)
        .map((c) => c.id)
        .toSet();
    return state.streams
        .where((s) => !activeClassIds.contains(s.classId))
        .map(
          (s) => StructureValidationIssue(
            category: 'Streams / Sections',
            message:
                '"${s.name}" references a class that no longer exists or is archived.',
            severity: ValidationSeverity.error,
            fixRoute: '/staff/admin/structure/academic?tab=1',
          ),
        )
        .toList();
  }

  List<StructureValidationIssue> _findClassesWithoutLevel(
    StructureState state,
  ) {
    final levelIds = state.levels.map((l) => l.id).toSet();
    return state.classes
        .where(
          (c) =>
              c.isActive &&
              (c.levelId.isEmpty || !levelIds.contains(c.levelId)),
        )
        .map(
          (c) => StructureValidationIssue(
            category: 'Classes',
            message: '"${c.name}" has no valid Educational Level assigned.',
            severity: ValidationSeverity.warning,
            fixRoute: '/staff/admin/structure/academic?tab=1',
          ),
        )
        .toList();
  }

  List<StructureValidationIssue> _findOverlappingGradeBands(
    StructureState state,
  ) {
    final issues = <StructureValidationIssue>[];
    for (final system in state.gradingSystems) {
      final bands =
          state.gradeBands.where((b) => b.gradingSystemId == system.id).toList()
            ..sort((a, b) => a.minScore.compareTo(b.minScore));
      for (var i = 0; i < bands.length - 1; i++) {
        final current = bands[i];
        final next = bands[i + 1];
        if (current.maxScore > next.minScore) {
          issues.add(
            StructureValidationIssue(
              category: 'Grading Systems',
              message:
                  'In "${system.name}", "${current.grade}" (${current.minScore}-${current.maxScore}) overlaps with "${next.grade}" (${next.minScore}-${next.maxScore}).',
              severity: ValidationSeverity.error,
              fixRoute: '/staff/admin/structure/academics/grading-systems',
            ),
          );
        }
      }
    }
    return issues;
  }

  List<StructureValidationIssue> _findTermsOutsideYearRange(
    StructureState state,
  ) {
    final issues = <StructureValidationIssue>[];
    final yearsById = {for (final y in state.academicYears) y.id: y};
    for (final term in state.academicTerms) {
      final year = yearsById[term.academicYearId];
      if (year == null) {
        issues.add(
          StructureValidationIssue(
            category: 'Terms',
            message:
                '"${term.name}" references an academic year that no longer exists.',
            severity: ValidationSeverity.error,
            fixRoute: '/staff/admin/structure/academic?tab=0',
          ),
        );
        continue;
      }
      if (term.startDate.isBefore(year.startDate) ||
          term.endDate.isAfter(year.endDate)) {
        issues.add(
          StructureValidationIssue(
            category: 'Terms',
            message:
                '"${term.name}" dates fall outside "${year.name}"\'s academic year range.',
            severity: ValidationSeverity.warning,
            fixRoute: '/staff/admin/structure/academic?tab=0',
          ),
        );
      }
    }
    return issues;
  }

  List<StructureValidationIssue> _findOverlappingTerms(StructureState state) {
    final issues = <StructureValidationIssue>[];
    final activeTerms = state.academicTerms.where((term) => !term.isArchived);
    final byYear = <String, List<dynamic>>{};
    for (final term in activeTerms) {
      (byYear[term.academicYearId] ??= []).add(term);
    }
    for (final entry in byYear.entries) {
      final terms = entry.value
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      for (var index = 1; index < terms.length; index++) {
        final previous = terms[index - 1];
        final current = terms[index];
        if (!current.startDate.isAfter(previous.endDate)) {
          issues.add(
            StructureValidationIssue(
              category: 'Terms',
              message: '"${current.name}" overlaps "${previous.name}".',
              severity: ValidationSeverity.error,
              fixRoute:
                  '/staff/admin/structure/academics/years-terms?mode=terms',
            ),
          );
        }
      }
    }
    return issues;
  }

  List<StructureValidationIssue> _findStreamCapacityViolations(
    StructureState state,
  ) {
    const capacity = CapacityValidationService();
    return [
      for (final schoolClass in state.classes.where((item) => item.isActive))
        if (!capacity
            .validateClassCapacityChange(
              candidate: schoolClass,
              newCapacity: schoolClass.capacity,
              streams: state.streams,
            )
            .isValid)
          StructureValidationIssue(
            category: 'Streams / Sections',
            message:
                '"${schoolClass.name}" has active stream capacity above its class capacity.',
            severity: ValidationSeverity.error,
            fixRoute: '/staff/admin/structure/academics/classes-streams',
          ),
    ];
  }
}
