import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/services/structure_setup_progress_calculator.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import '../widgets/institution_tab.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_overview_kit.dart';

/// Structure's route-backed control panel. It exposes a small, clear category
/// navigator rather than an unbounded grid of settings.
class StructureScreen extends StatefulWidget {
  const StructureScreen({super.key, this.initialSection = 'overview'});

  final String initialSection;

  @override
  State<StructureScreen> createState() => _StructureScreenState();
}

class _StructureScreenState extends State<StructureScreen> {
  final _institutionTabKey = GlobalKey<InstitutionTabState>();

  static const _sections = [
    ('overview', 'Overview'),
    ('institution', 'Institution'),
    ('academics', 'Academics'),
    ('people', 'People'),
    ('operations', 'Operations'),
  ];

  /// Destinations only reachable via the overflow menu - they still exist
  /// and are still fully supported, they just don't get a top-level pill in
  /// the reference layout's 5-tab row.
  static const _moreDestinations = [
    _Destination(
      'Attendance & assessment rules',
      'Grading systems and promotion configuration',
      Icons.rule_outlined,
      '/staff/admin/structure/attendance-config',
    ),
    _Destination(
      'Templates',
      'Communication, document and custom field templates',
      Icons.description_outlined,
      '/staff/admin/structure/document-templates',
    ),
    _Destination(
      'Feature settings',
      'Enable optional modules for this school',
      Icons.toggle_on_outlined,
      '/staff/admin/structure/feature-toggles',
    ),
  ];

  Future<bool> _confirmLeaveInstitutionIfDirty() async {
    final formState = _institutionTabKey.currentState;
    if (formState == null) return true;
    return formState.confirmDiscardIfDirty(context);
  }

  Future<void> _switchSection(String id, String selected) async {
    if (selected == 'institution' && id != 'institution') {
      if (!await _confirmLeaveInstitutionIfDirty()) return;
    }
    if (!mounted) return;
    context.go('/staff/admin/structure?section=$id');
  }

  @override
  Widget build(BuildContext context) {
    final selected = _sections.any((item) => item.$1 == widget.initialSection)
        ? widget.initialSection
        : 'overview';
    return PopScope(
      canPop: selected != 'institution',
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeaveInstitutionIfDirty() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AdminAppBar(
          title: 'Structure',
          actions: [
            IconButton(
              tooltip: 'Setup progress',
              onPressed: () => context.push('/staff/admin/structure/progress'),
              icon: const Icon(Icons.task_alt_outlined),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'validation') {
                  context.push('/staff/admin/structure/validation');
                  return;
                }
                final destination = _moreDestinations.firstWhere(
                  (d) => d.route == value,
                  orElse: () => _moreDestinations.first,
                );
                context.push(destination.route);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'validation',
                  child: Text('Check setup'),
                ),
                const PopupMenuDivider(),
                for (final d in _moreDestinations)
                  PopupMenuItem(value: d.route, child: Text(d.title)),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 4),
            StructureTopTabs(
              sections: _sections,
              selected: selected,
              onSelected: (id) => _switchSection(id, selected),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: BlocBuilder<StructureBloc, StructureState>(
                builder: (context, state) => selected == 'institution'
                    ? InstitutionTab(key: _institutionTabKey)
                    : _CategoryBody(section: selected, state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBody extends StatelessWidget {
  const _CategoryBody({required this.section, required this.state});
  final String section;
  final StructureState state;

  @override
  Widget build(BuildContext context) {
    if (section == 'overview') return _Overview(state: state);
    final pages = <String, List<_Destination>>{
      'academics': [
        _Destination(
          'Academics',
          'Levels, years, terms, classes, subjects and more',
          Icons.school_outlined,
          '/staff/admin/structure/academics',
        ),
        _Destination(
          'Timetable',
          'Teaching days, periods and school hours',
          Icons.schedule_outlined,
          '/staff/admin/structure/timetable-config',
        ),
      ],
      'people': [
        _Destination(
          'People structure',
          'Departments, designations and staff roles',
          Icons.groups_outlined,
          '/staff/admin/structure/people',
        ),
        _Destination(
          'Houses & campus life',
          'Campuses, houses, clubs and societies',
          Icons.home_work_outlined,
          '/staff/admin/structure/campus?tab=1',
        ),
      ],
      'operations': [
        _Destination(
          'Campuses & facilities',
          'Campuses, facilities, hostels and transport structure',
          Icons.apartment_outlined,
          '/staff/admin/structure/campus',
        ),
        _Destination(
          'Operational configuration',
          'Timetable, attendance and communication defaults',
          Icons.tune_outlined,
          '/staff/admin/structure/operations',
        ),
      ],
    };
    return _DestinationList(items: pages[section] ?? const []);
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.state});
  final StructureState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const _OverviewSkeleton();
    }

    final progress = StructureSetupProgressCalculator().calculate(state);
    final schoolId = switch (context.watch<AuthBloc>().state) {
      AuthAuthenticated(:final user) => user.schoolId,
      _ => '',
    };
    final bloc = context.read<StructureBloc>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ConfigurationHealthCard(
          percentage: progress.percentage,
          ratio: progress.ratio,
          configuredCount: progress.configuredCount,
          pendingCount: progress.pendingCount,
          onViewDetails: () => context.push('/staff/admin/structure/progress'),
        ),
        const SizedBox(height: 22),
        Text(
          'Academic structure',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 3 : 2;
            const spacing = 10.0;
            final cardWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            final cards = [
              StructureMetricCard(
                icon: Icons.calendar_today_outlined,
                color: Colors.blue,
                title: 'Academic years',
                count: state.academicYears.length,
                onTap: () => context.push(
                  '/staff/admin/structure/academics/years-terms',
                ),
              ),
              StructureMetricCard(
                icon: Icons.menu_book_outlined,
                color: Colors.teal,
                title: 'Ed. levels',
                count: state.levels.length,
                onTap: () =>
                    context.push('/staff/admin/structure/academics/levels'),
              ),
              StructureMetricCard(
                icon: Icons.school_outlined,
                color: Colors.amber,
                title: 'Classes',
                count: state.classes.length,
                onTap: () => context.push(
                  '/staff/admin/structure/academics/classes-streams',
                ),
              ),
              StructureMetricCard(
                icon: Icons.auto_stories_outlined,
                color: Colors.purple,
                title: 'Subjects',
                count: state.subjects.length,
                onTap: () =>
                    context.push('/staff/admin/structure/academics/subjects'),
              ),
              StructureMetricCard(
                icon: Icons.account_balance_outlined,
                color: Colors.redAccent,
                title: 'Departments',
                count: state.departments.length,
                onTap: () => context.push(
                  '/staff/admin/structure/academics/departments',
                ),
              ),
              StructureMetricCard(
                icon: Icons.account_tree_outlined,
                color: Colors.green,
                title: 'Sections',
                count: state.streams.length,
                onTap: () => context.push(
                  '/staff/admin/structure/academics/classes-streams',
                ),
              ),
            ];
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final card in cards)
                  SizedBox(width: cardWidth, child: card),
              ],
            );
          },
        ),
        if (progress.pendingCount > 0) ...[
          const SizedBox(height: 20),
          StructureAttentionCard(
            pendingCount: progress.pendingCount,
            onReview: () => context.push('/staff/admin/structure/progress'),
          ),
        ],
        const SizedBox(height: 22),
        Text(
          'Quick actions',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StructureQuickActionCard(
                icon: Icons.calendar_month_outlined,
                label: 'Add\nAcademic Year',
                onTap: () => showAcademicYearFormDialog(
                  context,
                  schoolId: schoolId,
                  onSave: (year) => bloc.add(SaveAcademicYearRequested(year)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StructureQuickActionCard(
                icon: Icons.layers_outlined,
                label: 'Add Level',
                onTap: () => showLevelFormDialog(
                  context,
                  schoolId: schoolId,
                  onSave: (level) => bloc.add(SaveLevelRequested(level)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StructureQuickActionCard(
                icon: Icons.school_outlined,
                label: 'Add Class',
                onTap: () {
                  if (state.levels.isEmpty) {
                    context.push('/staff/admin/structure/academic?tab=0');
                    return;
                  }
                  showClassFormDialog(
                    context,
                    levels: state.levels,
                    schoolId: schoolId,
                    onSave: (c) => bloc.add(SaveClassRequested(c)),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StructureQuickActionCard(
                icon: Icons.auto_stories_outlined,
                label: 'Add Subject',
                onTap: () => showSubjectFormDialog(
                  context,
                  departments: state.departments,
                  schoolId: schoolId,
                  onSave: (s) => bloc.add(SaveSubjectRequested(s)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StructureQuickActionCard(
                icon: Icons.grid_view_rounded,
                label: 'More\nActions',
                onTap: () =>
                    _showMoreActionsSheet(context, state, bloc, schoolId),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _continueSetup(context, progress),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Continue setup',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _continueSetup(BuildContext context, StructureSetupProgress progress) {
    final next = progress.sections.where((s) => !s.isConfigured).toList();
    if (next.isEmpty) {
      context.push('/staff/admin/structure/wizard');
      return;
    }
    final core = next.where((s) => s.isCore).toList();
    final target = core.isNotEmpty ? core.first : next.first;
    context.push(target.route);
  }

  void _showMoreActionsSheet(
    BuildContext context,
    StructureState state,
    StructureBloc bloc,
    String schoolId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More actions',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_outlined),
                title: const Text('Add Department'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDepartmentFormDialog(
                    context,
                    schoolId: schoolId,
                    onSave: (d) => bloc.add(SaveDepartmentRequested(d)),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text('Add Stream/Section'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (state.classes.isEmpty) {
                    context.push('/staff/admin/structure/academic?tab=1');
                    return;
                  }
                  showStreamFormDialog(
                    context,
                    classes: state.classes,
                    schoolId: schoolId,
                    onSave: (s) => bloc.add(SaveStreamRequested(s)),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note_outlined),
                title: const Text('Add Term/Semester'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (state.academicYears.isEmpty) {
                    context.push('/staff/admin/structure/academic?tab=0');
                    return;
                  }
                  showAcademicTermFormDialog(
                    context,
                    years: state.academicYears,
                    schoolId: schoolId,
                    onSave: (t) => bloc.add(SaveAcademicTermRequested(t)),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Add Staff Role'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showStaffRoleFormDialog(
                    context,
                    designations: state.designations,
                    schoolId: schoolId,
                    onSave: (r) => bloc.add(SaveStaffRoleRequested(r)),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.home_work_outlined),
                title: const Text('Houses & clubs'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/staff/admin/structure/campus?tab=1');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainer;
    Widget block(double height, {double? width}) => Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(14),
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        block(84),
        const SizedBox(height: 22),
        block(20, width: 160),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: List.generate(
            6,
            (_) => Container(
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Destination {
  const _Destination(this.title, this.subtitle, this.icon, this.route);
  final String title, subtitle, route;
  final IconData icon;
}

class _DestinationList extends StatelessWidget {
  const _DestinationList({required this.items});
  final List<_Destination> items;
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final item = items[index];
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(item.route),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
