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
import 'attendance_detail_screen.dart';
import 'attendance_statistics_screen.dart';

/// Matches the mockup's "Previous Attendances" list - one card per past
/// session grouped by scope/date, with a present/absent/late breakdown line
/// and Export/Share actions surfaced from the detail screen.
class PreviousAttendanceScreen extends StatefulWidget {
  const PreviousAttendanceScreen({super.key});

  @override
  State<PreviousAttendanceScreen> createState() =>
      _PreviousAttendanceScreenState();
}

class _PreviousAttendanceScreenState extends State<PreviousAttendanceScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
        LoadRecordsRequested(schoolId: authState.user.schoolId),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<AttendanceRecord>> _groupBySession(
    List<AttendanceRecord> records,
  ) {
    final grouped = <String, List<AttendanceRecord>>{};
    for (final r in records) {
      final key =
          '${r.scopeName.isEmpty ? r.scopeId : r.scopeName}_${r.date.year}${r.date.month}${r.date.day}';
      grouped.putIfAbsent(key, () => []).add(r);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Previous Attendances'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistics',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AttendanceBloc>(),
                  child: const AttendanceStatisticsScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! RecordsLoaded) return const SizedBox.shrink();

          final query = _searchController.text.trim().toLowerCase();
          final filtered = query.isEmpty
              ? state.records
              : state.records
                    .where(
                      (r) =>
                          r.scopeName.toLowerCase().contains(query) ||
                          r.personName.toLowerCase().contains(query),
                    )
                    .toList();
          final grouped = _groupBySession(filtered);
          final sessions = grouped.entries.toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by class, date, or status',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surfaceContainer(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(
                          'No attendance records yet',
                          style: TextStyle(color: AppColors.textMuted(context)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final records = sessions[index].value;
                          final first = records.first;
                          final present = records
                              .where((r) => r.status == AttendanceStatus.present)
                              .length;
                          final absent = records
                              .where((r) => r.status == AttendanceStatus.absent)
                              .length;
                          final late = records
                              .where((r) => r.status == AttendanceStatus.late)
                              .length;

                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.m),
                            child: ListTile(
                              title: Text(
                                first.scopeName.isEmpty
                                    ? first.scopeId
                                    : first.scopeName,
                              ),
                              subtitle: Text(
                                '${first.date.day}/${first.date.month}/${first.date.year}  '
                                'Present: $present  Absent: $absent  Late: $late',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<AttendanceBloc>(),
                                    child: AttendanceDetailScreen(
                                      records: records,
                                      title: first.scopeName.isEmpty
                                          ? first.scopeId
                                          : first.scopeName,
                                    ),
                                  ),
                                ),
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
