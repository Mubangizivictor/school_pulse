import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

/// Matches the mockup's "Attendance Statistics" screen - date range filter,
/// class/stream/status dropdowns, stat cards, and a per-scope breakdown
/// (the mockup's "Top Classes" list generalizes to "Top Scopes" here since
/// this screen serves every category, not just Students).
class AttendanceStatisticsScreen extends StatefulWidget {
  const AttendanceStatisticsScreen({super.key});

  @override
  State<AttendanceStatisticsScreen> createState() =>
      _AttendanceStatisticsScreenState();
}

class _AttendanceStatisticsScreenState
    extends State<AttendanceStatisticsScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
        LoadRecordsRequested(
          schoolId: authState.user.schoolId,
          operatorUser: authState.user,
          from: _from,
          to: _to,
        ),
      );
    }
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Attendance Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          final records = state is RecordsLoaded
              ? state.records
              : <AttendanceRecord>[];

          final total = records.length;
          final present = records
              .where((r) => r.status == AttendanceStatus.present)
              .length;
          final absent = records
              .where((r) => r.status == AttendanceStatus.absent)
              .length;
          final late = records
              .where((r) => r.status == AttendanceStatus.late)
              .length;
          final presentPct = total == 0
              ? '0.0'
              : (present / total * 100).toStringAsFixed(1);
          final absentPct = total == 0
              ? '0.0'
              : (absent / total * 100).toStringAsFixed(1);
          final latePct = total == 0
              ? '0.0'
              : (late / total * 100).toStringAsFixed(1);

          final byScope = <String, List<AttendanceRecord>>{};
          for (final r in records) {
            final key = r.scopeName.isEmpty ? r.scopeId : r.scopeName;
            byScope.putIfAbsent(key, () => []).add(r);
          }
          final topScopes = byScope.entries.toList()
            ..sort((a, b) {
              double rate(List<AttendanceRecord> recs) => recs.isEmpty
                  ? 0
                  : recs.where((r) => r.status == AttendanceStatus.present).length /
                        recs.length;
              return rate(b.value).compareTo(rate(a.value));
            });

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(
                    '${_from.day}/${_from.month}/${_from.year} - '
                    '${_to.day}/${_to.month}/${_to.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickRange,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Records',
                      value: '$total',
                      color: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _StatCard(
                      label: 'Present',
                      value: '$present ($presentPct%)',
                      color: AppColors.success(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Absent',
                      value: '$absent ($absentPct%)',
                      color: AppColors.danger(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _StatCard(
                      label: 'Late',
                      value: '$late ($latePct%)',
                      color: AppColors.warning(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Top Classes / Scopes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              ...topScopes.take(10).map((entry) {
                final recs = entry.value;
                final rate = recs.isEmpty
                    ? 0.0
                    : recs
                              .where((r) => r.status == AttendanceStatus.present)
                              .length /
                          recs.length *
                          100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        '${rate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: AppColors.success(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
