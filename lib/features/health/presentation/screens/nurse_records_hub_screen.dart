import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Nurse Records tab. Matches the attached reference: title/subtitle header
/// with notifications, a search + filter row, a stats strip (visits today /
/// medication due / low stock), the Records list, and a Recent activity
/// list. All figures come from [HealthBloc]'s [HealthDashboardLoaded] state
/// - no mock data.
class NurseRecordsHubScreen extends StatefulWidget {
  const NurseRecordsHubScreen({super.key});

  @override
  State<NurseRecordsHubScreen> createState() => _NurseRecordsHubScreenState();
}

class _NurseRecordsHubScreenState extends State<NurseRecordsHubScreen> {
  static const _card = Colors.black;
  static const _muted = Colors.black;

  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final schoolId = authState.user.schoolId;
      context.read<HealthBloc>().add(FetchHealthDashboardData(schoolId));
      di.sl<GetAllStudents>()(schoolId: schoolId).then((result) {
        if (!mounted) return;
        result.fold((_) {}, (students) => setState(() => _students = students));
      });
    }
  }

  String _studentName(String studentId) {
    final match = _students.where((s) => s.id == studentId).toList();
    return match.isEmpty ? 'Student' : match.first.name;
  }

  String _studentClass(String studentId) {
    final match = _students.where((s) => s.id == studentId).toList();
    return match.isEmpty ? '' : match.first.className;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _Header(),
                const SizedBox(height: 20),
                const _SearchAndFilterRow(),
                const SizedBox(height: 16),
                _StatsStrip(state: state),
                const SizedBox(height: 24),
                Text(
                  'Records',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _RecordsList(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent activity',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/staff/nurse/history'),
                      child: const Text(
                        'View all',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _RecentActivityList(
                  state: state,
                  studentName: _studentName,
                  studentClass: _studentClass,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health records',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find and manage student care records',
                style: TextStyle(
                  color: _NurseRecordsHubScreenState._muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const NotificationBellButton(),
      ],
    );
  }
}

class _SearchAndFilterRow extends StatelessWidget {
  const _SearchAndFilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _NurseRecordsHubScreenState._card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: 'Search student, ID or visit',
                      hintStyle: TextStyle(
                        color: _NurseRecordsHubScreenState._muted,
                        fontSize: 14,
                      ),
                    ),
                    onSubmitted: (query) {
                      if (query.trim().isNotEmpty) {
                        context.push('/staff/nurse/lookup');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: _NurseRecordsHubScreenState._card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'All records',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              Icon(Icons.expand_more, color: Colors.white, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final HealthState state;
  const _StatsStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    var visitsToday = 0;
    var lowStock = 0;
    if (state is HealthDashboardLoaded) {
      final loaded = state as HealthDashboardLoaded;
      visitsToday = loaded.todayVisits.length;
      lowStock = loaded.lowStockItems.length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _NurseRecordsHubScreenState._card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_today_outlined,
              color: Colors.black,
              value: visitsToday,
              label: 'Visits today',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white),
          Expanded(
            child: _StatItem(
              icon: Icons.healing_outlined,
              color: Colors.black,
              value: 0,
              label: 'Medication due',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white),
          Expanded(
            child: _StatItem(
              icon: Icons.warning_amber_rounded,
              color: Colors.black,
              value: lowStock,
              label: 'Low stock',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String label;
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _NurseRecordsHubScreenState._muted,
                  fontSize: 9.5,
                  height: 1.1,
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordsList extends StatelessWidget {
  const _RecordsList();

  @override
  Widget build(BuildContext context) {
    final records = [
      _RecordEntryData(
        title: 'Clinic visits',
        subtitle: 'View consultations and treatment history',
        icon: Icons.medical_services_outlined,
        color: Colors.black,
        onTap: () => context.push('/staff/nurse/visits'),
      ),
      _RecordEntryData(
        title: 'Student health profiles',
        subtitle: 'Allergies, conditions and medical notes',
        icon: Icons.person_outline,
        color: Colors.black,
        onTap: () => context.push('/staff/nurse/lookup'),
      ),
      _RecordEntryData(
        title: 'Medication log',
        subtitle: 'Doses, prescriptions and administration',
        icon: Icons.medication_outlined,
        color: Colors.black,
        onTap: () => context.push('/staff/nurse/inventory'),
      ),
      _RecordEntryData(
        title: 'Clinic inventory',
        subtitle: 'Medicine and supplies',
        icon: Icons.inventory_2_outlined,
        color: Colors.black,
        onTap: () => context.push('/staff/nurse/inventory'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _NurseRecordsHubScreenState._card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++) ...[
            _RecordEntry(data: records[i]),
            if (i != records.length - 1)
              const Divider(
                height: 1,
                color: Colors.white,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _RecordEntryData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RecordEntryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _RecordEntry extends StatelessWidget {
  final _RecordEntryData data;
  const _RecordEntry({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: data.onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: data.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(data.icon, color: data.color, size: 22),
      ),
      title: Text(
        data.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        data.subtitle,
        style: const TextStyle(
          color: _NurseRecordsHubScreenState._muted,
          fontSize: 12.5,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final HealthState state;
  final String Function(String studentId) studentName;
  final String Function(String studentId) studentClass;

  const _RecentActivityList({
    required this.state,
    required this.studentName,
    required this.studentClass,
  });

  @override
  Widget build(BuildContext context) {
    List<ClinicVisit> visits = [];
    if (state is HealthDashboardLoaded) {
      visits = (state as HealthDashboardLoaded).todayVisits;
    }

    if (visits.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _NurseRecordsHubScreenState._card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No recent activity',
          style: TextStyle(color: _NurseRecordsHubScreenState._muted),
        ),
      );
    }

    final recent = visits.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: _NurseRecordsHubScreenState._card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < recent.length; i++) ...[
            _ActivityRow(
              visit: recent[i],
              name: studentName(recent[i].studentId),
              className: studentClass(recent[i].studentId),
            ),
            if (i != recent.length - 1)
              const Divider(
                height: 1,
                color: Colors.white,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ClinicVisit visit;
  final String name;
  final String className;
  const _ActivityRow({
    required this.visit,
    required this.name,
    required this.className,
  });

  static const _avatarColors = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
    final color = _avatarColors[name.hashCode.abs() % _avatarColors.length];
    final time = TimeOfDay.fromDateTime(visit.dateTime).format(context);
    final subtitle = [
      visit.reason,
      if (className.isNotEmpty) className,
    ].join(' • ');

    return ListTile(
      onTap: () => context.push('/staff/nurse/profile/${visit.studentId}'),
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _NurseRecordsHubScreenState._muted,
          fontSize: 12,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: _NurseRecordsHubScreenState._muted,
              fontSize: 11,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}
