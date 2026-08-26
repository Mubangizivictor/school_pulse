import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/app_components.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';
import '../widgets/institution_tab.dart';
import 'institution_settings_screen.dart';
import 'academic_structure_screen.dart';
import 'academic_departments_screen.dart';
import 'assessment_grading_screen.dart';
import 'spaces_rooms_screen.dart';
import 'operations_config_screen.dart';
import 'feature_toggles_screen.dart';
import 'teaching_plans_screen.dart';
import 'academic_staff_assignment_screen.dart';
import 'timetables/timetables_list_screen.dart';

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
  final _institutionTabKey = GlobalKey<InstitutionTabState>();
  final _timetableSectionKey = GlobalKey<TimetableSectionState>();

  static const _steps = <_StructureStep>[
    _StructureStep(
      'Institution',
      'Confirm the school identity and institutional profile before academic setup.',
    ),
    _StructureStep(
      'Academic year',
      'Create the school year and set exactly one year as current.',
    ),
    _StructureStep(
      'Terms / semesters',
      'Create periods inside the current academic year.',
    ),
    _StructureStep(
      'Educational levels',
      'Define only the education levels this institution actually offers.',
    ),
    _StructureStep(
      'Classes',
      'Create classes under their correct educational levels.',
    ),
    _StructureStep(
      'Streams / sections',
      'Optionally divide classes into streams or sections.',
    ),
    _StructureStep(
      'Subjects',
      'Build the subject catalogue before curriculum and teacher assignment.',
    ),
    _StructureStep(
      'Teaching plans',
      'Set the subjects and weekly lesson load for each education level.',
    ),
    _StructureStep(
      'People & roles',
      'Configure staff roles, designations and school people structure.',
    ),
    _StructureStep(
      'Academic assignments',
      'Assign teachers only after classes, subjects and staff exist.',
    ),
    _StructureStep(
      'Assessment & grading',
      'Configure assessment types, grading systems and grade bands.',
    ),
    _StructureStep(
      'Campus & facilities',
      'Configure learning spaces and physical facilities used by operations.',
    ),
    _StructureStep(
      'Operations',
      'Configure school-day and operational structure after the academic foundation exists.',
    ),
    _StructureStep(
      'Feature choices',
      'Enable only optional modules the institution actually uses.',
    ),
    _StructureStep(
      'Class timetables',
      'Build timetables last, after curriculum, rooms and teacher assignments are ready.',
    ),
    _StructureStep(
      'Review',
      'Review the configured structure before leaving setup.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        if (_index == 1) {
          return _WizardStepScreen(
            title: 'Academic years',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            continueEnabled: state.academicYears.any(
              (year) => year.isCurrent && !year.isArchived,
            ),
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: AcademicStructureScreen(
              section: 'years',
              onSetUpTerms: () => setState(() => _index = 2),
              showAppBar: false,
            ),
          );
        }
        if (_index == 2) {
          return _WizardStepScreen(
            title: 'Academic calendar',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            continueEnabled: state.academicTerms.any(
              (term) =>
                  !term.isArchived &&
                  state.academicYears.any(
                    (year) => year.id == term.academicYearId && year.isCurrent,
                  ),
            ),
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AcademicStructureScreen(
              section: 'terms',
              showAppBar: false,
            ),
          );
        }
        if (_index == 3) {
          return _WizardStepScreen(
            title: 'Education levels',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            continueEnabled: state.levels.any((level) => level.isActive),
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AcademicStructureScreen(
              section: 'levels',
              showAppBar: false,
            ),
          );
        }
        if (_index == 4) {
          return _WizardStepScreen(
            title: 'Classes',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            continueEnabled: state.classes.any(
              (schoolClass) => schoolClass.isActive,
            ),
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AcademicStructureScreen(
              section: 'classes',
              showAppBar: false,
            ),
          );
        }
        if (_index == 5) {
          return _WizardStepScreen(
            title: 'Streams / Sections',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AcademicStructureScreen(
              section: 'streams',
              showAppBar: false,
            ),
          );
        }
        if (_index == 6) {
          return _WizardStepScreen(
            title: 'Subject catalogue',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            continueEnabled: state.subjects.any((subject) => subject.isActive),
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AcademicStructureScreen(
              section: 'subjects',
              showAppBar: false,
            ),
          );
        }
        if (_index == 7) {
          return _WizardStepScreen(
            title: 'Teaching plans',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const TeachingPlansScreen(showAppBar: false),
          );
        }
        if (_index == 8) {
          return _WizardStepScreen(
            title: 'Academic departments',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AcademicDepartmentsScreen(showAppBar: false),
          );
        }
        if (_index == 9) {
          return _WizardStepScreen(
            title: 'Academic responsibilities',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AcademicStaffAssignmentScreen(),
          );
        }
        if (_index == 10) {
          return _WizardStepScreen(
            title: 'Assessment & grading',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const AssessmentGradingScreen(showAppBar: false),
          );
        }
        if (_index == 11) {
          return _WizardStepScreen(
            title: 'Spaces & rooms',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const SpacesRoomsScreen(),
          );
        }
        if (_index == 12) {
          return _WizardStepScreen(
            title: 'School day & periods',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: OperationsConfigScreen(
              showAppBar: false,
              timetableSectionKey: _timetableSectionKey,
            ),
          );
        }
        if (_index == 13) {
          return _WizardStepScreen(
            title: 'Feature choices',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const FeatureTogglesScreen(showAppBar: false),
          );
        }
        if (_index == 14) {
          return _WizardStepScreen(
            title: 'Timetables',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              setState(() => _index++);
            },
            child: const TimetablesListScreen(showAppBar: false),
          );
        }
        if (_index == 15) {
          return _WizardStepScreen(
            title: 'Review setup',
            stepNumber: _index + 1,
            totalSteps: _steps.length,
            continueLabel: 'Finish',
            continueIcon: Icons.check_rounded,
            onBack: () async {
              if (!await _confirmLeaveCurrentStep()) return;
              setState(() => _index--);
            },
            onContinue: () async {
              final navigator = Navigator.of(context);
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              navigator.maybePop();
            },
            child: _Review(
              state: state,
              onJump: (index) => setState(() => _index = index),
            ),
          );
        }
        return _InstitutionProfileStep(
          onBack: () async {
            if (!await _confirmLeaveCurrentStep()) return;
            if (context.mounted) Navigator.of(context).maybePop();
          },
          onContinue: () async {
            if (!await _confirmLeaveCurrentStep()) return;
            if (!mounted) return;
            setState(() => _index++);
          },
          child: InstitutionSettingsScreen(
            tabKey: _institutionTabKey,
            showAppBar: false,
            wizardMode: true,
          ),
        );
      },
    );
  }

  Future<bool> _confirmLeaveCurrentStep() async {
    if (_index == 0) {
      return _institutionTabKey.currentState?.saveAndValidateForContinue() ??
          false;
    }
    if (_index == 12) {
      return _timetableSectionKey.currentState?.saveIfDirty() ?? true;
    }
    return true;
  }
}

class _ReviewRow {
  final String label;
  final IconData icon;
  final int? count;
  final int stepIndex;
  final bool requiresSetup;

  /// Overrides the default `onJump(stepIndex)` behaviour with a direct
  /// navigation (e.g. a GoRouter push) instead of a wizard-step jump. Used
  /// by rows - like Fee Plans - that live outside this linear setup wizard
  /// entirely, so they need a real route rather than a step index.
  final VoidCallback? onTap;

  const _ReviewRow({
    required this.label,
    required this.icon,
    this.count,
    this.stepIndex = -1,
    this.requiresSetup = false,
    this.onTap,
  });
}

class _Review extends StatelessWidget {
  final StructureState state;
  final ValueChanged<int> onJump;

  const _Review({required this.state, required this.onJump});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final academicStructure = [
      _ReviewRow(
        label: 'Academic year',
        icon: Icons.event_available_outlined,
        count: state.academicYears.length,
        stepIndex: 1,
      ),
      _ReviewRow(
        label: 'Terms / semesters',
        icon: Icons.layers_outlined,
        count: state.academicTerms.length,
        stepIndex: 2,
      ),
      _ReviewRow(
        label: 'Educational levels',
        icon: Icons.bookmark_outline,
        count: state.levels.length,
        stepIndex: 3,
      ),
      _ReviewRow(
        label: 'Classes',
        icon: Icons.groups_outlined,
        count: state.classes.length,
        stepIndex: 4,
      ),
      _ReviewRow(
        label: 'Streams / sections',
        icon: Icons.account_tree_outlined,
        count: state.streams.length,
        stepIndex: 5,
      ),
      _ReviewRow(
        label: 'Subjects',
        icon: Icons.menu_book_outlined,
        count: state.subjects.length,
        stepIndex: 6,
      ),
      // Fee Plans lives outside this linear setup wizard (it's an ongoing
      // management surface, not a one-time setup step), so it navigates via
      // a real route rather than a wizard-step index. This is the Structure
      // hub's entry point into the Fee Plan Builder - school admin never
      // has to go through a Bursar-prefixed screen to configure billing.
      _ReviewRow(
        label: 'Fee plans',
        icon: Icons.receipt_long_outlined,
        onTap: () =>
            context.push('/staff/admin/structure/academics/fee-structures'),
      ),
    ];

    final peopleAndAssessment = [
      _ReviewRow(
        label: 'Staff roles',
        icon: Icons.person_outline,
        count: state.designations.length,
        stepIndex: 8,
        requiresSetup: state.designations.isEmpty,
      ),
      // Academic Assignments (staff <-> class/subject/department) is written
      // directly via its own repository rather than StructureBloc, so its
      // count isn't part of StructureState - this row still lets an admin
      // jump back to review it even without a live tally.
      const _ReviewRow(
        label: 'Academic responsibilities',
        icon: Icons.assignment_ind_outlined,
        stepIndex: 9,
      ),
      _ReviewRow(
        label: 'Assessment types',
        icon: Icons.assignment_outlined,
        count: state.assessmentTypes.length,
        stepIndex: 10,
        requiresSetup: state.assessmentTypes.isEmpty,
      ),
      _ReviewRow(
        label: 'Grading systems',
        icon: Icons.grading_outlined,
        count: state.gradingSystems.length,
        stepIndex: 10,
        requiresSetup: state.gradingSystems.isEmpty,
      ),
    ];

    final facilities = [
      _ReviewRow(
        label: 'Facilities',
        icon: Icons.holiday_village_outlined,
        count: state.facilities.length,
        stepIndex: 11,
      ),
    ];

    // Teaching plans and Class Timetables are likewise written via their own
    // repositories/blocs (TeachingPlanRepository, TimetableBloc), not
    // StructureState, so they're surfaced as count-less jump rows rather
    // than omitted from Review entirely.
    final schedulingAndFeatures = [
      const _ReviewRow(
        label: 'Teaching plans',
        icon: Icons.menu_book_outlined,
        stepIndex: 7,
      ),
      const _ReviewRow(
        label: 'Class timetables',
        icon: Icons.calendar_view_week_outlined,
        stepIndex: 14,
      ),
      _ReviewRow(
        label: 'Feature choices',
        icon: Icons.tune_outlined,
        count: [
          state.featureToggles.transport,
          state.featureToggles.hostel,
          state.featureToggles.library,
          state.featureToggles.medical,
          state.featureToggles.visitors,
          state.featureToggles.inventory,
          state.featureToggles.payroll,
          state.featureToggles.procurement,
          state.featureToggles.communication,
          state.featureToggles.boarding,
          state.featureToggles.qrAttendance,
          state.featureToggles.digitalIds,
          state.featureToggles.parentPortal,
          state.featureToggles.studentPortal,
          state.featureToggles.alumni,
        ].where((enabled) => enabled).length,
        stepIndex: 13,
      ),
    ];

    final allRows = [
      ...academicStructure,
      ...peopleAndAssessment,
      ...facilities,
      ...schedulingAndFeatures,
    ];
    final configuredCount = allRows.where((r) => !r.requiresSetup).length;
    final needsAttentionCount = allRows.length - configuredCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.black, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setup ready',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$configuredCount configured'
                      '${needsAttentionCount > 0 ? ' • $needsAttentionCount need attention' : ''}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReviewCategory(
          title: 'Academic structure',
          icon: Icons.school_outlined,
          rows: academicStructure,
          onJump: onJump,
        ),
        const SizedBox(height: 12),
        _ReviewCategory(
          title: 'People & assessment',
          icon: Icons.groups_2_outlined,
          rows: peopleAndAssessment,
          onJump: onJump,
        ),
        const SizedBox(height: 12),
        _ReviewCategory(
          title: 'Facilities',
          icon: Icons.apartment_outlined,
          rows: facilities,
          onJump: onJump,
        ),
        const SizedBox(height: 12),
        _ReviewCategory(
          title: 'Curriculum & scheduling',
          icon: Icons.event_note_outlined,
          rows: schedulingAndFeatures,
          onJump: onJump,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You can finish now and complete optional items later.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_ReviewRow> rows;
  final ValueChanged<int> onJump;

  const _ReviewCategory({
    required this.title,
    required this.icon,
    required this.rows,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              leading: Icon(rows[i].icon, size: 20, color: scheme.primary),
              title: Text(rows[i].label),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (rows[i].count != null)
                    Text(
                      '${rows[i].count} configured',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  if (rows[i].requiresSetup) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: scheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Needs setup',
                      style: TextStyle(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              onTap: rows[i].onTap ?? () => onJump(rows[i].stepIndex),
            ),
          ],
        ],
      ),
    );
  }
}

class _StructureStep {
  final String title;
  final String description;
  const _StructureStep(this.title, this.description);
}

/// Standalone step layout used by every restyled wizard step: its own
/// AppBar/progress bar and outlined Back / filled Save & Continue footer,
/// built entirely from the design system's ColorScheme tokens so it stays
/// correct in both light and dark mode.
class _WizardStepScreen extends StatelessWidget {
  const _WizardStepScreen({
    required this.title,
    required this.stepNumber,
    required this.totalSteps,
    required this.onBack,
    required this.onContinue,
    required this.child,
    this.continueLabel = 'Save & Continue',
    this.continueIcon = Icons.arrow_forward_rounded,
    this.continueEnabled = true,
  });

  final String title;
  final int stepNumber;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final Widget child;
  final String continueLabel;
  final IconData continueIcon;
  final bool continueEnabled;

  @override
  Widget build(BuildContext context) {
    final isFirstStep = stepNumber <= 1;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: [
            WizardStepProgress(
              currentStep: stepNumber - 1,
              stepCount: totalSteps,
              stepTitle: title,
            ),
            const Divider(height: 1),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (!isFirstStep)
                Expanded(
                  child: SecondaryButton(label: 'Back', onPressed: onBack),
                ),
              if (!isFirstStep) const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: continueLabel,
                  icon: continueIcon,
                  onPressed: continueEnabled ? onContinue : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The first setup screen intentionally has its own mobile treatment. Later
/// setup steps continue using [_WizardStepScreen] unchanged.
class _InstitutionProfileStep extends StatelessWidget {
  const _InstitutionProfileStep({
    required this.onBack,
    required this.onContinue,
    required this.child,
  });

  final Future<void> Function() onBack;
  final Future<void> Function() onContinue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  SizedBox(
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: onBack,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                            ),
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'Institution profile',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step 1 of 16',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                      Text(
                        '6%',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (int i = 0; i < 16; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: 1,
                              minHeight: 5,
                              backgroundColor: Colors.black,
                              color: i == 0 ? Colors.black : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text(
                'Save & continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
