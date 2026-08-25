import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import '../../domain/entities/repair.dart';
import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../bloc/stores_assets_state.dart';
import '../widgets/request_repair_dialog.dart';

class RepairListScreen extends StatefulWidget {
  const RepairListScreen({super.key});

  @override
  State<RepairListScreen> createState() => _RepairListScreenState();
}

class _RepairListScreenState extends State<RepairListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StoresAssetsBloc>().add(LoadRepairs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repair Records')),
      body: BlocBuilder<StoresAssetsBloc, StoresAssetsState>(
        builder: (context, state) {
          if (state is StoresAssetsLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          List<RepairRecord> repairs = [];
          if (state is StoresAssetsLoaded) {
            repairs = state.repairs;
          }

          if (repairs.isEmpty) {
            return const Center(child: Text('No repair records found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: repairs.length,
            itemBuilder: (context, index) {
              final repair = repairs[index];
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
                          child: Text(
                            repair.assetName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: repair.status.name,
                          color: _repairStatusColor(repair.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(repair.description),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.format(repair.requestDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (repair.actualCost > 0) ...[
                          const Spacer(),
                          Text(
                            'UGX ${repair.actualCost.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const RequestRepairDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Color _repairStatusColor(RepairStatus status) => switch (status) {
  RepairStatus.pending => Colors.black,
  RepairStatus.approved => Colors.black,
  RepairStatus.inProgress => Colors.black,
  RepairStatus.completed => Colors.black,
  RepairStatus.cancelled => Colors.black,
};
