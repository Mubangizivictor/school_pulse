import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/patron/presentation/screens/bed_management_screen.dart';

class DormitoryManagementScreen extends StatefulWidget {
  const DormitoryManagementScreen({super.key});

  @override
  State<DormitoryManagementScreen> createState() => _DormitoryManagementScreenState();
}

class _DormitoryManagementScreenState extends State<DormitoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatronBloc>().add(WatchDormitories());
    context.read<PatronBloc>().add(WatchUnallocatedStudents());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Dormitory Management')),
      body: BlocConsumer<PatronBloc, PatronState>(
        listener: (context, state) {
          if (state is PatronActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is PatronError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: semanticColors.error),
            );
          }
        },
        buildWhen: (previous, current) => current is DormitoriesLoaded || current is PatronLoading,
        builder: (context, state) {
          if (state is DormitoriesLoaded) {
            final dorms = state.dormitories;
            if (dorms.isEmpty) {
              return const EmptyState(
                icon: Icons.hotel_outlined,
                title: 'No Dormitories Yet',
                message: 'Tap + to add the first boys\' dormitory.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dorms.length,
              itemBuilder: (context, index) => _DormCard(dorm: dorms[index]),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDormDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Dormitory'),
      ),
    );
  }

  void _showAddDormDialog(BuildContext context, {Dormitory? dorm}) {
    final bloc = context.read<PatronBloc>();
    final nameController = TextEditingController(text: dorm?.name);
    final capacityController = TextEditingController(text: dorm?.capacity.toString());
    final locationController = TextEditingController(text: dorm?.location);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dorm == null ? 'Add Dormitory' : 'Edit Dormitory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Dormitory Name'),
            ),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Capacity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final newDorm = Dormitory(
                id: dorm?.id ?? '',
                name: nameController.text.trim(),
                capacity: int.tryParse(capacityController.text) ?? 0,
                occupantCount: dorm?.occupantCount ?? 0,
                roomLeaderId: dorm?.roomLeaderId,
                roomLeaderName: dorm?.roomLeaderName,
                dormPrefectId: dorm?.dormPrefectId,
                dormPrefectName: dorm?.dormPrefectName,
                location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
              );
              if (dorm == null) {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                bloc.add(AddDormitoryEvent(
                  Dormitory(
                    id: id,
                    name: newDorm.name,
                    capacity: newDorm.capacity,
                    occupantCount: 0,
                    location: newDorm.location,
                  ),
                ));
              } else {
                bloc.add(UpdateDormitoryEvent(newDorm));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DormCard extends StatelessWidget {
  final Dormitory dorm;
  const _DormCard({required this.dorm});

  @override
  Widget build(BuildContext context) {
    final occupancy = dorm.capacity > 0 ? dorm.occupantCount / dorm.capacity : 0.0;
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dorm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    if (dorm.location != null)
                      Text(dorm.location!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(
                label: '${dorm.occupantCount}/${dorm.capacity}',
                color: dorm.occupantCount >= dorm.capacity ? semanticColors.error : semanticColors.success,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => (context.findAncestorStateOfType<_DormitoryManagementScreenState>())
                    ?._showAddDormDialog(context, dorm: dorm),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: occupancy,
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation(occupancy >= 1.0 ? semanticColors.error : semanticColors.success),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_border, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(child: Text(dorm.roomLeaderName ?? 'No Room Leader', style: Theme.of(context).textTheme.bodySmall)),
              TextButton(
                onPressed: () => _showLeadershipSheet(context, dorm),
                child: const Text('Set Leadership'),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.military_tech_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(child: Text(dorm.dormPrefectName ?? 'No Dorm Prefect', style: Theme.of(context).textTheme.bodySmall)),
            ],
          ),
          const SizedBox(height: 8),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BedManagementScreen(dormitory: dorm)),
                ),
                icon: const Icon(Icons.bed_outlined),
                label: const Text('Beds'),
              ),
              TextButton(
                onPressed: () => _showAllocationSheet(context, dorm),
                child: const Text('Allocate Student'),
              ),
              TextButton(
                onPressed: () async {
                  final confirmed = await confirmActionDialog(
                    context,
                    title: 'Delete Dormitory',
                    message: 'Are you sure you want to delete ${dorm.name}?',
                    isDestructive: true,
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<PatronBloc>().add(DeleteDormitoryEvent(dorm.id));
                  }
                },
                child: Text('Delete', style: TextStyle(color: semanticColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLeadershipSheet(BuildContext context, Dormitory dorm) {
    final bloc = context.read<PatronBloc>();
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
    final bloc = context.read<PatronBloc>();
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
    context.read<PatronBloc>().add(WatchBoardingStudents(dormitoryId: widget.dorm.id));
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
      child: BlocBuilder<PatronBloc, PatronState>(
        buildWhen: (previous, current) => current is BoardingStudentsLoaded,
        builder: (context, state) {
          final students = state is BoardingStudentsLoaded ? state.students : <BoardingStudent>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dorm Leadership', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _roomLeaderId,
                decoration: const InputDecoration(labelText: 'Room Leader', border: OutlineInputBorder()),
                items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _roomLeaderId = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _dormPrefectId,
                decoration: const InputDecoration(labelText: 'Dorm Prefect', border: OutlineInputBorder()),
                items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _dormPrefectId = val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<PatronBloc>().add(SetDormLeadershipEvent(
                          widget.dorm.id,
                          roomLeaderId: _roomLeaderId,
                          dormPrefectId: _dormPrefectId,
                        ));
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
    context.read<PatronBloc>().add(WatchUnallocatedStudents());
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
      child: BlocConsumer<PatronBloc, PatronState>(
        listener: (context, state) {
          if (state is PatronActionSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final students = state is UnallocatedStudentsLoaded ? state.students : <BoardingStudent>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Allocate to ${widget.dorm.name}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Student', border: OutlineInputBorder()),
                items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedStudentId = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bedController,
                decoration: const InputDecoration(labelText: 'Bed Number (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedStudentId != null
                      ? () {
                          context.read<PatronBloc>().add(AllocateStudentEvent(
                                _selectedStudentId!,
                                widget.dorm.id,
                                _bedController.text.isEmpty ? null : _bedController.text,
                              ));
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
