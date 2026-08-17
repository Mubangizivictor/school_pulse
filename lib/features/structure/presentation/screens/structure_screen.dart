import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';
import 'institution_profile_screen.dart';
import 'academic_structure_screen.dart';
import 'people_structure_screen.dart';
import 'assessment_grading_screen.dart';
import 'campus_facilities_screen.dart';
import 'operations_config_screen.dart';
import 'feature_toggles_screen.dart';
import 'curriculum_assignment_screen.dart';
import 'academic_staff_assignment_screen.dart';
import 'class_timetable_screen.dart';

/// Structure V2: one dependency-ordered setup flow.
///
/// This intentionally does not navigate from a wizard card into a second
/// management hierarchy. The real editors are mounted directly inside the
/// current step so the administrator always knows where they are and what
/// comes next.
class StructureScreen extends StatefulWidget {
  const StructureScreen({super.key});

  @override
  State<StructureScreen> createState() => _StructureScreenState();
}

class _StructureScreenState extends State<StructureScreen> {
  int _index = 0;

  static const _steps = <_StructureStep>[
    _StructureStep('Institution', 'Confirm the school identity and institutional profile before academic setup.'),
    _StructureStep('Academic year', 'Create the school year and set exactly one year as current.'),
    _StructureStep('Terms / semesters', 'Create periods inside the current academic year.'),
    _StructureStep('Educational levels', 'Define only the education levels this institution actually offers.'),
    _StructureStep('Classes', 'Create classes under their correct educational levels.'),
    _StructureStep('Streams / sections', 'Optionally divide classes into streams or sections.'),
    _StructureStep('Subjects', 'Build the subject catalogue before curriculum and teacher assignment.'),
    _StructureStep('Curriculum', 'Assign the correct subjects to the classes that study them.'),
    _StructureStep('People & roles', 'Configure staff roles, designations and school people structure.'),
    _StructureStep('Academic assignments', 'Assign teachers only after classes, subjects and staff exist.'),
    _StructureStep('Assessment & grading', 'Configure assessment types, grading systems and grade bands.'),
    _StructureStep('Campus & facilities', 'Configure learning spaces and physical facilities used by operations.'),
    _StructureStep('Operations', 'Configure school-day and operational structure after the academic foundation exists.'),
    _StructureStep('Feature choices', 'Enable only optional modules the institution actually uses.'),
    _StructureStep('Class timetables', 'Build timetables last, after curriculum, rooms and teacher assignments are ready.'),
    _StructureStep('Review', 'Review the configured structure before leaving setup.'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final step = _steps[_index];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Structure Setup'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${_index + 1}/${_steps.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(value: (_index + 1) / _steps.length, minHeight: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP ${_index + 1}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(step.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 5),
                          Text(step.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: _editor(state)),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: OutlinedButton.icon(
                      onPressed: _index == 0 ? null : () => setState(() => _index--),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _index == _steps.length - 1
                          ? () => Navigator.of(context).maybePop()
                          : () => setState(() => _index++),
                      icon: Icon(_index == _steps.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded),
                      label: Text(_index == _steps.length - 1 ? 'Finish' : 'Save & Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _editor(StructureState state) {
    switch (_index) {
      case 0:
        return const InstitutionProfileScreen();
      case 1:
        return const AcademicStructureScreen(section: 'years');
      case 2:
        return const AcademicStructureScreen(section: 'terms');
      case 3:
        return const AcademicStructureScreen(section: 'levels');
      case 4:
        return const AcademicStructureScreen(section: 'classes');
      case 5:
        return const AcademicStructureScreen(section: 'streams');
      case 6:
        return const AcademicStructureScreen(section: 'subjects');
      case 7:
        return const CurriculumAssignmentScreen();
      case 8:
        return const PeopleStructureScreen();
      case 9:
        return const AcademicStaffAssignmentScreen();
      case 10:
        return const AssessmentGradingScreen();
      case 11:
        return const CampusFacilitiesScreen();
      case 12:
        return const OperationsConfigScreen();
      case 13:
        return const FeatureTogglesScreen();
      case 14:
        return const ClassTimetableScreen();
      default:
        return _Review(state: state, onJump: (index) => setState(() => _index = index));
    }
  }
}

class _Review extends StatelessWidget {
  final StructureState state;
  final ValueChanged<int> onJump;

  const _Review({required this.state, required this.onJump});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, int)>[
      ('Academic years', '${state.academicYears.length}', 1),
      ('Terms / semesters', '${state.academicTerms.length}', 2),
      ('Educational levels', '${state.levels.length}', 3),
      ('Classes', '${state.classes.length}', 4),
      ('Streams / sections', '${state.streams.length}', 5),
      ('Subjects', '${state.subjects.length}', 6),
      ('Staff roles', '${state.staffRoles.length}', 8),
      ('Assessment types', '${state.assessmentTypes.length}', 10),
      ('Grading systems', '${state.gradingSystems.length}', 10),
      ('Facilities', '${state.facilities.length}', 11),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.fact_check_outlined, color: Theme.of(context).colorScheme.primary, size: 30),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text('Check every count below. Tap any row to return directly to that setup step and correct it.'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...rows.map(
                  (row) => Card(
                    child: ListTile(
                      title: Text(row.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${row.$2} configured'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => onJump(row.$3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StructureStep {
  final String title;
  final String description;
  const _StructureStep(this.title, this.description);
}
