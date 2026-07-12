import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/data/models/visitor.dart';
import 'package:school_pulse/features/admin/data/repositories/visitor_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

class VisitorLogScreen extends StatefulWidget {
  const VisitorLogScreen({super.key});

  @override
  State<VisitorLogScreen> createState() => _VisitorLogScreenState();
}

class _VisitorLogScreenState extends State<VisitorLogScreen> {
  final _repository = di.sl<VisitorRepository>();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Visitor Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVisitorDialog(context),
            tooltip: 'Log New Visitor',
          ),
        ],
      ),
      body: StreamBuilder<List<Visitor>>(
        stream: _repository.getVisitors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Couldn\'t load the visitor log',
              message: 'Something went wrong on our end. Pull to refresh or check back shortly.',
            );
          }
          final visitors = snapshot.data ?? const [];
          final filtered = _query.isEmpty
              ? visitors
              : visitors
                  .where((v) =>
                      v.name.toLowerCase().contains(_query) ||
                      v.purpose.toLowerCase().contains(_query))
                  .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                _buildVisitorStats(context, visitors),
                const SizedBox(height: 24),
                _buildVisitorList(context, filtered),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisitorStats(BuildContext context, List<Visitor> visitors) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final now = DateTime.now();
    final active = visitors.where((v) => v.checkOut == null).toList();
    final today = visitors.where((v) =>
        v.checkIn.year == now.year && v.checkIn.month == now.month && v.checkIn.day == now.day);
    final completed = visitors.where((v) => v.checkOut != null);
    final avgStayMinutes = completed.isEmpty
        ? 0
        : completed.map((v) => v.checkOut!.difference(v.checkIn).inMinutes).reduce((a, b) => a + b) ~/
            completed.length;

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          DashboardStatCard(title: 'Active', value: active.length.toDouble(), icon: Icons.meeting_room, color: Colors.blue, trend: 'Inside'),
          DashboardStatCard(title: 'Total Today', value: today.length.toDouble(), icon: Icons.people_outline, color: Colors.green, trend: 'Logged'),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: DashboardStatCard(title: 'Active Visitors', value: active.length.toDouble(), icon: Icons.meeting_room, color: Colors.blue, trend: 'Currently on premises')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'Total Today', value: today.length.toDouble(), icon: Icons.people_outline, color: Colors.green, trend: 'Logged today')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'Avg. Stay', value: avgStayMinutes.toDouble(), suffix: ' min', icon: Icons.timer, color: Colors.orange, trend: 'Completed visits')),
      ],
    );
  }

  Widget _buildVisitorList(BuildContext context, List<Visitor> visitors) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Visitor History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Visitor Entry/Exit History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                          decoration: const InputDecoration(
                            hintText: 'Search by name or purpose...',
                            prefixIcon: Icon(Icons.search),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1),
          if (visitors.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: EmptyState(
                icon: Icons.meeting_room_outlined,
                title: 'No visitors logged',
                message: 'Tap the + button to log a new visitor entry.',
              ),
            )
          else if (isMobile)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visitors.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final v = visitors[index];
                final isActive = v.checkOut == null;
                return ListTile(
                  title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${v.purpose} • In: ${DateFormat('hh:mm a').format(v.checkIn)}'),
                  trailing: isActive
                      ? TextButton(onPressed: () => _repository.checkOutVisitor(v.id), child: const Text('Out'))
                      : Icon(Icons.check_circle, color: Theme.of(context).extension<SemanticColors>()!.success, size: 20),
                );
              },
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Visitor Name')),
                    DataColumn(label: Text('Purpose')),
                    DataColumn(label: Text('In Time')),
                    DataColumn(label: Text('Out Time')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: visitors.map((v) {
                    final isActive = v.checkOut == null;
                    return DataRow(cells: [
                      DataCell(Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(v.purpose)),
                      DataCell(Text(DateFormat('hh:mm a').format(v.checkIn))),
                      DataCell(isActive
                          ? StatusBadge(label: 'On Premises', color: Theme.of(context).extension<SemanticColors>()!.info)
                          : Text(DateFormat('hh:mm a').format(v.checkOut!))),
                      DataCell(Text(v.contact)),
                      DataCell(
                        isActive
                            ? TextButton(onPressed: () => _repository.checkOutVisitor(v.id), child: const Text('Check Out'))
                            : Icon(Icons.check_circle, color: Theme.of(context).extension<SemanticColors>()!.success, size: 20),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddVisitorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final purposeController = TextEditingController();
    final hostId = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Visitor Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact Number'),
            ),
            const SizedBox(height: 16),
            TextField(controller: purposeController, decoration: const InputDecoration(labelText: 'Purpose of Visit')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await _repository.addVisitor(Visitor(
                id: '',
                name: nameController.text.trim(),
                purpose: purposeController.text.trim().isEmpty ? 'General visit' : purposeController.text.trim(),
                contact: contactController.text.trim(),
                checkIn: DateTime.now(),
                signedInBy: hostId,
              ));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Log Entry'),
          ),
        ],
      ),
    );
  }
}
