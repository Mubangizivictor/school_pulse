import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';
import '../widgets/institution_tab.dart';
import '../widgets/setup_wizard_shell.dart';
import 'institution_settings_screen.dart';
import 'academic_calendar_step_screen.dart';
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

  List<String> get _stepTitles =>
      _steps.map((step) => step.title).toList(growable: false);

  @override
  void initState() {
    super.initState();
    // Resume at the first step that still needs setup instead of always
    // reopening at Institution: this screen has no persisted "current step"
    // of its own, and every one of the 16 steps' data (institution profile,
    // academic years, classes, subjects, ...) already lives in
    // StructureBloc's state, so an admin who already configured most of
    // Structure was otherwise forced to click through every prior step
    // again just to reach the one they actually wanted to edit.
    final state = context.read<StructureBloc>().state;
    _index = _firstIncompleteStepIndex(state);
  }

  int _firstIncompleteStepIndex(StructureState state) {
    final institutionConfigured = state.institutionProfile.name
        .trim()
        .isNotEmpty;
    if (!institutionConfigured) return 0;
    final hasCurrentYear = state.academicYears.any(
      (year) => year.isCurrent && !year.isArchived,
    );
    if (!hasCurrentYear) return 1;
    if (state.academicTerms.isEmpty) return 2;
    if (!state.levels.any((level) => level.isActive)) return 3;
    if (!state.classes.any((schoolClass) => schoolClass.isActive)) return 4;
    // Streams (5) and Teaching plans (7) are optional steps with no
    // continueEnabled gate in the switch below, so they can't block resume.
    if (!state.subjects.any((subject) => subject.isActive)) return 6;
    // Steps 8-14 (departments, responsibilities, assessment, spaces,
    // operations, feature choices, timetables) are all optional/ungated -
    // land on Review (15) once every required step above is satisfied.
    return _steps.length - 1;
  }

  Future<void> _goBack() async {
    if (!await _confirmLeaveOrExit()) return;
    if (!mounted) return;
    setState(() => _index--);
  }

  Future<void> _goContinue() async {
    if (!await _confirmLeaveCurrentStep()) return;
    if (!mounted) return;
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        if (_index == 1) {
          return SetupWizardShell(
            title: 'Academic years',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            continueEnabled: state.academicYears.any(
              (year) => year.isCurrent && !year.isArchived,
            ),
            onBack: _goBack,
            onContinue: _goContinue,
            body: AcademicStructureScreen(
              section: 'years',
              onSetUpTerms: () => setState(() => _index = 2),
              showAppBar: false,
            ),
          );
        }
        if (_index == 2) {
          return AcademicCalendarStepScreen(
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
          );
        }
        if (_index == 3) {
          return SetupWizardShell(
            title: 'Education levels',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            continueEnabled: state.levels.any((level) => level.isActive),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const AcademicStructureScreen(
              section: 'levels',
              showAppBar: false,
            ),
          );
        }
        if (_index == 4) {
          return SetupWizardShell(
            title: 'Classes',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            continueEnabled: state.classes.any(
              (schoolClass) => schoolClass.isActive,
            ),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const AcademicStructureScreen(
              section: 'classes',
              showAppBar: false,
            ),
          );
        }
        if (_index == 5) {
          return SetupWizardShell(
            title: 'Streams / Sections',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const AcademicStructureScreen(
              section: 'streams',
              showAppBar: false,
            ),
          );
        }
        if (_index == 6) {
          return SetupWizardShell(
            title: 'Subject catalogue',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            continueEnabled: state.subjects.any((subject) => subject.isActive),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const AcademicStructureScreen(
              section: 'subjects',
              showAppBar: false,
            ),
          );
        }
        if (_index == 7) {
          return SetupWizardShell(
            title: 'Teaching plans',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const TeachingPlansScreen(showAppBar: false),
          );
        }
        if (_index == 8) {
          return SetupWizardShell(
            title: 'Academic departments',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const AcademicDepartmentsScreen(showAppBar: false),
          );
        }
        if (_index == 9) {
          return SetupWizardShell(
            title: 'Academic responsibilities',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const AcademicStaffAssignmentScreen(),
          );
        }
        if (_index == 10) {
          return SetupWizardShell(
            title: 'Assessment & grading',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const AssessmentGradingScreen(showAppBar: false),
          );
        }
        if (_index == 11) {
          return SetupWizardShell(
            title: 'Spaces & rooms',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const SpacesRoomsScreen(),
          );
        }
        if (_index == 12) {
          return SetupWizardShell(
            title: 'School day & periods',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: OperationsConfigScreen(
              showAppBar: false,
              timetableSectionKey: _timetableSectionKey,
            ),
          );
        }
        if (_index == 13) {
          return SetupWizardShell(
            title: 'Feature choices',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const FeatureTogglesScreen(showAppBar: false),
          );
        }
        if (_index == 14) {
          return SetupWizardShell(
            title: 'Timetables',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            onBack: _goBack,
            onContinue: _goContinue,
            body: const TimetablesListScreen(showAppBar: false),
          );
        }
        if (_index == 15) {
          return SetupWizardShell(
            title: 'Review setup',
            stepIndex: _index,
            stepCount: _steps.length,
            stepTitles: _stepTitles,
            onJumpToStep: (index) => setState(() => _index = index),
            continueLabel: 'Finish',
            continueIcon: Icons.check_rounded,
            onBack: _goBack,
            onContinue: () async {
              final navigator = Navigator.of(context);
              if (!await _confirmLeaveCurrentStep()) return;
              if (!mounted) return;
              navigator.maybePop();
            },
            body: _Review(
              state: state,
              onJump: (index) => setState(() => _index = index),
            ),
          );
        }
        return SetupWizardShell(
          title: 'Institution profile',
          stepIndex: _index,
          stepCount: _steps.length,
          stepTitles: _stepTitles,
          onJumpToStep: (index) => setState(() => _index = index),
          onBack: () async {
            if (!await _confirmLeaveOrExit()) return;
            if (context.mounted) Navigator.of(context).maybePop();
          },
          onContinue: _goContinue,
          onSaveDraft: () async {
            await _institutionTabKey.currentState?.saveDraft();
          },
          body: InstitutionSettingsScreen(
            tabKey: _institutionTabKey,
            showAppBar: false,
            wizardMode: true,
          ),
        );
      },
    );
  }

  /// Gates moving forward (Continue): Step 1 must pass full validation
  /// before its data counts as saved.
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

  /// Gates moving backward or exiting the wizard entirely. Unlike
  /// [_confirmLeaveCurrentStep], this must never require Step 1's fields to
  /// pass "Continue" validation - a partially-filled profile is a legitimate
  /// reason to go back or leave, not a reason to trap the admin on the
  /// step with no way out. Offers to save/discard/cancel instead.
  Future<bool> _confirmLeaveOrExit() async {
    if (_index == 0) {
      return await _institutionTabKey.currentState?.confirmDiscardIfDirty(
            context,
          ) ??
          true;
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

  /// When set, tapping this row navigates directly to this route instead of
  /// jumping to [stepIndex] within the wizard - used for destinations (e.g.
  /// Fee plans) that live outside the linear wizard step sequence.
  final String? routePath;

  const _ReviewRow({
    required this.label,
    required this.icon,
    this.count,
    this.stepIndex = -1,
    this.requiresSetup = false,
    this.routePath,
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
      const _ReviewRow(
        label: 'Fee plans',
        icon: Icons.receipt_long_outlined,
        stepIndex: 6,
        routePath: '/staff/admin/structure/academics/fee-structures',
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
      // Salary Structures lives outside this linear setup wizard (it's an
      // ongoing management surface, same as Fee Plans), so it navigates via
      // a real route rather than a wizard-step index.
      const _ReviewRow(
        label: 'Salary structures',
        icon: Icons.payments_outlined,
        stepIndex: 8,
        routePath: '/staff/admin/structure/people/salary-structures',
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
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: scheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Setup ready',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              onTap: () => rows[i].routePath != null
                  ? context.push(rows[i].routePath!)
                  : onJump(rows[i].stepIndex),
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
