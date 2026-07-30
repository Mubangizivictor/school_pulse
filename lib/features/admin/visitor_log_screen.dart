import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/data/models/visitor.dart';
import 'package:school_pulse/features/admin/data/repositories/visitor_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
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
  
  // Filtering state
  int? _selectedYear;
  int? _selectedMonth; // 1-12, or null for entire year
  bool _showTodayOnly = true;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

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
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter by Period',
          ),
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
          
          final now = DateTime.now();
          final filteredByDate = visitors.where((v) {
            if (_showTodayOnly) {
              return v.checkIn.year == now.year && 
                     v.checkIn.month == now.month && 
                     v.checkIn.day == now.day;
            }
            
            bool matchesYear = _selectedYear == null || v.checkIn.year == _selectedYear;
            bool matchesMonth = _selectedMonth == null || v.checkIn.month == _selectedMonth;
            
            return matchesYear && matchesMonth;
          }).toList();

          final filtered = _query.isEmpty
              ? filteredByDate
              : filteredByDate
                  .where((v) =>
                      v.name.toLowerCase().contains(_query) ||
                      v.purpose.toLowerCase().contains(_query))
                  .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                _buildActiveFilterChip(context),
                const SizedBox(height: 12),
                _buildVisitorStats(context, filteredByDate),
                const SizedBox(height: 24),
                _buildVisitorTrafficChart(context, filteredByDate),
                const SizedBox(height: 24),
                _buildVisitorList(context, filtered),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterChip(BuildContext context) {
    String label = '';
    if (_showTodayOnly) {
      label = 'Showing: Today';
    } else {
      final monthName = _selectedMonth != null ? DateFormat('MMMM').format(DateTime(2000, _selectedMonth!)) : 'All Months';
      label = 'Showing: $monthName ${_selectedYear ?? ""}';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: InputChip(
        avatar: const Icon(Icons.filter_list, size: 16),
        label: Text(label),
        onPressed: () => _showFilterDialog(context),
        onDeleted: _showTodayOnly ? null : () {
          setState(() {
            _showTodayOnly = true;
          });
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int? tempYear = _selectedYear;
        int? tempMonth = _selectedMonth;
        bool tempToday = _showTodayOnly;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Visitors'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Today Only'),
                    value: tempToday,
                    onChanged: (val) {
                      setDialogState(() {
                        tempToday = val;
                      });
                    },
                  ),
                  if (!tempToday) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Year'),
                      initialValue: tempYear,
                      items: List.generate(5, (i) => DateTime.now().year - i).map((y) {
                        return DropdownMenuItem(value: y, child: Text(y.toString()));
                      }).toList(),
                      onChanged: (y) => setDialogState(() => tempYear = y),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      decoration: const InputDecoration(labelText: 'Month'),
                      initialValue: tempMonth,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Months')),
                        ...List.generate(12, (i) => i + 1).map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(DateFormat('MMMM').format(DateTime(2000, m))),
                          );
                        }),
                      ],
                      onChanged: (m) => setDialogState(() => tempMonth = m),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _showTodayOnly = tempToday;
                      _selectedYear = tempYear;
                      _selectedMonth = tempMonth;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filter'),
                ),
              ],
            );
          },
        );
      },
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
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: 'Active',
                  value: active.length.toDouble(),
                  icon: Icons.meeting_room,
                  color: Colors.blue,
                  trend: 'Inside',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DashboardStatCard(
                  title: 'Total Today',
                  value: today.length.toDouble(),
                  icon: Icons.people_outline,
                  color: Colors.green,
                  trend: 'Logged',
                ),
              ),
            ],
          ),
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
                      AppSearchField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Visitor Entry/Exit History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(
                        width: 300,
                        child: AppSearchField(
                          controller: _searchController,
                          hintText: 'Search by name or purpose...',
                          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
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

  Widget _buildVisitorTrafficChart(BuildContext context, List<Visitor> visitors) {
    final now = DateTime.now();
    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = {for (final label in weekdayLabels) label: 0.0};

    for (final v in visitors) {
      final checkInDay = DateTime(v.checkIn.year, v.checkIn.month, v.checkIn.day);
      final daysAgo = DateTime(now.year, now.month, now.day).difference(checkInDay).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        final label = weekdayLabels[v.checkIn.weekday - 1];
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    final maxCount = counts.values.fold<double>(0, (a, b) => a > b ? a : b);
    return PerformanceBarChart(
      title: 'Visitor Traffic (Last 7 Days)',
      color: Colors.blue,
      data: counts,
      maxValue: maxCount == 0 ? 1 : maxCount,
      showPercentSign: false,
    );
  }

  void _showAddVisitorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final purposeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    
    final hostId = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('New Visitor Entry'),
            content: SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Check-in Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        if (!dialogContext.mounted) return;
                        final time = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setDialogState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
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
                    checkIn: selectedDate,
                    signedInBy: hostId,
                  ));
                  di.sl<AuditRepository>().logAction(
                    title: 'Visitor Checked In',
                    description: '${nameController.text.trim()} - ${purposeController.text.trim().isEmpty ? 'General visit' : purposeController.text.trim()}.',
                    iconName: 'inventory_2',
                    colorHex: 'FF009688',
                    userId: hostId.isEmpty ? null : hostId,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                },
                child: const Text('Log Entry'),
              ),
            ],
          );
        },
      ),
    );
  }
}
