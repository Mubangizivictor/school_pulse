import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/attendance_summary/domain/attendance_summary.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

class _RollCallEntry {
  final String title;
  final DateTime date;
  final AttendanceSummary summary;

  const _RollCallEntry({
    required this.title,
    required this.date,
    required this.summary,
  });
}

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    // Last 7 days, one WatchAttendance call per day - the bloc/repository
    // only support a single-date query, so history is built by requesting
    // each day and letting _AttendanceUpdated accumulate.
    for (var i = 0; i < 7; i++) {
      context.read<MatronBloc>().add(
        WatchAttendance(
          schoolId: schoolId,
          date: DateTime.now().subtract(Duration(days: i)),
        ),
      );
    }
  }

  List<_RollCallEntry> _groupByRollCall(List<BoardingAttendance> records) {
    final grouped = <String, List<BoardingAttendance>>{};
    for (final r in records) {
      final dayKey = '${r.date.year}-${r.date.month}-${r.date.day}';
      final key = '${r.dormitoryId}|${r.type}|$dayKey';
      (grouped[key] ??= []).add(r);
    }
    return grouped.values.map((group) {
      final first = group.first;
      final summary = AttendanceRateCalculator.summarize(
        group.map((r) => classifyBoardingStatus(r.status)),
      );
      return _RollCallEntry(
        title: '${first.dormitoryId} — ${first.type}',
        date: first.date,
        summary: summary,
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Attendance History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilter(context, 'Date Range', 'Last 7 Days'),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: _buildFilter(context, 'Category', 'Boarding'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                AppSearchField(
                  hintText: 'Search history...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<MatronBloc, MatronState>(
              builder: (context, state) {
                final records = state is AttendanceLoaded
                    ? state.attendance
                    : const <BoardingAttendance>[];
                final history = _groupByRollCall(records)
                    .where(
                      (entry) => entry.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (history.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history,
                    title: 'No history found',
                    message: 'Try adjusting your search or filters.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: index * 50),
                      child: _HistoryCard(entry: entry, colors: semanticColors),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final _RollCallEntry entry;
  final SemanticColors colors;

  const _HistoryCard({required this.entry, required this.colors});

  @override
  Widget build(BuildContext context) {
    final rate = entry.summary.ratePercent;
    final bool isPerfect = rate == 100.0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/staff/attendance/summary'),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPerfect ? colors.success : colors.warning),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPerfect ? Icons.verified_user : Icons.pending_actions,
                  color: isPerfect ? colors.success : colors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      DateFormat('d/M/yyyy • h:mm a').format(entry.date),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attendance Rate',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          rate == null ? '—' : '${rate.round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isPerfect ? colors.success : colors.warning,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: rate == null ? 0 : rate / 100,
                        backgroundColor: AppColors.surfaceElevated(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPerfect ? colors.success : colors.warning,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '${entry.summary.present}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'of ${entry.summary.totalMarked}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
