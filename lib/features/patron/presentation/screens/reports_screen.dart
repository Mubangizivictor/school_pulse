import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Dormitory> _dormitories = const [];
  List<DisciplineIncident> _discipline = const [];
  List<WelfareRecord> _welfare = const [];
  List<LeaveRequest> _leave = const [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : '';
    context.read<PatronBloc>().add(WatchDormitories());
    context.read<PatronBloc>().add(const WatchDisciplineIncidents());
    context.read<PatronBloc>().add(WatchWelfareRecords(schoolId: schoolId));
    context.read<PatronBloc>().add(const WatchLeaveRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boarding Reports')),
      body: BlocListener<PatronBloc, PatronState>(
        listener: (context, state) {
          setState(() {
            if (state is DormitoriesLoaded) _dormitories = state.dormitories;
            if (state is DisciplineIncidentsLoaded) _discipline = state.incidents;
            if (state is WelfareRecordsLoaded) _welfare = state.records;
            if (state is LeaveRequestsLoaded) _leave = state.requests;
          });
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionHeader(title: 'Dormitory Occupancy'),
            const SizedBox(height: 12),
            _BarChartCard(
              data: {for (final d in _dormitories) d.name: d.occupantCount.toDouble()},
              maxValue: _dormitories.isEmpty
                  ? 10
                  : _dormitories.map((d) => d.capacity).reduce((a, b) => a > b ? a : b).toDouble(),
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Discipline Cases by Category'),
            const SizedBox(height: 12),
            _BarChartCard(data: _countBy(_discipline.map((d) => d.category)), color: Colors.red),
            const SizedBox(height: 24),
            SectionHeader(title: 'Welfare Records by Category'),
            const SizedBox(height: 12),
            _BarChartCard(data: _countBy(_welfare.map((w) => w.category)), color: Colors.pink),
            const SizedBox(height: 24),
            SectionHeader(title: 'Leave Requests by Status'),
            const SizedBox(height: 12),
            _BarChartCard(data: _countBy(_leave.map((l) => l.isOverdue ? 'Overdue' : l.status)), color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Map<String, double> _countBy(Iterable<String> values) {
    final map = <String, double>{};
    for (final v in values) {
      map[v] = (map[v] ?? 0) + 1;
    }
    return map;
  }
}

class _BarChartCard extends StatelessWidget {
  final Map<String, double> data;
  final Color color;
  final double? maxValue;

  const _BarChartCard({required this.data, required this.color, this.maxValue});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    if (entries.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No data yet')),
      );
    }
    final maxY = maxValue ?? (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY <= 0 ? 1 : maxY,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          entries[index].key,
                          style: const TextStyle(fontSize: 9),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  reservedSize: 36,
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(entries.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entries[index].value,
                    color: color,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
