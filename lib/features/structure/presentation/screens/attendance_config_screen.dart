import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/attendance_config_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Custom attendance statuses and session types Structure exposes for the
/// Attendance module to consume - the Attendance engine itself is untouched.
class AttendanceConfigScreen extends StatefulWidget {
  final int initialTab;
  const AttendanceConfigScreen({super.key, this.initialTab = 0});

  @override
  State<AttendanceConfigScreen> createState() => _AttendanceConfigScreenState();
}

class _AttendanceConfigScreenState extends State<AttendanceConfigScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, 1);
  }

  @override
  void didUpdateWidget(covariant AttendanceConfigScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Attendance Configuration'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go(
                      '/staff/admin/structure/attendance-config?tab=0',
                    ),
                    child: const Text('Attendance types'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go(
                      '/staff/admin/structure/attendance-config?tab=1',
                    ),
                    child: const Text('Sessions'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<StructureBloc, StructureState>(
              builder: (context, state) => _selectedIndex == 0
                  ? _AttendanceTypesTab(state: state)
                  : _AttendanceSessionsTab(state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTypesTab extends StatelessWidget {
  final StructureState state;
  const _AttendanceTypesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.attendanceTypes.isEmpty
          ? const StructureEmptyHint(
              'No attendance types defined yet.\ne.g. Present, Absent, Late, Excused.',
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.l),
              itemCount: state.attendanceTypes.length,
              itemBuilder: (context, index) {
                final type = state.attendanceTypes[index];
                Color color = Colors.blueGrey;
                if (type.colorHex.isNotEmpty) {
                  try {
                    color = Color(
                      int.parse(type.colorHex.replaceFirst('#', '0xff')),
                    );
                  } catch (_) {}
                }
                return StructureListRow(
                  icon: Icons.event_available_outlined,
                  color: color,
                  title: type.name,
                  isActive: type.isActive,
                  badge: StructureStatusBadge(
                    label: 'Active',
                    isActive: type.isActive,
                  ),
                  onEdit: () => showAttendanceTypeFormDialog(
                    context,
                    existing: type,
                    schoolId: schoolId,
                    onSave: (u) => bloc.add(SaveAttendanceTypeRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Type',
                      message: 'Delete "${type.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteAttendanceTypeRequested(type.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => showAttendanceTypeFormDialog(
          context,
          schoolId: schoolId,
          onSave: (t) => bloc.add(SaveAttendanceTypeRequested(t)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Type'),
      ),
    );
  }
}

class _AttendanceSessionsTab extends StatelessWidget {
  final StructureState state;
  const _AttendanceSessionsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.attendanceSessions.isEmpty
          ? const StructureEmptyHint(
              'No attendance sessions defined yet.\ne.g. Morning, Afternoon, Lesson, Gate.',
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.l),
              itemCount: state.attendanceSessions.length,
              itemBuilder: (context, index) {
                final session = state.attendanceSessions[index];
                return StructureListRow(
                  icon: Icons.schedule_outlined,
                  color: Colors.cyan,
                  title: session.name,
                  isActive: session.isActive,
                  badge: StructureStatusBadge(
                    label: 'Active',
                    isActive: session.isActive,
                  ),
                  onEdit: () => showAttendanceSessionFormDialog(
                    context,
                    existing: session,
                    schoolId: schoolId,
                    onSave: (u) => bloc.add(SaveAttendanceSessionRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Session',
                      message: 'Delete "${session.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteAttendanceSessionRequested(session.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => showAttendanceSessionFormDialog(
          context,
          schoolId: schoolId,
          onSave: (s) => bloc.add(SaveAttendanceSessionRequested(s)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Session'),
      ),
    );
  }
}
