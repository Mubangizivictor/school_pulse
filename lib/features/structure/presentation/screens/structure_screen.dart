import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/structure/domain/services/structure_setup_progress_calculator.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

/// Structure's route-backed control panel. It exposes a small, clear category
/// navigator rather than an unbounded grid of settings.
class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key, this.initialSection = 'overview'});

  final String initialSection;
  static const _sections = [
    ('overview', 'Overview'),
    ('institution', 'Institution'),
    ('academics', 'Academics'),
    ('people', 'People'),
    ('operations', 'Operations'),
    ('rules', 'Rules'),
    ('templates', 'Templates'),
    ('features', 'Features'),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _sections.any((item) => item.$1 == initialSection)
        ? initialSection
        : 'overview';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Structure'),
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
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'validation', child: Text('Check setup')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _CategoryNavigation(selected: selected),
          Expanded(
            child: BlocBuilder<StructureBloc, StructureState>(
              builder: (context, state) =>
                  _CategoryBody(section: selected, state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryNavigation extends StatelessWidget {
  const _CategoryNavigation({required this.selected});
  final String selected;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      scrollDirection: Axis.horizontal,
      itemCount: StructureScreen._sections.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final item = StructureScreen._sections[index];
        final active = item.$1 == selected;
        return Material(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () =>
                context.go('/staff/admin/structure?section=${item.$1}'),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Text(
                item.$2,
                style: TextStyle(
                  color: active
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _CategoryBody extends StatelessWidget {
  const _CategoryBody({required this.section, required this.state});
  final String section;
  final StructureState state;

  @override
  Widget build(BuildContext context) {
    if (section == 'overview') return _Overview(state: state);
    final pages = <String, List<_Destination>>{
      'institution': [
        _Destination(
          'Institution profile',
          'School identity, contact and regional settings',
          Icons.account_balance_outlined,
          '/staff/admin/structure/institution',
        ),
      ],
      'academics': [
        _Destination(
          'Academic setup',
          'Years, terms, levels, classes and subjects',
          Icons.school_outlined,
          '/staff/admin/structure/academic',
        ),
        _Destination(
          'Assessment & grading',
          'Fee categories, assessment types and grading systems',
          Icons.fact_check_outlined,
          '/staff/admin/structure/assessment',
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
          'Houses, clubs and societies',
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
      'rules': [
        _Destination(
          'Attendance configuration',
          'Sessions, types and attendance rules',
          Icons.how_to_reg_outlined,
          '/staff/admin/structure/attendance-config',
        ),
        _Destination(
          'Assessment & progression',
          'Grading systems and promotion configuration',
          Icons.rule_outlined,
          '/staff/admin/structure/assessment?tab=2',
        ),
        _Destination(
          'Timetable rules',
          'Working days and hours',
          Icons.schedule_outlined,
          '/staff/admin/structure/timetable-config',
        ),
      ],
      'templates': [
        _Destination(
          'Communication templates',
          'Announcement categories and message templates',
          Icons.campaign_outlined,
          '/staff/admin/structure/communication-config',
        ),
        _Destination(
          'Document templates',
          'Manage generated document templates',
          Icons.description_outlined,
          '/staff/admin/structure/document-templates',
        ),
        _Destination(
          'Custom fields',
          'Extend school records without code changes',
          Icons.view_list_outlined,
          '/staff/admin/structure/custom-fields',
        ),
      ],
      'features': [
        _Destination(
          'Feature settings',
          'Enable optional modules for this school',
          Icons.toggle_on_outlined,
          '/staff/admin/structure/feature-toggles',
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
    final progress = StructureSetupProgressCalculator().calculate(state);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress.ratio,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      strokeWidth: 5,
                    ),
                    Text(
                      '${progress.percentage}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration health',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${progress.configuredCount} configured · ${progress.pendingCount} need attention',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Academic status',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _StatusRow(label: 'Academic years', value: state.academicYears.length),
        _StatusRow(label: 'Educational levels', value: state.levels.length),
        _StatusRow(label: 'Classes', value: state.classes.length),
        _StatusRow(label: 'Subjects', value: state.subjects.length),
        _StatusRow(label: 'Departments', value: state.departments.length),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => context.push('/staff/admin/structure/wizard'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Continue setup'),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
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
