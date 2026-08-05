import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/visitors/presentation/pages/emergency_roll_call_page.dart';
import 'package:school_pulse/features/visitors/presentation/pages/package_delivery_page.dart';
import 'package:school_pulse/features/visitors/presentation/pages/scheduled_visits_page.dart';
import 'package:school_pulse/features/visitors/presentation/pages/student_pickup_page.dart';
import 'package:school_pulse/features/visitors/presentation/pages/printer/printer_setup_page.dart';
import 'package:school_pulse/features/visitors/presentation/pages/visitor_history_page.dart';
import 'package:school_pulse/features/visitors/presentation/pages/parking_management_page.dart';
import '../../domain/entities/visitor.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../bloc/visitors_state.dart';

class VisitorDashboardScreen extends StatefulWidget {
  const VisitorDashboardScreen({super.key});

  @override
  State<VisitorDashboardScreen> createState() => _VisitorDashboardScreenState();
}

class _VisitorDashboardScreenState extends State<VisitorDashboardScreen> {
  final _searchController = TextEditingController();
  String? _gateFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<VisitorsBloc>().add(LoadVisitors(authState.user.schoolId));
        context.read<VisitorsBloc>().add(
          WatchVisitorsList(authState.user.schoolId),
        );
        context.read<VisitorsBloc>().add(
          LoadPreApprovedVisitors(authState.user.schoolId),
        );
      }
    });
  }

  void _exportData(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exporting logs to Google Sheets...')),
      );
      context.read<VisitorsBloc>().add(
        ExportVisitorsEvent(
          authState.user.schoolId,
          authState.user.schoolName ?? 'School Pulse',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: Colors.red),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyRollCallPage()),
            ),
            tooltip: 'Emergency Roll-Call',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () =>
                context.read<VisitorsBloc>().add(SyncPendingVisitors()),
            tooltip: 'Sync Pending',
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              switch (value) {
                case 'scheduled':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScheduledVisitsPage(),
                    ),
                  );
                  break;
                case 'packages':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PackageDeliveryPage(),
                    ),
                  );
                  break;
                case 'pickup':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentPickupPage(),
                    ),
                  );
                  break;
                case 'parking':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParkingManagementPage(),
                    ),
                  );
                  break;
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VisitorHistoryPage(),
                    ),
                  );
                  break;
                case 'printer':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrinterSetupPage()),
                  );
                  break;
                case 'export':
                  _exportData(context);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'scheduled',
                child: ListTile(
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text('Scheduled Visits'),
                ),
              ),
              PopupMenuItem(
                value: 'packages',
                child: ListTile(
                  leading: Icon(Icons.inventory_2_outlined),
                  title: Text('Packages'),
                ),
              ),
              PopupMenuItem(
                value: 'pickup',
                child: ListTile(
                  leading: Icon(Icons.no_accounts_outlined),
                  title: Text('Student Pickup'),
                ),
              ),
              PopupMenuItem(
                value: 'parking',
                child: ListTile(
                  leading: Icon(Icons.local_parking_outlined),
                  title: Text('Vehicle & Parking'),
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Complete History'),
                ),
              ),
              PopupMenuItem(
                value: 'printer',
                child: ListTile(
                  leading: Icon(Icons.print_outlined),
                  title: Text('Printer Setup'),
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.file_download_outlined),
                  title: Text('Export Logs'),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/staff/security/visitors/scan'),
            tooltip: 'Scan QR to Check-out',
          ),
        ],
      ),
      body: BlocListener<VisitorsBloc, VisitorsState>(
        listener: (context, state) {
          if (state is VisitorsExporting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exporting logs to Google Sheets...'),
              ),
            );
          } else if (state is VisitorsExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is VisitorsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<VisitorsBloc, VisitorsState>(
          builder: (context, state) {
            if (state is VisitorsLoading || state is VisitorsExporting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VisitorsLoaded || state is VisitorsExportSuccess) {
              final loadedState = state is VisitorsLoaded
                  ? state
                  : (context.read<VisitorsBloc>().state as VisitorsLoaded);

              return RefreshIndicator(
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<VisitorsBloc>().add(
                      LoadVisitors(authState.user.schoolId),
                    );
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickStats(loadedState),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildGateFilter(),
                      const SizedBox(height: 20),
                      _buildVisitorList(_applyGateFilter(loadedState.visitors)),
                    ],
                  ),
                ),
              );
            }

            if (state is VisitorsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context.read<VisitorsBloc>().add(
                            LoadVisitors(authState.user.schoolId),
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No visitors found'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/staff/security/visitors/new'),
        label: const Text('New Visitor'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickStats(VisitorsLoaded state) {
    final active = state.activeVisitors.length;
    final overstayed = state.overstayedVisitors.length;
    final today = state.visitors.where((v) {
      final now = DateTime.now();
      return v.arrivalTime.year == now.year &&
          v.arrivalTime.month == now.month &&
          v.arrivalTime.day == now.day;
    }).length;

    return Column(
      children: [
        if (overstayed > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AlertBanner(
              title: 'Overstay Alert',
              message:
                  '$overstayed visitors have exceeded their expected departure time.',
              color: Colors.orange,
              icon: Icons.timer_off,
            ),
          ),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                title: 'Inside',
                value: active.toDouble(),
                icon: Icons.meeting_room,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                title: 'Overstayed',
                value: overstayed.toDouble(),
                icon: Icons.history,
                color: overstayed > 0 ? Colors.orange : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                title: 'Today',
                value: today.toDouble(),
                icon: Icons.people,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search visitors...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: (query) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.read<VisitorsBloc>().add(
            SearchVisitorsEvent(authState.user.schoolId, query),
          );
        }
      },
    );
  }

  List<Visitor> _applyGateFilter(List<Visitor> visitors) {
    if (_gateFilter == null) return visitors;
    return visitors.where((v) => v.gateId == _gateFilter).toList();
  }

  Widget _buildGateFilter() {
    final configGates = context.watch<ThemeProvider>().config?.visitorGates;
    final gates = (configGates != null && configGates.isNotEmpty)
        ? configGates
        : const ['Main Gate'];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All Gates'),
              selected: _gateFilter == null,
              onSelected: (_) => setState(() => _gateFilter = null),
            ),
          ),
          ...gates.map(
            (gate) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(gate),
                selected: _gateFilter == gate,
                onSelected: (_) => setState(
                  () => _gateFilter = _gateFilter == gate ? null : gate,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorList(List<Visitor> visitors) {
    if (visitors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('No visitors matching your criteria'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visitors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return AppCard(
          onTap: () => context.push(
            '/staff/security/visitors/details/${visitor.id}',
            extra: visitor,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: visitor.status == VisitorStatus.checkedIn
                  ? Colors.green
                  : Colors.grey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              visitor.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${visitor.purpose} • ${visitor.host}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('hh:mm a').format(visitor.arrivalTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (!visitor.isSynced)
                  const Icon(Icons.cloud_off, size: 16, color: Colors.orange),
              ],
            ),
          ),
        );
      },
    );
  }
}
