import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/entities/audit_log.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school_application.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../widgets/super_admin_tab_navigator.dart';
import 'school_application_review_screen.dart';
import 'school_detail_screen.dart';

/// Presentation-only owner Schools surface. All lists are projections of the
/// existing SuperAdminBloc state; lifecycle changes continue through the
/// established UpdateSchoolStatusEvent flow.
class SchoolManagementScreen extends StatefulWidget {
  const SchoolManagementScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  State<SchoolManagementScreen> createState() => _SchoolManagementScreenState();
}

class _SchoolManagementScreenState extends State<SchoolManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(_onTabChanged);
  late String _query = widget.initialQuery ?? '';
  late final TextEditingController _search = TextEditingController(
    text: _query,
  );
  SchoolFilter _filter = SchoolFilter.all;

  void _onTabChanged() {
    if (!_tabs.indexIsChanging) {
      setState(() => _filter = SchoolFilter.all);
    }
  }

  @override
  void didUpdateWidget(covariant SchoolManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != null &&
        widget.initialQuery != oldWidget.initialQuery) {
      _query = widget.initialQuery!;
      _search.value = TextEditingValue(text: _query);
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  void _refresh() {
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    context.read<SuperAdminBloc>().add(const LoadAuditLogsEvent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    body: SafeArea(
      bottom: false,
      child: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          final data = _SchoolsViewData.fromState(state, _query, _filter);
          return Column(
            children: [
              PlatformSchoolsHeader(
                tabIndex: _tabs.index,
                activeCount: data.totalActive,
                applicationsCount: data.totalApplications,
                suspendedCount: data.totalSuspended,
                onRefresh: _refresh,
                onCreate: () => _tabs.animateTo(1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SchoolStatusTabs(
                  controller: _tabs,
                  activeCount: data.totalActive,
                  applicationsCount: data.totalApplications,
                  suspendedCount: data.totalSuspended,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _descriptionFor(_tabs.index),
                    style: _body(context),
                  ),
                ),
              ),
              if (_tabs.index == 2)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: _SuspensionNotice(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: SchoolSearchAndFilter(
                  controller: _search,
                  filter: _filter,
                  tabIndex: _tabs.index,
                  onChanged: (value) => setState(() => _query = value),
                  onFilterChanged: (value) => setState(() => _filter = value),
                ),
              ),
              Expanded(child: _tabBody(context, state, data)),
            ],
          );
        },
      ),
    ),
  );

  Widget _tabBody(
    BuildContext context,
    SuperAdminState state,
    _SchoolsViewData data,
  ) {
    if (state.status == SuperAdminStatus.loading &&
        state.schools.isEmpty &&
        state.applications.isEmpty) {
      return const Center(child: SchoolPulseLoader());
    }
    if (state.status == SuperAdminStatus.failure &&
        state.schools.isEmpty &&
        state.applications.isEmpty) {
      return _CompactState(
        message: state.errorMessage ?? 'Unable to load schools.',
        onRetry: _refresh,
      );
    }
    return TabBarView(
      controller: _tabs,
      children: [
        _SchoolGrid(
          schools: data.active,
          plans: state.plans,
          emptyTitle: 'No active schools',
          emptyMessage: 'Approved schools will appear here.',
        ),
        _ApplicationsGrid(applications: data.applications),
        _SuspendedGrid(
          schools: data.suspended,
          plans: state.plans,
          logs: state.auditLogs,
        ),
      ],
    );
  }
}

class PlatformSchoolsHeader extends StatelessWidget {
  const PlatformSchoolsHeader({
    super.key,
    required this.tabIndex,
    required this.activeCount,
    required this.applicationsCount,
    required this.suspendedCount,
    required this.onRefresh,
    required this.onCreate,
  });
  final int tabIndex, activeCount, applicationsCount, suspendedCount;
  final VoidCallback onRefresh, onCreate;

  @override
  Widget build(BuildContext context) {
    final (count, label, color) = switch (tabIndex) {
      0 => (activeCount, 'active', AppColors.information(context)),
      1 => (applicationsCount, 'applications', AppColors.warning(context)),
      _ => (suspendedCount, 'suspended', AppColors.danger(context)),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Schools',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _pageTitle(context),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: _CountPill(label: '$count $label', color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _HeaderAction(
            icon: Icons.add_rounded,
            tooltip: 'Start a school application',
            label: 'Create',
            onTap: onCreate,
          ),
          const SizedBox(width: 6),
          _HeaderAction(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh schools',
            label: 'Refresh',
            onTap: onRefresh,
          ),
        ],
      ),
    );
  }
}

class SchoolStatusTabs extends StatelessWidget {
  const SchoolStatusTabs({
    super.key,
    required this.controller,
    required this.activeCount,
    required this.applicationsCount,
    required this.suspendedCount,
  });
  final TabController controller;
  final int activeCount, applicationsCount, suspendedCount;
  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: TabBar(
      controller: controller,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.information(context), width: 3),
        insets: const EdgeInsets.symmetric(horizontal: 8),
      ),
      labelColor: AppColors.information(context),
      unselectedLabelColor: AppColors.textSecondary(context),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      tabs: [
        _tab('Active', activeCount, context),
        _tab('Applications', applicationsCount, context),
        _tab('Suspended', suspendedCount, context),
      ],
    ),
  );
  Widget _tab(String label, int count, BuildContext context) => Tab(
    child: FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          _CountPill(
            label: '$count',
            color: AppColors.textMuted(context),
            compact: true,
          ),
        ],
      ),
    ),
  );
}

class SchoolSearchAndFilter extends StatelessWidget {
  const SchoolSearchAndFilter({
    super.key,
    required this.controller,
    required this.filter,
    required this.tabIndex,
    required this.onChanged,
    required this.onFilterChanged,
  });
  final TextEditingController controller;
  final SchoolFilter filter;
  final int tabIndex;
  final ValueChanged<String> onChanged;
  final ValueChanged<SchoolFilter> onFilterChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search name, prefix, email, district or tenant ID',
            hintStyle: _body(context),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary(context),
              size: 21,
            ),
            isDense: true,
            filled: true,
            fillColor: AppColors.surfaceElevated(context),
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.information(context),
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      PopupMenuButton<SchoolFilter>(
        tooltip: 'Filter schools',
        onSelected: onFilterChanged,
        itemBuilder: (_) => _filterOptions(tabIndex)
            .map(
              (option) =>
                  PopupMenuItem(value: option.$1, child: Text(option.$2)),
            )
            .toList(),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: filter == SchoolFilter.all
                ? AppColors.surfaceElevated(context)
                : AppColors.informationSurface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 4),
              const Text(
                'Filter',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _SchoolGrid extends StatelessWidget {
  const _SchoolGrid({
    required this.schools,
    required this.plans,
    required this.emptyTitle,
    required this.emptyMessage,
  });
  final List<School> schools;
  final List<SubscriptionPlan> plans;
  final String emptyTitle, emptyMessage;
  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) {
      return _CompactEmpty(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.school_outlined,
      );
    }
    return _ResponsiveGrid(
      itemCount: schools.length,
      itemBuilder: (_, index) => PlatformSchoolCard(
        school: schools[index],
        plan: _planFor(schools[index], plans),
      ),
    );
  }
}

class PlatformSchoolCard extends StatelessWidget {
  const PlatformSchoolCard({super.key, required this.school, this.plan});
  final School school;
  final SubscriptionPlan? plan;
  @override
  Widget build(BuildContext context) {
    final healthy = school.status == SchoolStatus.active;
    return PulseCard(
      onTap: () => _openSchool(context, school),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(
                label: _initials(school.name),
                color: healthy
                    ? AppColors.information(context)
                    : AppColors.warning(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _schoolName(school),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _cardTitle(context),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _location(school),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _StatusChip(
                label: healthy ? 'Healthy' : 'Trial',
                color: healthy
                    ? AppColors.success(context)
                    : AppColors.warning(context),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.border(context)),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _Meta(
                  label: 'Plan',
                  value: plan?.name ?? _fallbackPlan(school),
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.border(context)),
              const SizedBox(width: 12),
              Expanded(
                child: _Meta(
                  label: _adminLabel(school),
                  value: _adminValue(school),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationsGrid extends StatelessWidget {
  const _ApplicationsGrid({required this.applications});
  final List<SchoolApplication> applications;
  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const _CompactEmpty(
        title: 'No school applications',
        message: 'New applications will appear here.',
        icon: Icons.inbox_outlined,
      );
    }
    return _ResponsiveGrid(
      itemCount: applications.length,
      mainAxisExtent: 232,
      itemBuilder: (_, index) =>
          SchoolApplicationCard(application: applications[index]),
    );
  }
}

class SchoolApplicationCard extends StatelessWidget {
  const SchoolApplicationCard({super.key, required this.application});
  final SchoolApplication application;
  @override
  Widget build(BuildContext context) => PulseCard(
    onTap: () => _openApplication(context, application),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(
              label: _initials(application.schoolName),
              color: AppColors.information(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.schoolName.isEmpty
                        ? 'Unnamed school'
                        : application.schoolName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cardTitle(context),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _applicationLocation(application),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(context),
                  ),
                ],
              ),
            ),
            _StatusChip(
              label: _relative(application.createdAt),
              color: AppColors.warning(context),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(height: 1, color: AppColors.border(context)),
        const SizedBox(height: 9),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _Meta(
                label: 'Applicant contact',
                value: _applicationContact(application),
              ),
            ),
            Expanded(
              child: _Meta(
                label: 'Requested plan',
                value: application.plan.isEmpty
                    ? 'Not selected'
                    : application.plan,
              ),
            ),
            Expanded(
              child: _Meta(
                label: 'Verification',
                value: _verification(application),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            onPressed: () => _openApplication(context, application),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.information(context),
              side: BorderSide(color: AppColors.information(context)),
              minimumSize: const Size(76, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Review'),
          ),
        ),
      ],
    ),
  );
}

class _SuspendedGrid extends StatelessWidget {
  const _SuspendedGrid({
    required this.schools,
    required this.plans,
    required this.logs,
  });
  final List<School> schools;
  final List<SubscriptionPlan> plans;
  final List<AuditLog> logs;
  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) {
      return const _CompactEmpty(
        title: 'No suspended schools',
        message: 'Suspended schools will appear here.',
        icon: Icons.lock_outline_rounded,
      );
    }
    return _ResponsiveGrid(
      itemCount: schools.length,
      mainAxisExtent: 244,
      itemBuilder: (_, index) => SuspendedSchoolCard(
        school: schools[index],
        plan: _planFor(schools[index], plans),
        audit: _latestSuspensionLog(schools[index], logs),
      ),
    );
  }
}

class SuspendedSchoolCard extends StatelessWidget {
  const SuspendedSchoolCard({
    super.key,
    required this.school,
    this.plan,
    this.audit,
  });
  final School school;
  final SubscriptionPlan? plan;
  final AuditLog? audit;
  @override
  Widget build(BuildContext context) => PulseCard(
    onTap: () => _openSchool(context, school),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(
              label: _initials(school.name),
              color: AppColors.danger(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _schoolName(school),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cardTitle(context),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _location(school),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(context),
                  ),
                ],
              ),
            ),
            _StatusChip(label: 'Suspended', color: AppColors.danger(context)),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(height: 1, color: AppColors.border(context)),
        const SizedBox(height: 9),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Meta(
                label: 'Suspended on',
                value: audit == null
                    ? 'Unavailable'
                    : DateFormat('MMM d, y').format(audit!.timestamp),
              ),
            ),
            Expanded(
              child: _Meta(
                label: 'Plan',
                value: plan?.name ?? _fallbackPlan(school),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _Meta(
                label: 'Reason',
                value: audit?.reason?.trim().isNotEmpty == true
                    ? audit!.reason!
                    : 'Unavailable',
              ),
            ),
            Expanded(
              child: _Meta(label: _adminLabel(school), value: _adminValue(school)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            onPressed: () => _confirmRestore(context, school),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.information(context),
              side: BorderSide(color: AppColors.information(context)),
              minimumSize: const Size(86, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Restore'),
          ),
        ),
      ],
    ),
  );
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.mainAxisExtent = 180,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double mainAxisExtent;
  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
        context.read<SuperAdminBloc>().add(const LoadAuditLogsEvent());
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          // At the 760px owner breakpoint this yields two usable card
          // columns; wider desktop windows naturally gain a third.
          maxCrossAxisExtent: wide ? 350 : 600,
          mainAxisExtent: mainAxisExtent,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class _SuspensionNotice extends StatelessWidget {
  const _SuspensionNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.dangerSurface(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.danger(context).withValues(alpha: .3),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 19,
          color: AppColors.danger(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Suspension keeps school data safe while restricting access.',
            style: _body(context),
          ),
        ),
      ],
    ),
  );
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty({
    required this.title,
    required this.message,
    required this.icon,
  });
  final String title, message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.textMuted(context)),
          const SizedBox(height: 8),
          Text(title, style: _cardTitle(context)),
          const SizedBox(height: 3),
          Text(message, textAlign: TextAlign.center, style: _body(context)),
        ],
      ),
    ),
  );
}

class _CompactState extends StatelessWidget {
  const _CompactState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, color: AppColors.danger(context)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: _body(context)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip, label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: _label(context)),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.label,
    required this.color,
    this.compact = false,
  });
  final String label;
  final Color color;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 7 : 10,
      vertical: compact ? 3 : 6,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? 12 : 14,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _label(context),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimary(context),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

enum SchoolFilter { all, trial, pending, needsVerification, archived }

class _SchoolsViewData {
  const _SchoolsViewData({
    required this.active,
    required this.suspended,
    required this.applications,
    required this.totalActive,
    required this.totalSuspended,
    required this.totalApplications,
  });
  final List<School> active, suspended;
  final List<SchoolApplication> applications;
  final int totalActive, totalSuspended, totalApplications;
  factory _SchoolsViewData.fromState(
    SuperAdminState state,
    String query,
    SchoolFilter filter,
  ) {
    final search = query.trim().toLowerCase();
    bool schoolMatches(School s) =>
        search.isEmpty ||
        [
          s.name,
          s.tenantId,
          s.contactEmail,
          s.address,
          '${s.metadata['prefix'] ?? ''}',
          '${s.metadata['district'] ?? ''}',
        ].any((value) => value.toLowerCase().contains(search));
    bool applicationMatches(SchoolApplication a) =>
        search.isEmpty ||
        [
          a.schoolName,
          a.prefix,
          a.schoolEmail,
          a.administratorEmail,
          a.district,
          a.administratorName,
        ].any((value) => value.toLowerCase().contains(search));
    final allActive = state.schools
        .where(
          (s) =>
              s.status == SchoolStatus.active || s.status == SchoolStatus.trial,
        )
        .toList();
    final allSuspended = state.schools
        .where(
          (s) =>
              s.status == SchoolStatus.suspended ||
              s.status == SchoolStatus.archived,
        )
        .toList();
    final active = allActive
        .where(
          (s) =>
              schoolMatches(s) &&
              (filter != SchoolFilter.trial || s.status == SchoolStatus.trial),
        )
        .toList();
    final suspended = allSuspended
        .where(
          (s) =>
              schoolMatches(s) &&
              (filter != SchoolFilter.archived ||
                  s.status == SchoolStatus.archived),
        )
        .toList();
    final applications =
        state.applications.where((a) {
          if (!applicationMatches(a)) return false;
          if (filter == SchoolFilter.pending) {
            return a.status == SchoolApplicationStatus.pendingReview;
          }
          if (filter == SchoolFilter.needsVerification) {
            return !a.administratorEmailVerified;
          }
          return true;
        }).toList()..sort(
          (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
            a.createdAt ?? DateTime(1970),
          ),
        );
    return _SchoolsViewData(
      active: active,
      suspended: suspended,
      applications: applications,
      totalActive: allActive.length,
      totalSuspended: allSuspended.length,
      totalApplications: state.applications.length,
    );
  }
}

List<(SchoolFilter, String)> _filterOptions(int tab) => switch (tab) {
  0 => const [
    (SchoolFilter.all, 'All active schools'),
    (SchoolFilter.trial, 'Trial schools'),
  ],
  1 => const [
    (SchoolFilter.all, 'All applications'),
    (SchoolFilter.pending, 'Pending review'),
    (SchoolFilter.needsVerification, 'Needs verification'),
  ],
  _ => const [
    (SchoolFilter.all, 'All suspended'),
    (SchoolFilter.archived, 'Archived schools'),
  ],
};
String _descriptionFor(int index) => switch (index) {
  0 => 'Manage every institution using School Pulse.',
  1 => 'Review and manage school applications.',
  _ => 'Restricted institutions remain available for safe restoration.',
};
SubscriptionPlan? _planFor(School school, List<SubscriptionPlan> plans) {
  for (final plan in plans) {
    if (plan.id == school.subscriptionPlanId) return plan;
  }
  return null;
}

AuditLog? _latestSuspensionLog(School school, List<AuditLog> logs) {
  final matches =
      logs
          .where(
            (log) =>
                log.schoolId == school.id &&
                log.action.toLowerCase().contains('suspend'),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return matches.isEmpty ? null : matches.first;
}

void _openSchool(BuildContext context, School school) => pushSuperAdminDetail(
  context: context,
  sectionPath: 'schools',
  detailPath: school.id,
  detail: SchoolDetailScreen(school: school),
);
void _openApplication(BuildContext context, SchoolApplication application) =>
    pushSuperAdminDetail(
      context: context,
      sectionPath: 'schools',
      detailPath: 'applications/${application.id}',
      detail: BlocProvider.value(
        value: context.read<SuperAdminBloc>(),
        child: SchoolApplicationReviewScreen(application: application),
      ),
    );
Future<void> _confirmRestore(BuildContext context, School school) async {
  final restore = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Restore school?'),
      content: Text(
        '${_schoolName(school)} will regain access. This action is logged.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialog, true),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
  if (restore == true && context.mounted) {
    context.read<SuperAdminBloc>().add(
      UpdateSchoolStatusEvent(schoolId: school.id, status: SchoolStatus.active),
    );
  }
}

String _schoolName(School school) =>
    school.name.trim().isEmpty ? 'Unnamed school' : school.name;
String _location(School school) {
  final district = school.metadata['district']?.toString().trim();
  return district?.isNotEmpty == true
      ? district!
      : (school.address.trim().isEmpty
            ? 'Location unavailable'
            : school.address);
}

String _adminLabel(School school) =>
    school.metadata['adminName']?.toString().trim().isNotEmpty == true
    ? 'School Admin'
    : 'Contact';
String _adminValue(School school) =>
    school.metadata['adminName']?.toString().trim().isNotEmpty == true
    ? school.metadata['adminName'].toString()
    : (school.contactEmail.isEmpty ? 'Unavailable' : school.contactEmail);
String _fallbackPlan(School school) => school.subscriptionPlanId.isEmpty
    ? 'Unavailable'
    : school.subscriptionPlanId;
String _applicationLocation(SchoolApplication app) => app.district.isNotEmpty
    ? app.district
    : (app.region.isNotEmpty ? app.region : 'Location unavailable');
String _applicationContact(SchoolApplication app) =>
    app.administratorEmail.isNotEmpty
    ? app.administratorEmail
    : (app.schoolEmail.isNotEmpty ? app.schoolEmail : 'Unavailable');
String _verification(SchoolApplication app) =>
    app.administratorEmailVerified ? 'Email verified' : app.status.label;
String _relative(DateTime? value) {
  if (value == null) return 'Submitted date unavailable';
  final difference = DateTime.now().difference(value);
  if (difference.inMinutes < 1) return 'Submitted now';
  if (difference.inHours < 1) return 'Submitted ${difference.inMinutes}m ago';
  if (difference.inDays < 1) return 'Submitted ${difference.inHours}h ago';
  return 'Submitted ${difference.inDays}d ago';
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'S';
  return parts.take(2).map((part) => part[0]).join().toUpperCase();
}

TextStyle _pageTitle(BuildContext context) =>
    AppTypography.headlineMedium.copyWith(
      color: AppColors.textPrimary(context),
      fontSize: 26,
      fontWeight: FontWeight.w800,
    );
TextStyle _cardTitle(BuildContext context) =>
    AppTypography.titleMedium.copyWith(
      color: AppColors.textPrimary(context),
      fontSize: 17,
      fontWeight: FontWeight.w800,
    );
TextStyle _label(BuildContext context) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(context),
  fontSize: 11.5,
);
TextStyle _body(BuildContext context) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(context),
  fontSize: 13.5,
);
