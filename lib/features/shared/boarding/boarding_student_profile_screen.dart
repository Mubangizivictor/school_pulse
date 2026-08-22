import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Plain, role-agnostic profile data - deliberately not the Patron/Matron
/// `BoardingStudent`/`Student` entities, so this file never imports either
/// role's domain layer. Fields the Patron/Matron doesn't have permission to
/// see (finance, academic marks, restricted medical/counseling notes) are
/// simply absent from this shape, not filtered out at render time.
class BoardingStudentProfile {
  final String id;
  final String name;
  final String? photoUrl;
  final String admissionNumber;
  final String studentClass;
  final String? dormitoryName;
  final String? bedNumber;
  final DateTime? dateOfBirth;
  final String? guardianPhone;
  final String? guardianName;
  final String status;

  const BoardingStudentProfile({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.admissionNumber,
    required this.studentClass,
    this.dormitoryName,
    this.bedNumber,
    this.dateOfBirth,
    this.guardianPhone,
    this.guardianName,
    this.status = 'Active',
  });
}

/// One session's attendance status for "Today's Attendance" - null means no
/// record exists yet for that session, rendered as a dash rather than a
/// fabricated status.
class TodaysAttendanceRow {
  final String? morningStatus;
  final String? eveningStatus;
  final String? weekendStatus;

  const TodaysAttendanceRow({
    this.morningStatus,
    this.eveningStatus,
    this.weekendStatus,
  });
}

/// Shared Patron/Matron boarding student profile - identical for boys and
/// girls, the per-role wrapper supplies live data + navigation callbacks so
/// no PatronBloc/MatronBloc reference belongs here.
class BoardingStudentProfileScreen extends StatelessWidget {
  final BoardingStudentProfile profile;
  final TodaysAttendanceRow attendance;
  final bool isLoading;
  final VoidCallback onWelfareNotes;
  final VoidCallback onDisciplineRecords;
  final VoidCallback onLeaveHistory;

  const BoardingStudentProfileScreen({
    super.key,
    required this.profile,
    required this.attendance,
    required this.isLoading,
    required this.onWelfareNotes,
    required this.onDisciplineRecords,
    required this.onLeaveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: isLoading
          ? const Center(child: Skeleton(height: 220, borderRadius: 16))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _HeaderCard(profile: profile),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.home_outlined,
                        label: 'Dormitory',
                        value: profile.dormitoryName ?? '—',
                      ),
                      _InfoRow(
                        icon: Icons.bed_outlined,
                        label: 'Bed Number',
                        value: profile.bedNumber ?? '—',
                      ),
                      if (profile.dateOfBirth != null)
                        _InfoRow(
                          icon: Icons.cake_outlined,
                          label: 'Date of Birth',
                          value: _formatDate(profile.dateOfBirth!),
                        ),
                      if (profile.guardianPhone != null &&
                          profile.guardianPhone!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: profile.guardianPhone!,
                        ),
                      if (profile.guardianName != null &&
                          profile.guardianName!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.family_restroom_outlined,
                          label: 'Parent',
                          value: profile.guardianName!,
                        ),
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Status',
                        value: profile.status,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  "Today's Attendance",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.l,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AttendanceCell(
                          label: 'Morning',
                          status: attendance.morningStatus,
                        ),
                      ),
                      _VerticalDivider(),
                      Expanded(
                        child: _AttendanceCell(
                          label: 'Evening',
                          status: attendance.eveningStatus,
                        ),
                      ),
                      _VerticalDivider(),
                      Expanded(
                        child: _AttendanceCell(
                          label: 'Weekend',
                          status: attendance.weekendStatus,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.favorite_outline,
                        label: 'Welfare Notes',
                        onTap: onWelfareNotes,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.gavel_outlined,
                        label: 'Discipline Records',
                        onTap: onDisciplineRecords,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.exit_to_app,
                        label: 'Leave History',
                        onTap: onLeaveHistory,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day} ${_month(date.month)} ${date.year}';

  static String _month(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
}

class _HeaderCard extends StatelessWidget {
  final BoardingStudentProfile profile;
  const _HeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
            CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(profile.photoUrl!),
            )
          else
            AvatarInitials(name: profile.name, size: 64),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${profile.admissionNumber} · ${profile.studentClass}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.m),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: AppSpacing.m),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _AttendanceCell extends StatelessWidget {
  final String label;
  final String? status;

  const _AttendanceCell({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;
    final color = switch (status?.toLowerCase()) {
      'present' => semanticColors.success,
      'absent' => semanticColors.error,
      'late' => semanticColors.warning,
      'leave' => Colors.deepOrange,
      _ => theme.colorScheme.outline,
    };
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          status ?? '—',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.l,
        horizontal: AppSpacing.s,
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(height: AppSpacing.s),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
