import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

/// Same boarding-scoped reasoning as manual_attendance_screen.dart: this
/// screen's own filter labels ("Dormitory", "Session") identify it as a
/// boarding attendance report despite the shared /staff/attendance route.
class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  String _searchQuery = '';
  final DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    context.read<MatronBloc>().add(
      WatchAttendance(schoolId: schoolId, date: _date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          title: const Text('Attendance Report'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Present'),
              Tab(text: 'Absent'),
            ],
          ),
        ),
        body: BlocBuilder<MatronBloc, MatronState>(
          builder: (context, state) {
            final records = state is AttendanceLoaded
                ? state.attendance
                : const <BoardingAttendance>[];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: AppSearchField(
                    hintText: 'Search students...',
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(context, records, semanticColors),
                      _buildList(
                        context,
                        records.where((r) => r.status != 'Absent').toList(),
                        semanticColors,
                      ),
                      _buildList(
                        context,
                        records.where((r) => r.status == 'Absent').toList(),
                        semanticColors,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    border: Border(
                      top: BorderSide(color: AppColors.border(context)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: PrimaryButton(
                      label: 'Export Detailed Report',
                      icon: Icons.ios_share,
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<BoardingAttendance> records,
    SemanticColors colors,
  ) {
    final filtered = records
        .where(
          (r) =>
              r.studentName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        message: 'Try adjusting your search or filters.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final record = filtered[index];
        final bool isPresent = record.status != 'Absent';

        return FadeInSlide(
          delay: Duration(milliseconds: index * 30),
          child: AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                AvatarInitials(name: record.studentName, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        record.dormitoryId,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(
                      label: record.status,
                      color: isPresent ? colors.success : colors.error,
                      icon: isPresent ? Icons.check_circle : Icons.cancel,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(record.date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
