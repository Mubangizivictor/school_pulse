import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/shared/boarding/dorm_screens.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/shared/boarding/dorm_widgets.dart';

class DormitoryManagementScreen extends StatefulWidget {
  const DormitoryManagementScreen({super.key});

  @override
  State<DormitoryManagementScreen> createState() =>
      _DormitoryManagementScreenState();
}

class _DormitoryManagementScreenState extends State<DormitoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchDormitories());
    context.read<MatronBloc>().add(WatchUnallocatedStudents());
  }

  final _search = TextEditingController();
  String _query = '';
  DormFilter _filter = DormFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dormitory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Transfer History',
            onPressed: () => context.push('/staff/matron/dorms/history'),
          ),
        ],
      ),
      body: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is MatronError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: semanticColors.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is DormitoriesLoaded || current is MatronLoading,
        builder: (context, state) {
          if (state is! DormitoriesLoaded) {
            return const Center(child: SchoolPulseLoader());
          }

          final all = state.dormitories;
          final dorms = all.where((d) {
            if (_query.isNotEmpty &&
                !d.name.toLowerCase().contains(_query.toLowerCase())) {
              return false;
            }
            final ratio = d.capacity == 0 ? 0.0 : d.occupantCount / d.capacity;
            return switch (_filter) {
              DormFilter.all => true,
              DormFilter.available => d.occupantCount < d.capacity,
              DormFilter.nearlyFull => ratio >= 0.85 && ratio < 1.0,
              DormFilter.full => d.occupantCount >= d.capacity,
              DormFilter.unassignedLeadership =>
                d.roomLeaderName == null || d.dormPrefectName == null,
            };
          }).toList();

          final totalCapacity = all.fold<int>(0, (sum, d) => sum + d.capacity);
          final totalOccupancy = all.fold<int>(
            0,
            (sum, d) => sum + d.occupantCount,
          );

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              DormSearchBar(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                onFilterPressed: () async {
                  final picked = await DormFilterSheet.show(context, _filter);
                  if (picked != null && mounted) {
                    setState(() => _filter = picked);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Expanded(
                    child: DormStatTile(
                      label: 'Total Dormitories',
                      value: '${all.length}',
                      icon: Icons.apartment_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: DormStatTile(
                      label: 'Total Capacity',
                      value: '$totalCapacity',
                      icon: Icons.groups_outlined,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: DormStatTile(
                      label: 'Total Occupancy',
                      value: '$totalOccupancy',
                      icon: Icons.person_outline,
                      color: semanticColors.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: DormStatTile(
                      label: 'Availability',
                      value:
                          '${(totalCapacity - totalOccupancy).clamp(0, totalCapacity)}',
                      icon: Icons.event_available_outlined,
                      color: semanticColors.success,
                    ),
                  ),
                ],
              ),
              if (_filter != DormFilter.all) ...[
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    Chip(
                      label: Text(_filter.label),
                      avatar: Icon(_filter.icon, size: 16),
                      onDeleted: () => setState(() => _filter = DormFilter.all),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.x2l),
              if (dorms.isEmpty)
                EmptyState(
                  icon: Icons.hotel_outlined,
                  title: _filter == DormFilter.all && _query.isEmpty
                      ? 'No Dormitories Yet'
                      : 'No Matches',
                  message: _filter == DormFilter.all && _query.isEmpty
                      ? 'Tap + to add the first dormitory.'
                      : 'No dormitory matches the current search or filter.',
                )
              else
                for (final dorm in dorms)
                  DormitoryCard(
                    name: dorm.name,
                    occupantCount: dorm.occupantCount,
                    capacity: dorm.capacity,
                    roomLeaderName: dorm.roomLeaderName,
                    dormPrefectName: dorm.dormPrefectName,
                    accent: Theme.of(context).colorScheme.primary,
                    onBeds: () =>
                        context.push('/staff/matron/dorms/beds', extra: dorm),
                    onStudents: () => _showAllocationSheet(context, dorm),
                    onLeadership: () => _showLeadershipSheet(context, dorm),
                    onMore: () => _showDormMenu(context, dorm, semanticColors),
                  ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDormForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Overflow menu for the actions that no longer fit on the card face.
  void _showDormMenu(
    BuildContext context,
    Dormitory dorm,
    SemanticColors semanticColors,
  ) {
    final bloc = context.read<MatronBloc>();
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Dormitory'),
              onTap: () {
                Navigator.pop(sheetContext);
                _openDormForm(context, dorm: dorm);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Set Dorm Leadership'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/staff/matron/dorms/leadership', extra: dorm);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transfer History'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/staff/matron/dorms/history');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: semanticColors.error),
              title: Text(
                'Delete',
                style: TextStyle(color: semanticColors.error),
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await confirmActionDialog(
                  context,
                  title: 'Delete Dormitory',
                  message: 'Are you sure you want to delete ${dorm.name}?',
                  isDestructive: true,
                );
                if (confirmed == true) {
                  bloc.add(DeleteDormitoryEvent(dorm.id));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeadershipSheet(BuildContext context, Dormitory dorm) {
    final bloc = context.read<MatronBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: _LeadershipSheet(dorm: dorm),
        );
      },
    );
  }

  void _showAllocationSheet(BuildContext context, Dormitory dorm) {
    final bloc = context.read<MatronBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: _AllocationSheet(dorm: dorm),
        );
      },
    );
  }

  /// Opens the full-page dormitory form and applies the result through the
  /// same add/update events the old dialog used.
  Future<void> _openDormForm(BuildContext context, {Dormitory? dorm}) async {
    final bloc = context.read<MatronBloc>();
    final result = await context.push<DormitoryFormResult>(
      '/staff/matron/dorms/new',
      extra: dorm,
    );
    if (result == null) return;

    if (dorm == null) {
      bloc.add(
        AddDormitoryEvent(
          Dormitory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: result.name,
            capacity: result.capacity,
            occupantCount: 0,
            location: result.location,
          ),
        ),
      );
    } else {
      bloc.add(
        UpdateDormitoryEvent(
          Dormitory(
            id: dorm.id,
            name: result.name,
            capacity: result.capacity,
            occupantCount: dorm.occupantCount,
            roomLeaderId: dorm.roomLeaderId,
            roomLeaderName: dorm.roomLeaderName,
            dormPrefectId: dorm.dormPrefectId,
            dormPrefectName: dorm.dormPrefectName,
            location: result.location,
          ),
        ),
      );
    }
  }
}

class _LeadershipSheet extends StatefulWidget {
  final Dormitory dorm;
  const _LeadershipSheet({required this.dorm});

  @override
  State<_LeadershipSheet> createState() => _LeadershipSheetState();
}

class _LeadershipSheetState extends State<_LeadershipSheet> {
  String? _roomLeaderId;
  String? _dormPrefectId;

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(
      WatchBoardingStudents(dormitoryId: widget.dorm.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: BlocBuilder<MatronBloc, MatronState>(
        buildWhen: (previous, current) => current is BoardingStudentsLoaded,
        builder: (context, state) {
          final students = state is BoardingStudentsLoaded
              ? state.students
              : <BoardingStudent>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dorm Leadership',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SearchablePickerField<BoardingStudent>(
                label: 'Room Leader',
                value: students.where((s) => s.id == _roomLeaderId).firstOrNull,
                items: students,
                labelBuilder: (s) => s.name,
                subtitleBuilder: (s) => s.studentClass,
                onChanged: (s) => setState(() => _roomLeaderId = s.id),
              ),
              const SizedBox(height: 16),
              SearchablePickerField<BoardingStudent>(
                label: 'Dorm Prefect',
                value: students
                    .where((s) => s.id == _dormPrefectId)
                    .firstOrNull,
                items: students,
                labelBuilder: (s) => s.name,
                subtitleBuilder: (s) => s.studentClass,
                onChanged: (s) => setState(() => _dormPrefectId = s.id),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<MatronBloc>().add(
                      SetDormLeadershipEvent(
                        widget.dorm.id,
                        roomLeaderId: _roomLeaderId,
                        dormPrefectId: _dormPrefectId,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AllocationSheet extends StatefulWidget {
  final Dormitory dorm;
  const _AllocationSheet({required this.dorm});

  @override
  State<_AllocationSheet> createState() => _AllocationSheetState();
}

class _AllocationSheetState extends State<_AllocationSheet> {
  String? _selectedStudentId;
  final _bedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchUnallocatedStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronActionSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final students = state is UnallocatedStudentsLoaded
              ? state.students
              : <BoardingStudent>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Allocate to ${widget.dorm.name}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SearchablePickerField<BoardingStudent>(
                label: 'Select Student',
                value: students
                    .where((s) => s.id == _selectedStudentId)
                    .firstOrNull,
                items: students,
                labelBuilder: (s) => s.name,
                subtitleBuilder: (s) => s.studentClass,
                searchHint: 'Search by name or class...',
                onChanged: (s) => setState(() => _selectedStudentId = s.id),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bedController,
                decoration: const InputDecoration(
                  labelText: 'Bed Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedStudentId != null
                      ? () {
                          context.read<MatronBloc>().add(
                            AllocateStudentEvent(
                              _selectedStudentId!,
                              widget.dorm.id,
                              _bedController.text.isEmpty
                                  ? null
                                  : _bedController.text,
                            ),
                          );
                        }
                      : null,
                  child: const Text('Confirm Allocation'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
