import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/entities/timetable.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/timetable_bloc.dart';
import '../../bloc/timetable_event.dart';
import '../../bloc/timetable_state.dart';
import '../../widgets/structure_ui_kit.dart';
import 'create_timetable_flow/create_timetable_screen.dart';

/// Structure -> Timetable -> Class Timetables: one card per class, showing
/// whether a timetable already exists for it, and the entry point for the
/// create wizard and the builder.
class TimetablesListScreen extends StatefulWidget {
  const TimetablesListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<TimetablesListScreen> createState() => _TimetablesListScreenState();
}

class _TimetablesListScreenState extends State<TimetablesListScreen> {
  @override
  void initState() {
    super.initState();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<TimetableBloc>().add(
      TimetableListRequested(schoolId: schoolId),
    );
  }

  void _onCreate(BuildContext context, {String? classId}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CreateTimetableScreen(initialClassId: classId),
          ),
        )
        .then((createdId) {
          if (createdId is String && context.mounted) {
            context.push('/staff/admin/structure/timetables/$createdId');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Class timetables'))
          : null,
      backgroundColor: widget.showAppBar ? null : Colors.transparent,
      body: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
          if (state.isLoadingList && state.timetables.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final scheme = Theme.of(context).colorScheme;
          final structureState = context.watch<StructureBloc>().state;
          final activeClasses = structureState.classes
              .where((c) => c.isActive)
              .toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Create a timetable after periods, rooms and teacher assignments are ready.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: activeClasses.isEmpty
                            ? null
                            : () => _onCreate(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create timetable'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (activeClasses.isEmpty)
                    _TimetablesEmptyState(
                      message:
                          'Add at least one class before creating a timetable.',
                    )
                  else
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          for (final schoolClass in activeClasses)
                            Builder(
                              builder: (context) {
                                final timetable = state.timetables
                                    .where((t) => t.classId == schoolClass.id)
                                    .firstOrNull;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _ClassTimetableCard(
                                    schoolClass: schoolClass,
                                    timetable: timetable,
                                    onTap: timetable == null
                                        ? () => _onCreate(
                                            context,
                                            classId: schoolClass.id,
                                          )
                                        : () => context.push(
                                            '/staff/admin/structure/timetables/${timetable.id}',
                                          ),
                                    onCreate: () => _onCreate(
                                      context,
                                      classId: schoolClass.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (state.timetables.isEmpty)
                            _TimetablesEmptyState(
                              message:
                                  'Create the first weekly timetable for ${activeClasses.first.name}.',
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClassTimetableCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final Timetable? timetable;
  final VoidCallback onTap;
  final VoidCallback onCreate;

  const _ClassTimetableCard({
    required this.schoolClass,
    required this.timetable,
    required this.onTap,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final structureState = context.watch<StructureBloc>().state;
    final streamName = timetable == null
        ? null
        : structureState.streams
              .where((s) => s.id == timetable!.streamId)
              .map((s) => s.name)
              .firstOrNull;

    return AppCard(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.event_seat_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          schoolClass.name,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timetable == null
                  ? 'No timetable created'
                  : [
                      if (streamName != null) streamName,
                      timetable!.status.label,
                    ].join(' • '),
            ),
            const SizedBox(height: 8),
            if (timetable == null)
              OutlinedButton.icon(
                onPressed: onCreate,
                icon: Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: scheme.primary,
                ),
                label: const Text('Ready to schedule'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              )
            else
              StructureStatusBadge(
                label: timetable!.status.label,
                isActive: timetable!.status == TimetableStatus.active,
              ),
          ],
        ),
        trailing: timetable == null
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (_) => onCreate(),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'create',
                    child: Text('Create timetable'),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _TimetablesEmptyState extends StatelessWidget {
  final String message;

  const _TimetablesEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No timetable yet',
      message: message,
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
