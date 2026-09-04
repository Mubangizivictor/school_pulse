import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/data/models/audit_log.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/presentation/widgets/messages_nav_icon.dart';
import 'package:school_pulse/features/notifications/domain/repositories/notification_repository.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Tenant-scoped School Admin home. All metric values come from the existing
/// dashboard BLoC; action counts and pins are read from the active tenant.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, this.firestoreOverride});

  /// Test-only override for the Firestore instance used by the "Needs
  /// attention" live-work stream. Defaults to [FirebaseFirestore.instance].
  final FirebaseFirestore? firestoreOverride;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => di.sl<AdminDashboardBloc>()..add(LoadAdminDashboardStats()),
    child: _AdminHome(firestore: firestoreOverride ?? FirebaseFirestore.instance),
  );
}

class _AdminHome extends StatelessWidget {
  const _AdminHome({required this.firestore});
  final FirebaseFirestore firestore;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final user = auth.user;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.textPrimary(context),
          onRefresh: () async {
            context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats());
            await context.read<AdminDashboardBloc>().stream.firstWhere(
              (state) => state is! AdminDashboardLoading,
            );
          },
          child: ResponsiveBuilder(
            builder: (context, layout) =>
                _HomeBody(user: user, layout: layout, firestore: firestore),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.user,
    required this.layout,
    required this.firestore,
  });
  final UserEntity user;
  final ResponsiveLayout layout;
  final FirebaseFirestore firestore;

  bool get _isMobile => layout == ResponsiveLayout.mobile;
  bool get _isDesktop => layout == ResponsiveLayout.desktop;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(
      _isMobile ? AppSpacing.xl : (_isDesktop ? AppSpacing.x4l : AppSpacing.x3l),
      AppSpacing.xl,
      _isMobile ? AppSpacing.xl : (_isDesktop ? AppSpacing.x4l : AppSpacing.x3l),
      AppSpacing.x9l,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _isDesktop ? 1200 : 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(user: user, isMobile: _isMobile, isDesktop: _isDesktop),
            SizedBox(height: _isMobile ? AppSpacing.xl : AppSpacing.x3l),
            _AttentionSection(
              user: user,
              isDesktop: _isDesktop,
              firestore: firestore,
            ),
            SizedBox(height: AppSpacing.x3l),
            _MetricsSection(user: user, isMobile: _isMobile),
            SizedBox(height: AppSpacing.x3l),
            _QuickActionsSection(isMobile: _isMobile),
            SizedBox(height: AppSpacing.x3l),
            if (_isDesktop || layout == ResponsiveLayout.tablet)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _AttendanceSummarySection(user: user)),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(child: _RecentActivitySection()),
                  ],
                ),
              )
            else ...[
              _AttendanceSummarySection(user: user),
              SizedBox(height: AppSpacing.x3l),
              _RecentActivitySection(),
            ],
          ],
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.isMobile,
    required this.isDesktop,
  });
  final UserEntity user;
  final bool isMobile;
  final bool isDesktop;

  /// Only desktop has real horizontal room for the name block, both term/
  /// date chips, and the two icon buttons on a single row. Mobile and
  /// tablet always stack the context row below instead of squeezing it in,
  /// so this never depends on exactly how wide "tablet" happens to be.
  bool get _inlineContextRow => isDesktop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: AppRadius.medium,
            ),
            child: Icon(
              Icons.school_outlined,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, ${user.name.split(' ').first}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  'School Admin · ${user.schoolName?.isNotEmpty == true ? user.schoolName! : 'School'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          if (_inlineContextRow) ...[
            const SizedBox(width: AppSpacing.xl),
            _ContextRow(user: user, compact: true),
          ],
          const SizedBox(width: AppSpacing.m),
          _NotificationButton(user: user),
          IconButton(
            onPressed: () => context.push('/staff/messages'),
            icon: const MessagesNavIcon(
              icon: Icons.chat_bubble_outline_rounded,
              size: 22,
            ),
          ),
        ],
      ),
      if (!_inlineContextRow) ...[
        const SizedBox(height: AppSpacing.l),
        _ContextRow(user: user, compact: false),
      ],
    ],
  );
}

/// Shows a badge only when the signed-in user has an unread notification.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) => StreamBuilder<NotificationCounts>(
    stream: di.sl<NotificationRepository>().watchCounts(
      schoolId: user.schoolId,
      recipientUserId: user.id,
    ),
    builder: (context, snapshot) {
      final unread = snapshot.data?.unread ?? 0;
      return IconButton(
        onPressed: () => context.push('/staff/notifications'),
        icon: Badge(
          isLabelVisible: unread > 0,
          backgroundColor: AppColors.danger(context),
          textColor: AppColors.white,
          label: Text(unread > 99 ? '99+' : '$unread'),
          child: Icon(
            Icons.notifications_none_rounded,
            size: 22,
            color: AppColors.textPrimary(context),
          ),
        ),
      );
    },
  );
}

class _ContextRow extends StatelessWidget {
  const _ContextRow({required this.user, required this.compact});
  final UserEntity user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chips = [
      _FilterChip(
        icon: Icons.calendar_today_outlined,
        label: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          builder: (_, state) => Text(
            state is AdminDashboardLoaded
                ? state.stats.currentPeriodLabel ?? 'Select term'
                : 'Select term',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onTap: () => _showTermPicker(context, user),
      ),
      _FilterChip(
        icon: Icons.event_outlined,
        label: Text(
          DateFormat('EEE, d MMM').format(DateTime.now()),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: null,
      ),
    ];
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: chips[0],
          ),
          const SizedBox(width: AppSpacing.m),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: chips[1],
          ),
        ],
      );
    }
    return Row(children: [
      Expanded(child: chips[0]),
      const SizedBox(width: AppSpacing.m),
      Expanded(child: chips[1]),
    ]);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final Widget label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceContainer(context),
    borderRadius: AppRadius.medium,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        decoration: BoxDecoration(
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary(context)),
            const SizedBox(width: AppSpacing.m),
            Flexible(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary(context),
                ),
                child: label,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({
    required this.user,
    required this.isDesktop,
    required this.firestore,
  });
  final UserEntity user;
  final bool isDesktop;
  final FirebaseFirestore firestore;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<_WorkItem>>(
    stream: _watchWork(user, firestore),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return PulseCard(
          child: _Retry(
            message: "Couldn't load work.",
            onRetry: () =>
                context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats()),
          ),
        );
      }
      if (!snapshot.hasData) return const _LoadingBlock();
      final items = snapshot.data!;
      return PulseCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Needs attention',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.m),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSurface(context),
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      '${items.fold<int>(0, (v, i) => v + i.count)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: AppColors.success(context),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Text(
                      "You're all caught up.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              )
            else if (isDesktop)
              Wrap(
                spacing: AppSpacing.l,
                runSpacing: AppSpacing.l,
                children: items.map((item) => _WorkChip(item: item)).toList(),
              )
            else
              Column(
                children: items.map((item) => _WorkRow(item: item)).toList(),
              ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              PulseButton(
                label: 'View all work',
                isFullWidth: true,
                onPressed: () => context.go('/staff/admin/approvals'),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _WorkChip extends StatelessWidget {
  const _WorkChip({required this.item});
  final _WorkItem item;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceContainer(context),
    borderRadius: AppRadius.medium,
    child: InkWell(
      onTap: () => context.push(item.route),
      borderRadius: AppRadius.medium,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 16, color: AppColors.textSecondary(context)),
            const SizedBox(width: AppSpacing.m),
            Text(
              '${item.count} ${item.label}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WorkRow extends StatelessWidget {
  const _WorkRow({required this.item});
  final _WorkItem item;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push(item.route),
    borderRadius: AppRadius.medium,
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.dangerSurface(context),
              borderRadius: AppRadius.small,
            ),
            child: Icon(item.icon, size: 18, color: AppColors.danger(context)),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Text(
              '${item.count} ${item.label}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textMuted(context),
          ),
        ],
      ),
    ),
  );
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({required this.user, required this.isMobile});
  final UserEntity user;
  final bool isMobile;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
    builder: (context, state) {
      if (state is AdminDashboardError) {
        return PulseCard(
          child: _Retry(
            message: "Couldn't load school metrics.",
            onRetry: () =>
                context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats()),
          ),
        );
      }
      if (state is! AdminDashboardLoaded) return const _LoadingBlock();
      final stats = state.stats;
      final todayPercent = stats.todayAttendanceCounts != null &&
              stats.todayAttendanceCounts!.total > 0
          ? stats.todayAttendanceCounts!.presentPercent * 100
          : null;

      final tiles = <Widget>[
        _MetricTile(
          label: 'Active learners',
          value: '${stats.totalStudentsCount}',
          icon: Icons.groups_2_outlined,
        ),
        _MetricTile(
          label: 'Active staff',
          value: '${stats.activeStaffCount}',
          icon: Icons.badge_outlined,
        ),
        _MetricTile(
          label: "Today's attendance",
          value: todayPercent == null ? '—' : '${todayPercent.round()}%',
          icon: Icons.check_circle_outline,
        ),
        if (_canSeeFinance(user))
          _MetricTile(
            label: 'Fees collected',
            value: stats.termFeesCollected == null
                ? '—'
                : 'UGX ${_money(stats.termFeesCollected!)}',
            icon: Icons.account_balance_wallet_outlined,
          ),
      ];

      if (isMobile) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.l,
          crossAxisSpacing: AppSpacing.l,
          childAspectRatio: 1.5,
          children: tiles,
        );
      }
      return Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.l),
            Expanded(child: tiles[i]),
          ],
        ],
      );
    },
  );
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => PulseCard(
    padding: const EdgeInsets.all(AppSpacing.l),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh(context),
            borderRadius: AppRadius.small,
          ),
          child: Icon(icon, size: 16, color: AppColors.textPrimary(context)),
        ),
        const SizedBox(height: AppSpacing.m),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
        ),
      ],
    ),
  );
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.isMobile});
  final bool isMobile;

  static const _shortcuts = [
    _Shortcut(
      'add_learner',
      'Add learner',
      'Register a new student',
      Icons.person_add_alt_1_outlined,
      '/staff/admin/admissions/register',
    ),
    _Shortcut(
      'attendance',
      'Take attendance',
      'Open an attendance session',
      Icons.check_circle_outline,
      '/staff/attendance',
    ),
    _Shortcut(
      'invite_staff',
      'Invite staff',
      'Add a new staff member',
      Icons.person_add_outlined,
      '/staff/admin/users/add-staff',
    ),
    _Shortcut(
      'school',
      'School structure',
      'Manage school structure and setup',
      Icons.school_outlined,
      '/staff/admin/structure',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.l,
        crossAxisSpacing: AppSpacing.l,
        childAspectRatio: 2.4,
        children: _shortcuts.map((s) => _QuickActionTile(shortcut: s)).toList(),
      );
    }
    return Row(
      children: [
        for (var i = 0; i < _shortcuts.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.l),
          Expanded(child: _QuickActionTile(shortcut: _shortcuts[i])),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.shortcut});
  final _Shortcut shortcut;
  @override
  Widget build(BuildContext context) => PulseCard(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.l,
      vertical: AppSpacing.l,
    ),
    onTap: () => context.push(shortcut.route),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: AppRadius.small,
            ),
            child: Icon(
              shortcut.icon,
              size: 18,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              shortcut.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textMuted(context),
          ),
        ],
      ),
    ),
  );
}

class _AttendanceSummarySection extends StatelessWidget {
  const _AttendanceSummarySection({required this.user});
  final UserEntity user;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
    builder: (context, state) {
      if (state is AdminDashboardError) {
        return PulseCard(
          child: _Retry(
            message: "Couldn't load attendance.",
            onRetry: () =>
                context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats()),
          ),
        );
      }
      if (state is! AdminDashboardLoaded) return const _LoadingBlock();
      final counts = state.stats.todayAttendanceCounts;

      return PulseCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Today's attendance",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/staff/attendance'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  ),
                  child: const Text('View details'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            if (counts == null || counts.total == 0)
              EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'No attendance yet today',
                message: 'Attendance sessions submitted today will show up here.',
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _AttendanceStat(
                      label: 'Present',
                      count: counts.present,
                      percent: counts.presentPercent,
                      color: AppColors.success(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: _AttendanceStat(
                      label: 'Late',
                      count: counts.late,
                      percent: counts.latePercent,
                      color: AppColors.warning(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: _AttendanceStat(
                      label: 'Absent',
                      count: counts.absent,
                      percent: counts.absentPercent,
                      color: AppColors.danger(context),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}

class _AttendanceStat extends StatelessWidget {
  const _AttendanceStat({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });
  final String label;
  final int count;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.s),
      Text(
        '${(percent * 100).round()}%',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
      Text(
        '$count learners',
        style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
      ),
    ],
  );
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
    builder: (context, state) {
      if (state is AdminDashboardError) {
        return PulseCard(
          child: _Retry(
            message: "Couldn't load recent activity.",
            onRetry: () =>
                context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats()),
          ),
        );
      }
      if (state is! AdminDashboardLoaded) return const _LoadingBlock();
      final logs = state.recentLogs;

      return PulseCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent activity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            if (logs.isEmpty)
              EmptyState(
                icon: Icons.history_outlined,
                title: 'No recent activity',
                message: 'Actions taken across the school will appear here.',
              )
            else
              Column(
                children: logs
                    .take(6)
                    .map((log) => _ActivityRow(log: log))
                    .toList(),
              ),
          ],
        ),
      );
    },
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.log});
  final AuditLog log;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer(context),
            borderRadius: AppRadius.small,
          ),
          child: Icon(
            Icons.circle_outlined,
            size: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(width: AppSpacing.l),
        Expanded(
          child: Text(
            log.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary(context)),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Text(
          DateFormat('h:mm a').format(log.timestamp),
          style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
        ),
      ],
    ),
  );
}

void _showTermPicker(BuildContext context, UserEntity user) {
  final bloc = context.read<AdminDashboardBloc>();
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => SafeArea(
      child: StreamBuilder<List<AcademicTerm>>(
        stream: di.sl<StructureRepository>().watchAcademicTerms(user.schoolId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 160,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary(context),
                ),
              ),
            );
          }
          final terms =
              snapshot.data!.where((term) => !term.isArchived).toList()
                ..sort((a, b) => b.startDate.compareTo(a.startDate));
          return ListView(
            shrinkWrap: true,
            children: terms
                .map(
                  (term) => ListTile(
                    title: Text('${term.name} · ${term.startDate.year}'),
                    trailing: term.isCurrent ? const Icon(Icons.check) : null,
                    onTap: () {
                      Navigator.pop(context);
                      bloc.add(
                        LoadAdminDashboardStats(
                          forTerm: term.isCurrent ? null : term,
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          );
        },
      ),
    ),
  );
}

Stream<List<_WorkItem>> _watchWork(UserEntity user, FirebaseFirestore firestore) {
  final school = firestore.collection('schools').doc(user.schoolId);
  final streams = [
    school
        .collection('expenditures')
        .where('status', isEqualTo: 'pending')
        .snapshots(),
    school
        .collection('reportCards')
        .where('academicStatus', isEqualTo: 'pendingHeadteacher')
        .snapshots(),
  ];
  return _streamZip(streams).map((data) {
    final work = <_WorkItem>[];
    if (_canSeeFinance(user) && data[0].docs.isNotEmpty) {
      work.add(
        _WorkItem(
          data[0].docs.length,
          'fees exceptions',
          Icons.account_balance_wallet_outlined,
          '/staff/bursar',
        ),
      );
    }
    if (_canApproveReports(user) && data[1].docs.isNotEmpty) {
      work.add(
        _WorkItem(
          data[1].docs.length,
          'report cards awaiting approval',
          Icons.description_outlined,
          '/staff/headteacher/report-approvals',
        ),
      );
    }
    return work;
  });
}

Stream<List<QuerySnapshot<Map<String, dynamic>>>> _streamZip(
  List<Stream<QuerySnapshot<Map<String, dynamic>>>> streams,
) => Stream.multi((controller) {
  final latest = List<QuerySnapshot<Map<String, dynamic>>?>.filled(
    streams.length,
    null,
  );
  final subscriptions =
      <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
  for (var index = 0; index < streams.length; index++) {
    final current = index;
    subscriptions.add(
      streams[index].listen((value) {
        latest[current] = value;
        if (latest.every((item) => item != null)) {
          controller.add(latest.cast<QuerySnapshot<Map<String, dynamic>>>());
        }
      }, onError: controller.addError),
    );
  }
  controller.onCancel = () async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  };
});

class _WorkItem {
  const _WorkItem(this.count, this.label, this.icon, this.route);
  final int count;
  final String label;
  final IconData icon;
  final String route;
}

class _Shortcut {
  const _Shortcut(this.id, this.label, this.description, this.icon, this.route);
  final String id, label, description, route;
  final IconData icon;
}

bool _canSeeFinance(UserEntity user) => user.roles.any(
  (role) =>
      role == UserRole.schoolAdmin ||
      role == UserRole.director ||
      role == UserRole.headTeacher ||
      role == UserRole.bursar,
);
bool _canApproveReports(UserEntity user) => user.roles.any(
  (role) =>
      role == UserRole.schoolAdmin ||
      role == UserRole.director ||
      role == UserRole.headTeacher,
);
String _money(double amount) => amount >= 1000000
    ? '${(amount / 1000000).toStringAsFixed(1)}M'
    : NumberFormat.decimalPattern().format(amount);

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100,
    child: Center(
      child: CircularProgressIndicator(color: AppColors.textPrimary(context)),
    ),
  );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(message, style: TextStyle(color: AppColors.textSecondary(context))),
      ),
      PulseButton(
        label: 'Retry',
        variant: PulseButtonVariant.outline,
        size: PulseButtonSize.small,
        onPressed: onRetry,
      ),
    ],
  );
}
