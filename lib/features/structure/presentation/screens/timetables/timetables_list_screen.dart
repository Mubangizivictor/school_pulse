import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/timetable.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_state.dart';
import '../../bloc/timetable_bloc.dart';
import '../../bloc/timetable_event.dart';
import '../../bloc/timetable_state.dart';
import '../../widgets/structure_empty_hint.dart';
import '../../widgets/structure_ui_kit.dart';
import 'create_timetable_flow/create_timetable_screen.dart';

/// Structure -> Timetable -> Class Timetables: one card per class/stream
/// timetable, the entry point for the create wizard and the builder.
class TimetablesListScreen extends StatefulWidget {
  const TimetablesListScreen({super.key});

  @override
  State<TimetablesListScreen> createState() => _TimetablesListScreenState();
}

class _TimetablesListScreenState extends State<TimetablesListScreen> {
  String _search = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<TimetableBloc>().add(
      TimetableListRequested(schoolId: schoolId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Timetables'),
      body: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
          if (state.isLoadingList && state.timetables.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final structureState = context.watch<StructureBloc>().state;
          final filtered = _applyFilters(state.timetables, structureState);

          return ListView(
            padding: EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                'Manage class timetables, periods and school schedule settings.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              _SummaryRow(
                classesCount: structureState.classes.length,
                timetablesCount: state.timetables.length,
                activeCount: state.timetables
                    .where((t) => t.status == TimetableStatus.active)
                    .length,
              ),
              const SizedBox(height: AppSpacing.l),
              StructureSearchBar(
                hint: 'Search classes, streams...',
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: AppSpacing.m),
              StructureFilterChips(
                filters: const ['All', 'Active', 'Draft', 'Archived'],
                selectedFilter: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: AppSpacing.xl),
              StructureSectionHeader(
                title: 'Timetables',
                actionLabel: 'Create Timetable',
                onAction: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const CreateTimetableScreen(),
                      ),
                    )
                    .then((createdId) {
                      if (createdId is String && context.mounted) {
                        context.push(
                          '/staff/admin/structure/timetables/$createdId',
                        );
                      }
                    }),
              ),
              if (filtered.isEmpty)
                const StructureEmptyHint(
                  'No timetable created for this class yet.',
                ),
              ...filtered.map(
                (t) => _TimetableCard(
                  timetable: t,
                  onTap: () =>
                      context.push('/staff/admin/structure/timetables/${t.id}'),
                ),
              ),
              const SizedBox(height: AppSpacing.x4l),
            ],
          );
        },
      ),
    );
  }

  List<Timetable> _applyFilters(
    List<Timetable> timetables,
    StructureState structureState,
  ) {
    return timetables.where((t) {
      if (_filter != 'All' && t.status.label != _filter) return false;
      if (_search.isEmpty) return true;
      final className = structureState.classes
          .where((c) => c.id == t.classId)
          .map((c) => c.name)
          .firstOrNull;
      final streamName = structureState.streams
          .where((s) => s.id == t.streamId)
          .map((s) => s.name)
          .firstOrNull;
      final haystack = [
        t.name,
        className ?? '',
        streamName ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(_search.toLowerCase());
    }).toList();
  }
}

class _SummaryRow extends StatelessWidget {
  final int classesCount;
  final int timetablesCount;
  final int activeCount;

  const _SummaryRow({
    required this.classesCount,
    required this.timetablesCount,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(label: 'Classes', value: '$classesCount'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(label: 'Timetables', value: '$timetablesCount'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(label: 'Active', value: '$activeCount'),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withValues(alpha: .18)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TimetableCard extends StatelessWidget {
  final Timetable timetable;
  final VoidCallback onTap;

  const _TimetableCard({required this.timetable, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final structureState = context.watch<StructureBloc>().state;
    final className = structureState.classes
        .where((c) => c.id == timetable.classId)
        .map((c) => c.name)
        .firstOrNull;
    final streamName = structureState.streams
        .where((s) => s.id == timetable.streamId)
        .map((s) => s.name)
        .firstOrNull;
    final label = [
      className ?? timetable.name,
      if (streamName != null) streamName,
    ].join(' - ');
    final academicYear = structureState.academicYears
        .where((y) => y.id == timetable.academicYearId)
        .map((y) => y.name)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: .18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.calendar_view_week_outlined,
                    color: Colors.blue,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        academicYear ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StructureStatusBadge(
                  label: timetable.status.label,
                  isActive: timetable.status == TimetableStatus.active,
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
