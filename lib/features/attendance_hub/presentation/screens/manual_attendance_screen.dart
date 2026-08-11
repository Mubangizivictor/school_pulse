import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_scope.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class ManualAttendanceScreen extends StatefulWidget {
  final AttendanceCategory category;

  const ManualAttendanceScreen({super.key, required this.category});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

enum _Step { scope, roster, review, success }

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  _Step _step = _Step.scope;
  AttendanceScope? _selectedScope;
  final Map<String, AttendanceStatus> _marks = {};
  List<AttendancePerson> _roster = [];
  final DateTime _date = DateTime.now();
  static const _sessionType = 'daily';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
        LoadScopesRequested(
          schoolId: authState.user.schoolId,
          category: widget.category,
          operatorUser: authState.user,
        ),
      );
    }
  }

  void _selectScope(AttendanceScope scope) {
    setState(() {
      _selectedScope = scope;
      _step = _Step.roster;
    });
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
        LoadRosterRequested(
          schoolId: authState.user.schoolId,
          category: widget.category,
          scopeId: scope.id,
          operatorUser: authState.user,
        ),
      );
    }
  }

  void _markAll(AttendanceStatus status) {
    setState(() {
      for (final p in _roster) {
        _marks[p.id] = status;
      }
    });
  }

  Future<void> _addPersonManually() async {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID / Code (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (added != true || nameController.text.trim().isEmpty) return;

    final name = nameController.text.trim();
    final code = idController.text.trim();
    final id = code.isNotEmpty
        ? code
        : '${name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _roster.add(
        AttendancePerson(
          id: id,
          name: name,
          subtitle: code.isEmpty ? null : code,
        ),
      );
      _marks[id] = AttendanceStatus.present;
    });
  }

  void _save() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _selectedScope == null) return;
    final user = authState.user;

    final records = _roster.map((p) {
      return AttendanceRecord(
        id: '',
        schoolId: user.schoolId,
        category: widget.category,
        scopeId: _selectedScope!.id,
        scopeName: _selectedScope!.name,
        sessionType: _sessionType,
        date: _date,
        personId: p.id,
        personName: p.name,
        status: _marks[p.id] ?? AttendanceStatus.present,
        method: AttendanceMethod.manual,
        markedBy: user.name,
        operatorId: user.id,
        createdAt: DateTime.now(),
      );
    }).toList();

    context.read<AttendanceBloc>().add(
      MarkBatchAttendanceRequested(records: records, operatorUser: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is RosterLoaded) {
          setState(() {
            _roster = state.roster;
            for (final p in _roster) {
              _marks[p.id] = AttendanceStatus.present;
            }
          });
        } else if (state is AttendanceBatchMarkSuccess) {
          setState(() => _step = _Step.success);
        } else if (state is AttendanceDuplicate) {
          setState(() => _step = _Step.review);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AttendanceActionDenied) {
          setState(() => _step = _Step.review);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AttendanceError) {
          setState(() => _step = _Step.review);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Manual Attendance'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_step) {
      case _Step.scope:
        return BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading || state is AttendanceInitial) {
              return const Center(child: SchoolPulseLoader());
            }
            if (state is! ScopesLoaded) return const SizedBox.shrink();
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: state.scopes.length,
              itemBuilder: (context, index) {
                final scope = state.scopes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: ListTile(
                    title: Text(scope.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectScope(scope),
                  ),
                );
              },
            );
          },
        );
      case _Step.roster:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _roster.isEmpty
                          ? null
                          : () => _markAll(AttendanceStatus.present),
                      child: const Text('Mark All Present'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  OutlinedButton.icon(
                    onPressed: _addPersonManually,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {
                  if (state is AttendanceLoading) {
                    return const Center(child: SchoolPulseLoader());
                  }
                  if (_roster.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: AppColors.textMuted(context),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              'No roster available for ${widget.category.label}. '
                              'Tap "Add" to record attendance for a person.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    itemCount: _roster.length,
                    itemBuilder: (context, index) {
                      final p = _roster[index];
                      final status = _marks[p.id] ?? AttendanceStatus.present;
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (p.subtitle != null)
                                Text(
                                  p.subtitle!,
                                  style: TextStyle(
                                    color: AppColors.textMuted(context),
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.s),
                              Wrap(
                                spacing: AppSpacing.s,
                                children: AttendanceStatus.values.map((s) {
                                  return ChoiceChip(
                                    label: Text(_statusLabel(s)),
                                    selected: status == s,
                                    onSelected: (_) =>
                                        setState(() => _marks[p.id] = s),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _roster.isEmpty
                      ? null
                      : () => setState(() => _step = _Step.review),
                  child: const Text('Review'),
                ),
              ),
            ),
          ],
        );
      case _Step.review:
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text(
                    _selectedScope?.name ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ...AttendanceStatus.values.map((s) {
                    final count = _marks.values.where((v) => v == s).length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(_statusLabel(s)), Text('$count')],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step = _Step.roster),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    flex: 2,
                    child: BlocBuilder<AttendanceBloc, AttendanceState>(
                      builder: (context, state) {
                        final saving = state is AttendanceLoading;
                        return FilledButton(
                          onPressed: saving ? null : _save,
                          child: saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Attendance'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case _Step.success:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success(context),
                size: 72,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Attendance Saved',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        );
    }
  }

  String _statusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }
}
