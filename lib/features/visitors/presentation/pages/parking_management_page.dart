import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_state.dart';

/// Vehicle & parking overview: shows every currently checked-in visitor who
/// arrived with a vehicle, and which parking slot (if any) they occupy.
class ParkingManagementPage extends StatelessWidget {
  const ParkingManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle & Parking')),
      body: BlocBuilder<VisitorsBloc, VisitorsState>(
        builder: (context, state) {
          if (state is VisitorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! VisitorsLoaded) {
            return const Center(child: Text('Unable to load parking data'));
          }

          final parked =
              state.activeVisitors
                  .where((v) => (v.vehicleNumber?.isNotEmpty ?? false))
                  .toList()
                ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

          final occupiedSlots = parked
              .where((v) => v.parkingSlot?.isNotEmpty ?? false)
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Vehicles On-site',
                        value: parked.length.toDouble(),
                        icon: Icons.directions_car,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Slots Assigned',
                        value: occupiedSlots.toDouble(),
                        icon: Icons.local_parking,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: parked.isEmpty
                    ? const Center(
                        child: Text('No vehicles currently on campus'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: parked.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final visitor = parked[index];
                          return AppCard(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.directions_car),
                              ),
                              title: Text(
                                visitor.vehicleNumber!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${visitor.fullName} • Host: ${visitor.host}\n'
                                'Arrived: ${DateFormat('hh:mm a').format(visitor.arrivalTime)}'
                                '${visitor.gateId != null ? ' • Gate: ${visitor.gateId}' : ''}',
                              ),
                              isThreeLine: true,
                              trailing: visitor.parkingSlot?.isNotEmpty ?? false
                                  ? StatusBadge(
                                      label: visitor.parkingSlot!,
                                      color: Colors.teal,
                                      icon: Icons.local_parking,
                                    )
                                  : const StatusBadge(
                                      label: 'UNASSIGNED',
                                      color: Colors.orange,
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
