import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/services/printer/printer_service.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/visitor_blacklist.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../bloc/visitors_state.dart';
import '../widgets/badge_widget.dart';
import 'visitor_qr_screen.dart';

class VisitorDetailsScreen extends StatelessWidget {
  final Visitor visitor;

  const VisitorDetailsScreen({super.key, required this.visitor});

  void _showBlacklistDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add to Blacklist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to blacklist ${visitor.fullName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for blacklisting',
                hintText: 'e.g., Unauthorized access attempt',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) return;
              
              final blacklist = VisitorBlacklist(
                id: const Uuid().v4(),
                visitorId: visitor.id,
                fullName: visitor.fullName,
                phone: visitor.phone,
                reason: reasonController.text,
                dateAdded: DateTime.now(),
                addedBy: 'Security Lead', // Should get from Auth
              );

              context.read<VisitorsBloc>().add(AddToBlacklistEvent(blacklist));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visitor added to blacklist')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Blacklist', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReissuedBadgeDialog(BuildContext context, Visitor reissued) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Badge Issued'),
        content: SingleChildScrollView(
          child: VisitorBadgeWidget(visitor: reissued, schoolName: 'School Pulse'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
          ElevatedButton(
            onPressed: () async {
              final printerService = sl<PrinterService>();
              final isConnected = await printerService.isConnected();
              if (isConnected) {
                await printerService.printVisitorBadge(reissued);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Print Badge'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitorsBloc, VisitorsState>(
      listenWhen: (previous, current) => current is BadgeReissued,
      listener: (context, state) {
        if (state is BadgeReissued && state.visitor.id == visitor.id) {
          _showReissuedBadgeDialog(context, state.visitor);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Details'),
        actions: [
          if (visitor.status == VisitorStatus.checkedIn)
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VisitorQRScreen(visitor: visitor)),
              ),
              tooltip: 'Show QR Pass',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'blacklist') {
                _showBlacklistDialog(context);
              } else if (value == 'reissue') {
                context.read<VisitorsBloc>().add(ReissueBadgeEvent(visitor.id));
              }
            },
            itemBuilder: (context) => [
              if (visitor.status == VisitorStatus.checkedIn)
                const PopupMenuItem(
                  value: 'reissue',
                  child: Row(
                    children: [
                      Icon(Icons.badge_outlined, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Reissue Badge (Lost)'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'blacklist',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Blacklist Visitor'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildStatusCard(context),
            const SizedBox(height: 24),
            _buildInfoSection(context, 'Visitor Information', [
              _InfoRow(label: 'Phone', value: visitor.phone, icon: Icons.phone),
              if (visitor.nationalId != null)
                _InfoRow(label: 'National ID', value: visitor.nationalId!, icon: Icons.badge),
              if (visitor.company != null)
                _InfoRow(label: 'Company', value: visitor.company!, icon: Icons.business),
              if (visitor.vehicleNumber != null)
                _InfoRow(label: 'Vehicle', value: visitor.vehicleNumber!, icon: Icons.directions_car),
              if (visitor.parkingSlot != null)
                _InfoRow(label: 'Parking Slot', value: visitor.parkingSlot!, icon: Icons.local_parking),
            ]),
            if (visitor.idImageLocalPath != null || visitor.idImageUrl != null) ...[
              const SizedBox(height: 24),
              _buildIdImageSection(context),
            ],
            const SizedBox(height: 24),
            _buildInfoSection(context, 'Visit Details', [
              _InfoRow(label: 'Host', value: visitor.host, icon: Icons.person_pin),
              _InfoRow(label: 'Department', value: visitor.department, icon: Icons.corporate_fare),
              _InfoRow(label: 'Purpose', value: visitor.purpose, icon: Icons.comment),
              if (visitor.gateId != null)
                _InfoRow(label: 'Gate', value: visitor.gateId!, icon: Icons.sensor_door_outlined),
              if (visitor.itemsCarried != null)
                _InfoRow(label: 'Items', value: visitor.itemsCarried!, icon: Icons.inventory_2),
              if (visitor.notes != null)
                _InfoRow(label: 'Notes', value: visitor.notes!, icon: Icons.note),
            ]),
            const SizedBox(height: 24),
            _buildHistorySection(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return BlocBuilder<VisitorsBloc, VisitorsState>(
      builder: (context, state) {
        if (state is! VisitorsLoaded) return const SizedBox.shrink();
        final pastVisits = state.visitors
            .where((v) => v.phone == visitor.phone && v.id != visitor.id)
            .toList()
          ..sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));

        if (pastVisits.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit History (${pastVisits.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: pastVisits.map((v) {
                  final isLast = pastVisits.indexOf(v) == pastVisits.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          v.status == VisitorStatus.checkedIn ? Icons.login : Icons.logout,
                          size: 20,
                          color: v.status == VisitorStatus.checkedIn ? Colors.green : Colors.grey,
                        ),
                        title: Text(v.purpose, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          'Host: ${v.host} • ${DateFormat('MMM dd, yyyy hh:mm a').format(v.arrivalTime)}',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    ImageProvider? imageProvider;
    if (visitor.photoLocalPath != null) {
      final file = File(visitor.photoLocalPath!);
      if (file.existsSync()) {
        imageProvider = FileImage(file);
      }
    }
    
    if (imageProvider == null && visitor.photoUrl != null) {
      imageProvider = NetworkImage(visitor.photoUrl!);
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: imageProvider,
          child: imageProvider == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visitor.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (visitor.isBlacklisted)
                const StatusBadge(label: 'BLACKLISTED', color: Colors.red, icon: Icons.warning),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final isCheckedIn = visitor.status == VisitorStatus.checkedIn;
    return AppCard(
      color: isCheckedIn ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            isCheckedIn ? Icons.login : Icons.logout,
            color: isCheckedIn ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckedIn ? 'Currently Inside' : 'Checked Out',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Arrived: ${DateFormat('hh:mm a, MMM dd').format(visitor.arrivalTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (visitor.departureTime != null)
                  Text(
                    'Departed: ${DateFormat('hh:mm a, MMM dd').format(visitor.departureTime!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdImageSection(BuildContext context) {
    ImageProvider imageProvider;
    if (visitor.idImageLocalPath != null && File(visitor.idImageLocalPath!).existsSync()) {
      imageProvider = FileImage(File(visitor.idImageLocalPath!));
    } else {
      imageProvider = NetworkImage(visitor.idImageUrl!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Document',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showDialog(
            context: context,
            builder: (_) => Dialog(
              child: InteractiveViewer(child: Image(image: imageProvider)),
            ),
          ),
          child: Container(
            height: 120,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<_InfoRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: rows.map((row) {
              final isLast = rows.indexOf(row) == rows.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(row.icon, size: 20),
                    title: Text(row.label, style: Theme.of(context).textTheme.bodySmall),
                    subtitle: Text(row.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final IconData icon;

  _InfoRow({required this.label, required this.value, required this.icon});
}
