import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/inventory/domain/entities/maintenance.dart';
import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../bloc/stores_assets_state.dart';
import '../widgets/schedule_maintenance_dialog.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StoresAssetsBloc>().add(LoadMaintenanceSchedule());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Schedule')),
      body: BlocBuilder<StoresAssetsBloc, StoresAssetsState>(
        builder: (context, state) {
          if (state is StoresAssetsLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          List<MaintenanceRecord> schedule = [];
          if (state is StoresAssetsLoaded) {
            schedule = state.maintenanceSchedule;
          }

          if (schedule.isEmpty) {
            return const Center(child: Text('No maintenance scheduled.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final record = schedule[index];
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
                            record.assetName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: record.status.name,
                          color: _maintenanceStatusColor(record.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(record.description),
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
                          DateFormatter.format(record.scheduledDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          record.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
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
            builder: (context) => const ScheduleMaintenanceDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Color _maintenanceStatusColor(MaintenanceStatus status) => switch (status) {
  MaintenanceStatus.scheduled => Colors.black,
  MaintenanceStatus.inProgress => Colors.black,
  MaintenanceStatus.completed => Colors.black,
  MaintenanceStatus.cancelled => Colors.black,
};
