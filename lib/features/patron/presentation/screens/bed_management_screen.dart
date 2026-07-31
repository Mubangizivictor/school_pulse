import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

class BedManagementScreen extends StatefulWidget {
  final Dormitory dormitory;
  const BedManagementScreen({super.key, required this.dormitory});

  @override
  State<BedManagementScreen> createState() => _BedManagementScreenState();
}

class _BedManagementScreenState extends State<BedManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatronBloc>().add(WatchBeds(widget.dormitory.id));
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Patron';
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dormitory.name} Beds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Transfer History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _TransferHistoryScreen()),
            ),
          ),
        ],
      ),
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
        buildWhen: (previous, current) => current is BedsLoaded || current is PatronLoading,
        builder: (context, state) {
          if (state is! BedsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.beds.isEmpty) {
            return const EmptyState(
              icon: Icons.bed_outlined,
              title: 'No Beds Registered',
              message: 'Tap + to add beds to this dormitory.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: state.beds.length,
            itemBuilder: (context, index) => _BedTile(
              bed: state.beds[index],
              dormitory: widget.dormitory,
              currentUserName: _currentUserName(context),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBedDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBedDialog(BuildContext context) {
    final bloc = context.read<PatronBloc>();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Bed'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Bed Number'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                bloc.add(AddBedEvent(widget.dormitory.id, controller.text.trim()));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _BedTile extends StatelessWidget {
  final Bed bed;
  final Dormitory dormitory;
  final String currentUserName;

  const _BedTile({required this.bed, required this.dormitory, required this.currentUserName});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final color = bed.occupied ? semanticColors.error : semanticColors.success;

    return AppCard(
      padding: const EdgeInsets.all(8),
      onTap: () => _showBedActions(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bed_outlined, color: color, size: 28),
          const SizedBox(height: 6),
          Text(bed.bedNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (bed.occupied)
            Text(
              bed.studentName ?? 'Occupied',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            )
          else
            Text('Vacant', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }

  void _showBedActions(BuildContext context) {
    final bloc = context.read<PatronBloc>();
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Assign / Transfer Student Here'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAssignDialog(context, bloc);
                },
              ),
              if (bed.occupied)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove Bed'),
                  onTap: () => Navigator.pop(sheetContext),
                )
              else
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove Bed'),
                  onTap: () {
                    bloc.add(RemoveBedEvent(dormitory.id, bed.id));
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAssignDialog(BuildContext context, PatronBloc bloc) {
    final studentIdController = TextEditingController();
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Assign / Transfer Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                helperText: 'From the Dormitory screen\'s allocation flow for new boarders; use this for moving an already-allocated student.',
              ),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (studentIdController.text.trim().isNotEmpty) {
                bloc.add(TransferStudentEvent(
                  studentId: studentIdController.text.trim(),
                  toDormitoryId: dormitory.id,
                  toBedNumber: bed.bedNumber,
                  transferredBy: currentUserName,
                  reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
                ));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _TransferHistoryScreen extends StatefulWidget {
  const _TransferHistoryScreen();

  @override
  State<_TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<_TransferHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatronBloc>().add(const WatchTransferHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer History')),
      body: BlocBuilder<PatronBloc, PatronState>(
        buildWhen: (previous, current) => current is TransferHistoryLoaded,
        builder: (context, state) {
          if (state is! TransferHistoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.transfers.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'No Transfers Yet',
              message: 'Bed and dorm transfers will be logged here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.transfers.length,
            itemBuilder: (context, index) {
              final t = state.transfers[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(t.studentName),
                  subtitle: Text(
                    '${t.fromDormitoryName ?? 'Unassigned'} -> ${t.toDormitoryName}'
                    '${t.toBedNumber != null ? ' (Bed ${t.toBedNumber})' : ''}',
                  ),
                  trailing: Text(DateFormat('MMM d').format(t.date), style: Theme.of(context).textTheme.labelSmall),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
