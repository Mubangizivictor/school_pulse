import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dormitory Management'),
      ),
      body: BlocBuilder<PatronBloc, PatronState>(
        builder: (context, state) {
          if (state is PatronLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DormitoriesLoaded) {
            final dorms = state.dormitories;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dorms.length,
              itemBuilder: (context, index) {
                final dorm = dorms[index];
                return _buildDormCard(context, dorm);
              },
            );
          }

          return const Center(child: Text('No dormitories found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDormCard(BuildContext context, Dormitory dorm) {
    final occupancyRate = dorm.capacity > 0 ? dorm.occupantCount / dorm.capacity : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(
              dorm.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text('Capacity: ${dorm.occupantCount}/${dorm.capacity} Students'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddDormDialog(context, dorm: dorm),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LinearProgressIndicator(
              value: occupancyRate,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancyRate > 0.9 ? Colors.red : Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_pin, color: Colors.indigo),
            title: Text(dorm.roomLeaderName ?? 'No Room Leader Assigned'),
            subtitle: const Text('Room Leader'),
            trailing: TextButton(
              onPressed: () => _showSetLeaderDialog(context, dorm),
              child: const Text('Change'),
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to dorm students list
                },
                child: const Text('View Students'),
              ),
              TextButton(
                onPressed: () => _showDeleteConfirmation(context, dorm.id),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddDormDialog(BuildContext context, {Dormitory? dorm}) {
    final nameController = TextEditingController(text: dorm?.name);
    final capacityController = TextEditingController(text: dorm?.capacity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newDorm = Dormitory(
                id: dorm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                capacity: int.tryParse(capacityController.text) ?? 0,
                occupantCount: dorm?.occupantCount ?? 0,
                roomLeaderId: dorm?.roomLeaderId,
                roomLeaderName: dorm?.roomLeaderName,
              );
              if (dorm == null) {
                context.read<PatronBloc>().add(AddDormitoryEvent(newDorm));
              } else {
                context.read<PatronBloc>().add(UpdateDormitoryEvent(newDorm));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSetLeaderDialog(BuildContext context, Dormitory dorm) {
    // In a real app, this would show a list of students in that dorm
    // For now, it's a simple dialog or just a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student list for selection not implemented yet')),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dormitory'),
        content: const Text('Are you sure you want to delete this dormitory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<PatronBloc>().add(DeleteDormitoryEvent(id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
