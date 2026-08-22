import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/notifications/data/repositories/staff_alerts_repository.dart';
import 'package:school_pulse/features/notifications/data/models/staff_alert.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Nurse More tab. Matches the attached reference: title/subtitle header
/// with a nurse avatar, a search field, and sectioned rows (Care services /
/// Operations / Communication / Support) with real pending/unread badges -
/// no mock data.
class NurseMoreScreen extends StatefulWidget {
  const NurseMoreScreen({super.key});

  @override
  State<NurseMoreScreen> createState() => _NurseMoreScreenState();
}

class _NurseMoreScreenState extends State<NurseMoreScreen> {
  static const _card = Color(0xFF151929);
  static const _muted = Color(0xFF8A93A6);

  StaffAlertsRepository? _alertsRepository;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HealthBloc>().add(
        FetchHealthDashboardData(authState.user.schoolId),
      );
      try {
        _alertsRepository = StaffAlertsRepository();
      } catch (_) {
        _alertsRepository = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    final uid = authState is AuthAuthenticated ? authState.user.id : '';

    return Scaffold(
      backgroundColor: const Color(0xFF070914),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _Header(
              name: authState is AuthAuthenticated
                  ? authState.user.name
                  : 'Nurse',
            ),
            const SizedBox(height: 20),
            const _SectionHeader('Care services'),
            _MoreSection(
              rows: [
                _MoreRowData(
                  icon: Icons.bed_outlined,
                  color: const Color(0xFF10B981),
                  title: 'Sick bay',
                  subtitle: 'Admissions, beds and observations',
                  onTap: () => context.push('/staff/nurse/records'),
                ),
                _MoreRowData(
                  icon: Icons.vaccines_outlined,
                  color: const Color(0xFF10B981),
                  title: 'Immunizations',
                  subtitle: 'Vaccination schedules and records',
                  onTap: () => context.push('/staff/nurse/lookup'),
                ),
                _MoreRowData(
                  icon: Icons.how_to_reg_outlined,
                  color: const Color(0xFF3B82F6),
                  title: 'Health screenings',
                  subtitle: 'Programs, results and follow-ups',
                  onTap: () => context.push('/staff/nurse/records'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionHeader('Operations'),
            BlocBuilder<HealthBloc, HealthState>(
              builder: (context, state) {
                final pending = state is HealthDashboardLoaded
                    ? state.pendingRequests.length
                    : 0;
                return _MoreSection(
                  rows: [
                    _MoreRowData(
                      icon: Icons.local_shipping_outlined,
                      color: const Color(0xFFFF6A00),
                      title: 'Supply requests',
                      subtitle: 'Request medicines and clinic supplies',
                      badge: pending > 0 ? '$pending pending' : null,
                      onTap: () => context.push('/staff/nurse/inventory'),
                    ),
                    _MoreRowData(
                      icon: Icons.event_available_outlined,
                      color: const Color(0xFF10B981),
                      title: 'Appointments & referrals',
                      subtitle: 'Clinic bookings and external referrals',
                      onTap: () => context.push('/staff/nurse/visits'),
                    ),
                    _MoreRowData(
                      icon: Icons.bar_chart_outlined,
                      color: const Color(0xFF3B82F6),
                      title: 'Reports & analytics',
                      subtitle: 'Health trends and statutory reports',
                      onTap: () => context.push('/staff/nurse/records'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const _SectionHeader('Communication'),
            _NotificationsAwareSection(
              alertsRepository: _alertsRepository,
              schoolId: schoolId,
              uid: uid,
            ),
            const SizedBox(height: 20),
            const _SectionHeader('Support'),
            _MoreSection(
              rows: [
                _MoreRowData(
                  icon: Icons.settings_outlined,
                  color: const Color(0xFF3B82F6),
                  title: 'Clinic settings',
                  subtitle: 'Preferences, policies and permissions',
                  onTap: () => context.push('/staff/more'),
                ),
                _MoreRowData(
                  icon: Icons.help_outline,
                  color: const Color(0xFF10B981),
                  title: 'Help & support',
                  subtitle: 'Guides and contact support',
                  onTap: () => context.push('/staff/more'),
                ),
                _MoreRowData(
                  icon: Icons.logout_rounded,
                  color: const Color(0xFFEF4444),
                  title: 'Logout',
                  subtitle: 'Sign out of your nurse account',
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutPressed());
      context.go('/welcome');
    }
  }
}

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

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
                'More',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Clinic services and administration',
                style: TextStyle(
                  color: _NurseMoreScreenState._muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFF1E293B),
          child: Icon(
            Icons.local_hospital_rounded,
            color: Color(0xFFFF6A00),
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MoreRowData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _MoreRowData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });
}

class _MoreSection extends StatelessWidget {
  final List<_MoreRowData> rows;
  const _MoreSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _NurseMoreScreenState._card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _MoreRow(data: rows[i]),
            if (i != rows.length - 1)
              const Divider(
                height: 1,
                color: Colors.white10,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final _MoreRowData data;
  const _MoreRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: data.onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(data.icon, color: data.color, size: 20),
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
          color: _NurseMoreScreenState._muted,
          fontSize: 12.5,
        ),
      ),
      trailing: data.badge != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6A00),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            )
          : const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}

/// Wraps the Communication section with a live unread-count badge on
/// Notifications, matching how [NotificationBellButton] sources its badge.
class _NotificationsAwareSection extends StatelessWidget {
  final StaffAlertsRepository? alertsRepository;
  final String schoolId;
  final String uid;

  const _NotificationsAwareSection({
    required this.alertsRepository,
    required this.schoolId,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final repository = alertsRepository;
    if (repository == null || schoolId.isEmpty || uid.isEmpty) {
      return _buildSection(context, unread: 0);
    }
    return StreamBuilder<List<StaffAlert>>(
      stream: repository.watchAllForUser(
        schoolId: schoolId,
        uid: uid,
        groups: NotificationGroups.forRole(UserRole.nurse),
      ),
      builder: (context, snapshot) {
        final unread = (snapshot.data ?? const [])
            .where((a) => !a.isReadBy(uid))
            .length;
        return _buildSection(context, unread: unread);
      },
    );
  }

  Widget _buildSection(BuildContext context, {required int unread}) {
    return _MoreSection(
      rows: [
        _MoreRowData(
          icon: Icons.notifications_outlined,
          color: const Color(0xFFFF6A00),
          title: 'Notifications',
          subtitle: 'Clinic alerts and announcements',
          badge: unread > 0 ? '$unread' : null,
          onTap: () => context.push('/staff/notifications'),
        ),
        _MoreRowData(
          icon: Icons.forum_outlined,
          color: const Color(0xFF10B981),
          title: 'Parent updates',
          subtitle: 'Health updates sent to guardians',
          onTap: () => context.push('/staff/messages'),
        ),
      ],
    );
  }
}
