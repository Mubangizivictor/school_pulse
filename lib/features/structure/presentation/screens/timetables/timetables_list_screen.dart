import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/timetable.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/timetable_bloc.dart';
import '../../bloc/timetable_event.dart';
import '../../bloc/timetable_state.dart';
import 'create_timetable_flow/create_timetable_screen.dart';

/// Optional, compact timetable workspace. It deliberately lists only actual
/// timetable records; classes without one belong in the creation flow, not a
/// long set of empty cards.
class TimetablesListScreen extends StatefulWidget {
  const TimetablesListScreen({super.key, this.showAppBar = true});
  final bool showAppBar;
  @override
  State<TimetablesListScreen> createState() => _TimetablesListScreenState();
}

class _TimetablesListScreenState extends State<TimetablesListScreen> {
  String _query = '';
  String? _yearId;
  String? _termId;
  String? _levelId;
  @override
  void initState() {
    super.initState();
    context.read<TimetableBloc>().add(
      TimetableListRequested(
        schoolId:
            (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId,
      ),
    );
  }

  void _create() => Navigator.of(context)
      .push<String>(
        MaterialPageRoute(builder: (_) => const CreateTimetableScreen()),
      )
      .then((id) {
        if (id != null && mounted)
          context.push('/staff/admin/structure/timetables/$id');
      });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.showAppBar ? AppBar(title: const Text('Timetables')) : null,
    backgroundColor: widget.showAppBar ? null : Colors.transparent,
    body: BlocBuilder<TimetableBloc, TimetableState>(
      builder: (context, state) {
        final s = context.watch<StructureBloc>().state;
        final years = s.academicYears.where((y) => !y.isArchived).toList();
        _yearId ??=
            years.where((y) => y.isCurrent).firstOrNull?.id ??
            years.firstOrNull?.id;
        final terms = s.academicTerms
            .where((t) => t.academicYearId == _yearId && !t.isArchived)
            .toList();
        _termId ??=
            terms.where((t) => t.isCurrent).firstOrNull?.id ??
            terms.firstOrNull?.id;
        final levels = s.levels.where((l) => l.isActive).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        final timetableRows = state.timetables
            .where(
              (t) =>
                  t.academicYearId == _yearId &&
                  (_termId == null || t.termId == _termId),
            )
            .where((t) {
              final c = s.classes.where((c) => c.id == t.classId).firstOrNull;
              return (_levelId == null || c?.levelId == _levelId) &&
                  '${c?.name ?? t.name} ${t.name}'.toLowerCase().contains(
                    _query.toLowerCase(),
                  );
            })
            .toList();
        final published = timetableRows
            .where((t) => t.status == TimetableStatus.active)
            .length;
        final drafts = timetableRows
            .where((t) => t.status == TimetableStatus.draft)
            .length;
        final needsReview = 0;
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _termId,
                      decoration: const InputDecoration(
                        labelText: 'Academic year and term',
                      ),
                      items: terms
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(
                                '${years.where((y) => y.id == _yearId).firstOrNull?.name ?? ''} · ${t.name}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _termId = v),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${s.classes.where((c) => c.isActive).length} classes · '
                      '$published published · $drafts drafts · $needsReview needs review',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _levelId == null,
                            onSelected: (_) => setState(() => _levelId = null),
                          ),
                          for (final l in levels)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ChoiceChip(
                                label: Text(l.name),
                                selected: _levelId == l.id,
                                onSelected: (_) =>
                                    setState(() => _levelId = l.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search timetables',
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoadingList && state.timetables.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : timetableRows.isEmpty
                    ? Center(
                        child: Text(
                          'No timetable yet\nCreate a draft after prerequisites are ready.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: timetableRows.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final t = timetableRows[i];
                          final c = s.classes
                              .where((c) => c.id == t.classId)
                              .firstOrNull;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            leading: Text(
                              c?.name ?? '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            title: Text(t.name),
                            subtitle: Text(
                              t.status == TimetableStatus.active
                                  ? 'Published · 100%'
                                  : 'Draft · needs validation',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(
                              '/staff/admin/structure/timetables/${t.id}',
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: s.classes.any((c) => c.isActive)
                        ? _create
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('New timetable'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
