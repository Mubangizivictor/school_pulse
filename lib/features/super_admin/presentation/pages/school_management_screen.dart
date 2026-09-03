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
///
/// This file was redesigned to a dense, light-mode-first console layout
/// (compact header, three summary cards, tabs, a responsive data table that
/// collapses to compact cards on mobile, and compact pagination). None of the
/// routes, BLoC events, permissions, filters or lifecycle actions changed -
/// only the widgets that render them.
class SchoolManagementScreen extends StatefulWidget {
  const SchoolManagementScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  State<SchoolManagementScreen> createState() => _SchoolManagementScreenState();
}

class _SchoolManagementScreenState extends State<SchoolManagementScreen>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 10;

  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(_onTabChanged);
  late String _query = widget.initialQuery ?? '';
  late final TextEditingController _search = TextEditingController(
    text: _query,
  );
  SchoolFilter _filter = SchoolFilter.all;
  int _page = 0;

  void _onTabChanged() {
    if (!_tabs.indexIsChanging) {
      setState(() {
        _filter = SchoolFilter.all;
        _page = 0;
      });
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
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlatformSchoolsHeader(
                      tabIndex: _tabs.index,
                      activeCount: data.totalActive,
                      applicationsCount: data.totalApplications,
                      suspendedCount: data.totalSuspended,
                      controller: _search,
                      filter: _filter,
                      onQueryChanged: (value) => setState(() {
                        _query = value;
                        _page = 0;
                      }),
                      onFilterChanged: (value) => setState(() {
                        _filter = value;
                        _page = 0;
                      }),
                      onRefresh: _refresh,
                      onCreate: () {
                        _tabs.animateTo(1);
                        setState(() => _page = 0);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: SchoolSummaryCards(
                        activeCount: data.totalActive,
                        applicationsCount: data.totalApplications,
                        suspendedCount: data.totalSuspended,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: SchoolStatusTabs(
                        controller: _tabs,
                        activeCount: data.totalActive,
                        applicationsCount: data.totalApplications,
                        suspendedCount: data.totalSuspended,
                      ),
                    ),
                    if (_tabs.index == 2)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: _SuspensionNotice(),
                      ),
                  ],
                ),
              ),
              _body(context, state, data),
            ],
          );
        },
      ),
    ),
  );

  Widget _body(
    BuildContext context,
    SuperAdminState state,
    _SchoolsViewData data,
  ) {
    if (state.status == SuperAdminStatus.loading &&
        state.schools.isEmpty &&
        state.applications.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: SchoolPulseLoader()),
      );
    }
    if (state.status == SuperAdminStatus.failure &&
        state.schools.isEmpty &&
        state.applications.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _CompactState(
          message: state.errorMessage ?? 'Unable to load schools.',
          onRetry: _refresh,
        ),
      );
    }

    switch (_tabs.index) {
      case 0:
        return _SchoolTableSection(
          rows: data.active,
          plans: state.plans,
          page: _page,
          pageSize: _pageSize,
          onPageChanged: (value) => setState(() => _page = value),
          emptyTitle: 'No active schools yet',
          emptyMessage:
              'Approved and active schools will appear here.\n'
              'Register your first school to get started.',
          emptyActionLabel: 'Register first school',
          onEmptyAction: () {
            _tabs.animateTo(1);
            setState(() => _page = 0);
          },
          kind: _SchoolRowKind.active,
        );
      case 1:
        return _ApplicationsTableSection(
          rows: data.applications,
          page: _page,
          pageSize: _pageSize,
          onPageChanged: (value) => setState(() => _page = value),
        );
      default:
        return _SchoolTableSection(
          rows: data.suspended,
          plans: state.plans,
          logs: state.auditLogs,
          page: _page,
          pageSize: _pageSize,
          onPageChanged: (value) => setState(() => _page = value),
          emptyTitle: 'No suspended schools',
          emptyMessage:
              'Temporarily suspended schools will appear here.\n'
              'Suspension keeps their data safe while restricting access.',
          emptyActionLabel: null,
          onEmptyAction: null,
          kind: _SchoolRowKind.suspended,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Header: title + count pill + search + filter + refresh + Register school
// ---------------------------------------------------------------------------

class PlatformSchoolsHeader extends StatelessWidget {
  const PlatformSchoolsHeader({
    super.key,
    required this.tabIndex,
    required this.activeCount,
    required this.applicationsCount,
    required this.suspendedCount,
    required this.onRefresh,
    required this.onCreate,
    this.controller,
    this.filter = SchoolFilter.all,
    this.onQueryChanged,
    this.onFilterChanged,
  });

  final int tabIndex, activeCount, applicationsCount, suspendedCount;
  final VoidCallback onRefresh, onCreate;
  final TextEditingController? controller;
  final SchoolFilter filter;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<SchoolFilter>? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final total = activeCount + applicationsCount + suspendedCount;
    final wide = isSuperAdminWide(context);
    // When no query/filter wiring is supplied the header renders as a bare
    // title bar (used by lightweight harnesses); the live screen always wires
    // these so search + filter sit inline as in the reference.
    final showControls = onQueryChanged != null && onFilterChanged != null;

    final search = _SearchField(
      controller: controller,
      onChanged: onQueryChanged ?? (_) {},
    );
    final filterButton = _FilterButton(
      filter: filter,
      tabIndex: tabIndex,
      onSelected: onFilterChanged ?? (_) {},
    );
    final refreshButton = _IconAction(
      icon: Icons.refresh_rounded,
      tooltip: 'Refresh schools',
      onTap: onRefresh,
    );
    final registerButton = _RegisterSchoolButton(onTap: onCreate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              _CountPill(label: '$total total', color: AppColors.textMuted(context)),
              if (wide && showControls) ...[
                const Spacer(),
                SizedBox(width: 320, child: search),
                const SizedBox(width: 10),
                filterButton,
                const SizedBox(width: 8),
                registerButton,
                const SizedBox(width: 8),
                refreshButton,
              ] else if (wide) ...[
                const Spacer(),
                registerButton,
                const SizedBox(width: 8),
                refreshButton,
              ],
            ],
          ),
          if (!wide && showControls) ...[
            const SizedBox(height: 12),
            search,
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: filterButton),
                const SizedBox(width: 8),
                refreshButton,
                const SizedBox(width: 8),
                Expanded(flex: 2, child: registerButton),
              ],
            ),
          ] else if (!wide) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                refreshButton,
                const SizedBox(width: 8),
                Expanded(child: registerButton),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    style: AppTypography.bodyMedium.copyWith(
      color: AppColors.textPrimary(context),
      fontSize: 14,
    ),
    decoration: InputDecoration(
      hintText: 'Search by name, code, email, district or tenant ID',
      hintStyle: _body(context),
      prefixIcon: Icon(
        Icons.search_rounded,
        color: AppColors.textSecondary(context),
        size: 20,
      ),
      isDense: true,
      filled: true,
      fillColor: AppColors.surfaceElevated(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.information(context), width: 1.4),
      ),
    ),
  );
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.filter,
    required this.tabIndex,
    required this.onSelected,
  });
  final SchoolFilter filter;
  final int tabIndex;
  final ValueChanged<SchoolFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = filter != SchoolFilter.all;
    return PopupMenuButton<SchoolFilter>(
      tooltip: 'Filter schools',
      onSelected: onSelected,
      itemBuilder: (_) => _filterOptions(tabIndex)
          .map(
            (option) => PopupMenuItem(value: option.$1, child: Text(option.$2)),
          )
          .toList(),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.informationSurface(context)
              : AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? AppColors.information(context)
                : AppColors.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: active
                  ? AppColors.information(context)
                  : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active
                    ? AppColors.information(context)
                    : AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterSchoolButton extends StatelessWidget {
  const _RegisterSchoolButton({required this.onTap, this.label = 'Register school'});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final blue = AppColors.information(context);
    return Material(
      color: blue,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(icon, size: 19, color: AppColors.textPrimary(context)),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Summary cards
// ---------------------------------------------------------------------------

class SchoolSummaryCards extends StatelessWidget {
  const SchoolSummaryCards({
    super.key,
    required this.activeCount,
    required this.applicationsCount,
    required this.suspendedCount,
  });
  final int activeCount, applicationsCount, suspendedCount;

  @override
  Widget build(BuildContext context) {
    final total = activeCount + applicationsCount + suspendedCount;
    String pct(int value) => total == 0
        ? '0%'
        : '${(value / total * 100).toStringAsFixed(1).replaceAll('.0', '')}%';

    final cards = <Widget>[
      _SummaryCard(
        icon: Icons.apartment_rounded,
        iconColor: AppColors.success(context),
        title: 'Active schools',
        value: '$activeCount',
        badge: pct(activeCount),
        badgeColor: AppColors.success(context),
        caption: 'All approved and active schools',
      ),
      _SummaryCard(
        icon: Icons.description_outlined,
        iconColor: AppColors.information(context),
        title: 'Applications',
        value: '$applicationsCount',
        badge: pct(applicationsCount),
        badgeColor: AppColors.information(context),
        caption: 'Pending review and approval',
      ),
      _SummaryCard(
        icon: Icons.pause_circle_outline_rounded,
        iconColor: AppColors.danger(context),
        title: 'Suspended',
        value: '$suspendedCount',
        badge: pct(suspendedCount),
        badgeColor: AppColors.danger(context),
        caption: 'Temporarily suspended schools',
      ),
    ];

    if (isSuperAdminWide(context)) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i != 0) const SizedBox(width: 16),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i != 0) const SizedBox(height: 12),
          cards[i],
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.caption,
  });
  final IconData icon;
  final Color iconColor, badgeColor;
  final String title, value, badge, caption;

  @override
  Widget build(BuildContext context) => PulseCard(
    padding: const EdgeInsets.all(16),
    borderRadius: 12,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _label(context).copyWith(fontSize: 12.5),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: _pageTitle(context).copyWith(fontSize: 24)),
                ],
              ),
            ),
            _CountPill(label: badge, color: badgeColor),
          ],
        ),
        const SizedBox(height: 10),
        Text(caption, style: _body(context)),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Tabs
// ---------------------------------------------------------------------------

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
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: AppColors.border(context)),
      ),
    ),
    child: TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.information(context), width: 2.5),
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
  );
}

/// Retained for source compatibility with earlier call sites / tests: the
/// search box and filter control now live inside [PlatformSchoolsHeader], but
/// this standalone composite still renders both and forwards their callbacks
/// through the exact same [SchoolFilter] / query contract.
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
        child: _SearchField(controller: controller, onChanged: onChanged),
      ),
      const SizedBox(width: 8),
      _FilterButton(
        filter: filter,
        tabIndex: tabIndex,
        onSelected: onFilterChanged,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Data table sections (desktop table / mobile card list) + pagination
// ---------------------------------------------------------------------------

enum _SchoolRowKind { active, suspended }

class _SchoolTableSection extends StatelessWidget {
  const _SchoolTableSection({
    required this.rows,
    required this.plans,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyActionLabel,
    required this.onEmptyAction,
    required this.kind,
    this.logs = const [],
  });
  final List<School> rows;
  final List<SubscriptionPlan> plans;
  final List<AuditLog> logs;
  final int page, pageSize;
  final ValueChanged<int> onPageChanged;
  final String emptyTitle, emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final _SchoolRowKind kind;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _IllustratedEmpty(
          title: emptyTitle,
          message: emptyMessage,
          actionLabel: emptyActionLabel,
          onAction: onEmptyAction,
        ),
      );
    }

    final pageCount = (rows.length + pageSize - 1) ~/ pageSize;
    final safePage = page.clamp(0, pageCount - 1);
    final start = safePage * pageSize;
    final visible = rows.sublist(
      start,
      (start + pageSize).clamp(0, rows.length),
    );
    final wide = isSuperAdminWide(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            PulseCard(
              padding: EdgeInsets.zero,
              borderRadius: 12,
              child: Column(
                children: [
                  if (wide) const _SchoolTableHeaderRow(),
                  for (var i = 0; i < visible.length; i++)
                    _SchoolDataRow(
                      school: visible[i],
                      plan: _planFor(visible[i], plans),
                      audit: _latestSuspensionLog(visible[i], logs),
                      kind: kind,
                      wide: wide,
                      isLast: i == visible.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PaginationBar(
              page: safePage,
              pageCount: pageCount,
              rangeStart: start + 1,
              rangeEnd: start + visible.length,
              total: rows.length,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolTableHeaderRow extends StatelessWidget {
  const _SchoolTableHeaderRow();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer(context),
      border: Border(bottom: BorderSide(color: AppColors.border(context))),
    ),
    child: Row(
      children: const [
        Expanded(flex: 26, child: _HeaderCell('School')),
        Expanded(flex: 12, child: _HeaderCell('School code')),
        Expanded(flex: 16, child: _HeaderCell('Location')),
        Expanded(flex: 10, child: _HeaderCell('Students')),
        Expanded(flex: 14, child: _HeaderCell('Plan')),
        Expanded(flex: 14, child: _HeaderCell('Payment status')),
        Expanded(flex: 14, child: _HeaderCell('Account status')),
        SizedBox(width: 40, child: _HeaderCell('', center: true)),
      ],
    ),
  );
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.center = false});
  final String label;
  final bool center;

  @override
  Widget build(BuildContext context) => Text(
    label,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: _label(context).copyWith(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: .2,
    ),
  );
}

class _SchoolDataRow extends StatelessWidget {
  const _SchoolDataRow({
    required this.school,
    required this.plan,
    required this.audit,
    required this.kind,
    required this.wide,
    required this.isLast,
  });
  final School school;
  final SubscriptionPlan? plan;
  final AuditLog? audit;
  final _SchoolRowKind kind;
  final bool wide, isLast;

  @override
  Widget build(BuildContext context) {
    final payment = _paymentStatusFor(school);
    final account = _accountStatusFor(school, kind);
    final border = isLast
        ? null
        : Border(bottom: BorderSide(color: AppColors.border(context)));

    if (!wide) {
      return _MobileSchoolCard(
        school: school,
        plan: plan,
        audit: audit,
        kind: kind,
        payment: payment,
        account: account,
        border: border,
      );
    }

    return InkWell(
      onTap: () => _openSchool(context, school),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: border),
        child: Row(
          children: [
            Expanded(
              flex: 26,
              child: _SchoolIdentityCell(school: school, kind: kind),
            ),
            Expanded(
              flex: 12,
              child: Text(_schoolCode(school), style: _cellText(context)),
            ),
            Expanded(
              flex: 16,
              child: Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _location(school),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _cellText(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Text(_studentCount(school), style: _cellText(context)),
            ),
            Expanded(
              flex: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan?.name ?? _fallbackPlan(school),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cellText(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _renewsLabel(school),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _label(context),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 14,
              child: _StatusStack(
                chip: payment.chip(context),
                caption: payment.caption,
              ),
            ),
            Expanded(
              flex: 14,
              child: _StatusStack(
                chip: account.chip(context),
                caption: account.caption,
              ),
            ),
            SizedBox(
              width: 40,
              child: _RowOverflowMenu(school: school, kind: kind),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileSchoolCard extends StatelessWidget {
  const _MobileSchoolCard({
    required this.school,
    required this.plan,
    required this.audit,
    required this.kind,
    required this.payment,
    required this.account,
    required this.border,
  });
  final School school;
  final SubscriptionPlan? plan;
  final AuditLog? audit;
  final _SchoolRowKind kind;
  final _StatusView payment, account;
  final Border? border;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _openSchool(context, school),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SchoolIdentityCell(school: school, kind: kind),
              ),
              _RowOverflowMenu(school: school, kind: kind),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _MiniField(label: 'Code', value: _schoolCode(school)),
              _MiniField(label: 'Location', value: _location(school)),
              _MiniField(label: 'Students', value: _studentCount(school)),
              _MiniField(
                label: 'Plan',
                value: plan?.name ?? _fallbackPlan(school),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatusStack(
                  chip: payment.chip(context),
                  caption: payment.caption,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusStack(
                  chip: account.chip(context),
                  caption: account.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SchoolIdentityCell extends StatelessWidget {
  const _SchoolIdentityCell({required this.school, required this.kind});
  final School school;
  final _SchoolRowKind kind;

  @override
  Widget build(BuildContext context) {
    final color = switch (kind) {
      _SchoolRowKind.suspended => AppColors.danger(context),
      _ => school.status == SchoolStatus.active
          ? AppColors.information(context)
          : AppColors.warning(context),
    };
    return Row(
      children: [
        _Avatar(label: _initials(school.name), color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _schoolName(school),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _cardTitle(context).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                _adminValue(school),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _label(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RowOverflowMenu extends StatelessWidget {
  const _RowOverflowMenu({required this.school, required this.kind});
  final School school;
  final _SchoolRowKind kind;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'School actions',
    icon: Icon(
      Icons.more_vert_rounded,
      size: 20,
      color: AppColors.textSecondary(context),
    ),
    onSelected: (value) {
      switch (value) {
        case 'open':
          _openSchool(context, school);
        case 'suspend':
          _confirmSuspend(context, school);
        case 'restore':
          _confirmRestore(context, school);
      }
    },
    itemBuilder: (_) => [
      const PopupMenuItem(value: 'open', child: Text('View school')),
      if (kind == _SchoolRowKind.active)
        const PopupMenuItem(value: 'suspend', child: Text('Suspend school'))
      else
        const PopupMenuItem(value: 'restore', child: Text('Restore school')),
    ],
  );
}

class _StatusStack extends StatelessWidget {
  const _StatusStack({required this.chip, required this.caption});
  final Widget chip;
  final String caption;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      chip,
      if (caption.isNotEmpty) ...[
        const SizedBox(height: 3),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _label(context),
        ),
      ],
    ],
  );
}

class _MiniField extends StatelessWidget {
  const _MiniField({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: _label(context)),
      const SizedBox(height: 2),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textPrimary(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageCount,
    required this.rangeStart,
    required this.rangeEnd,
    required this.total,
    required this.onPageChanged,
  });
  final int page, pageCount, rangeStart, rangeEnd, total;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);
    final label = Text(
      'Showing $rangeStart to $rangeEnd of $total',
      style: _body(context),
    );
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageChevron(
          icon: Icons.first_page_rounded,
          enabled: page > 0,
          onTap: () => onPageChanged(0),
        ),
        _PageChevron(
          icon: Icons.chevron_left_rounded,
          enabled: page > 0,
          onTap: () => onPageChanged(page - 1),
        ),
        for (final index in _pageWindow(page, pageCount))
          _PageNumber(
            index: index,
            selected: index == page,
            onTap: () => onPageChanged(index),
          ),
        _PageChevron(
          icon: Icons.chevron_right_rounded,
          enabled: page < pageCount - 1,
          onTap: () => onPageChanged(page + 1),
        ),
        _PageChevron(
          icon: Icons.last_page_rounded,
          enabled: page < pageCount - 1,
          onTap: () => onPageChanged(pageCount - 1),
        ),
      ],
    );

    if (wide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [label, controls],
      );
    }
    return Column(
      children: [
        label,
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: controls,
        ),
      ],
    );
  }

  static List<int> _pageWindow(int page, int pageCount) {
    if (pageCount <= 5) return [for (var i = 0; i < pageCount; i++) i];
    var start = page - 2;
    if (start < 0) start = 0;
    var end = start + 5;
    if (end > pageCount) {
      end = pageCount;
      start = end - 5;
    }
    return [for (var i = start; i < end; i++) i];
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Material(
      color: selected
          ? AppColors.information(context)
          : AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.information(context)
                  : AppColors.border(context),
            ),
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textPrimary(context),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PageChevron extends StatelessWidget {
  const _PageChevron({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Material(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? AppColors.textPrimary(context)
                : AppColors.textMuted(context),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Applications table section
// ---------------------------------------------------------------------------

class _ApplicationsTableSection extends StatelessWidget {
  const _ApplicationsTableSection({
    required this.rows,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
  });
  final List<SchoolApplication> rows;
  final int page, pageSize;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _IllustratedEmpty(
          title: 'No school applications',
          message:
              'New applications will appear here as schools apply.\n'
              'Review pending applications to approve or reject them.',
          actionLabel: null,
          onAction: null,
        ),
      );
    }

    final pageCount = (rows.length + pageSize - 1) ~/ pageSize;
    final safePage = page.clamp(0, pageCount - 1);
    final start = safePage * pageSize;
    final visible = rows.sublist(
      start,
      (start + pageSize).clamp(0, rows.length),
    );
    final wide = isSuperAdminWide(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            PulseCard(
              padding: EdgeInsets.zero,
              borderRadius: 12,
              child: Column(
                children: [
                  if (wide) const _ApplicationHeaderRow(),
                  for (var i = 0; i < visible.length; i++)
                    _ApplicationDataRow(
                      application: visible[i],
                      wide: wide,
                      isLast: i == visible.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PaginationBar(
              page: safePage,
              pageCount: pageCount,
              rangeStart: start + 1,
              rangeEnd: start + visible.length,
              total: rows.length,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationHeaderRow extends StatelessWidget {
  const _ApplicationHeaderRow();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer(context),
      border: Border(bottom: BorderSide(color: AppColors.border(context))),
    ),
    child: Row(
      children: const [
        Expanded(flex: 30, child: _HeaderCell('School')),
        Expanded(flex: 22, child: _HeaderCell('Applicant contact')),
        Expanded(flex: 16, child: _HeaderCell('Requested plan')),
        Expanded(flex: 18, child: _HeaderCell('Verification')),
        SizedBox(width: 96, child: _HeaderCell('', center: true)),
      ],
    ),
  );
}

class _ApplicationDataRow extends StatelessWidget {
  const _ApplicationDataRow({
    required this.application,
    required this.wide,
    required this.isLast,
  });
  final SchoolApplication application;
  final bool wide, isLast;

  @override
  Widget build(BuildContext context) {
    final border = isLast
        ? null
        : Border(bottom: BorderSide(color: AppColors.border(context)));
    final verified = application.administratorEmailVerified;

    final identity = Row(
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
                style: _cardTitle(context).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                _applicationLocation(application),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _label(context),
              ),
            ],
          ),
        ),
      ],
    );

    final verificationChip = _Chip(
      label: _verification(application),
      color: verified
          ? AppColors.success(context)
          : AppColors.warning(context),
    );

    final reviewButton = OutlinedButton(
      onPressed: () => _openApplication(context, application),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.information(context),
        side: BorderSide(color: AppColors.information(context)),
        minimumSize: const Size(72, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Review'),
    );

    if (!wide) {
      return InkWell(
        onTap: () => _openApplication(context, application),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: border),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              identity,
              const SizedBox(height: 12),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _MiniField(
                    label: 'Applicant contact',
                    value: _applicationContact(application),
                  ),
                  _MiniField(
                    label: 'Requested plan',
                    value: application.plan.isEmpty
                        ? 'Not selected'
                        : application.plan,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [verificationChip, reviewButton],
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _openApplication(context, application),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: border),
        child: Row(
          children: [
            Expanded(flex: 30, child: identity),
            Expanded(
              flex: 22,
              child: Text(
                _applicationContact(application),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _cellText(context),
              ),
            ),
            Expanded(
              flex: 16,
              child: Text(
                application.plan.isEmpty ? 'Not selected' : application.plan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _cellText(context),
              ),
            ),
            Expanded(
              flex: 18,
              child: Align(
                alignment: Alignment.centerLeft,
                child: verificationChip,
              ),
            ),
            SizedBox(
              width: 96,
              child: Align(
                alignment: Alignment.centerRight,
                child: reviewButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _SuspensionNotice extends StatelessWidget {
  const _SuspensionNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.dangerSurface(context),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: AppColors.danger(context).withValues(alpha: .3),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 18,
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

class _IllustratedEmpty extends StatelessWidget {
  const _IllustratedEmpty({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.informationSurface(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_rounded,
              size: 34,
              color: AppColors.information(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: _cardTitle(context)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _body(context),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            _RegisterSchoolButton(onTap: onAction!, label: actionLabel!),
          ],
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
      horizontal: compact ? 7 : 9,
      vertical: compact ? 2 : 4,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? 11.5 : 12.5,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
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
    width: 36,
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800),
    ),
  );
}

// ---------------------------------------------------------------------------
// View model + status derivation
// ---------------------------------------------------------------------------

class _StatusView {
  const _StatusView({
    required this.label,
    required this.color,
    required this.caption,
  });
  final String label, caption;
  final Color Function(BuildContext) color;

  Widget chip(BuildContext context) => _Chip(label: label, color: color(context));
}

/// Payment status derived from the same server-written signals the detail
/// screen uses ([School.accessMode] + [School.subscriptionExpiry]). Green is
/// reserved for paid, red for overdue.
_StatusView _paymentStatusFor(School school) {
  final expiry = school.subscriptionExpiry;
  final overdue =
      school.accessMode == 'blocked' ||
      school.accessMode == 'readOnly' ||
      expiry.isBefore(DateTime.now());
  if (overdue) {
    return _StatusView(
      label: 'Overdue',
      color: (c) => AppColors.danger(c),
      caption: 'Due since ${DateFormat('MMM d, y').format(expiry)}',
    );
  }
  return _StatusView(
    label: 'Paid',
    color: (c) => AppColors.success(c),
    caption: 'Next due: ${DateFormat('MMM d, y').format(expiry)}',
  );
}

_StatusView _accountStatusFor(School school, _SchoolRowKind kind) {
  if (kind == _SchoolRowKind.suspended ||
      school.status == SchoolStatus.suspended ||
      school.status == SchoolStatus.archived) {
    return _StatusView(
      label: 'Suspended',
      color: (c) => AppColors.danger(c),
      caption: school.subscriptionExpiry.isBefore(DateTime.now())
          ? 'Overdue'
          : 'Restricted',
    );
  }
  final overdue = school.subscriptionExpiry.isBefore(DateTime.now());
  return _StatusView(
    label: 'Active',
    color: (c) => AppColors.success(c),
    caption: overdue ? 'Overdue' : 'Healthy',
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

Future<void> _confirmSuspend(BuildContext context, School school) async {
  final suspend = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Suspend school?'),
      content: Text(
        '${_schoolName(school)} will lose access while its data is preserved. '
        'This action is logged.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialog, true),
          child: const Text('Suspend'),
        ),
      ],
    ),
  );
  if (suspend == true && context.mounted) {
    context.read<SuperAdminBloc>().add(
      UpdateSchoolStatusEvent(
        schoolId: school.id,
        status: SchoolStatus.suspended,
      ),
    );
  }
}

String _schoolName(School school) =>
    school.name.trim().isEmpty ? 'Unnamed school' : school.name;

String _schoolCode(School school) {
  final prefix = school.metadata['prefix']?.toString().trim();
  if (prefix != null && prefix.isNotEmpty) return prefix;
  final code = school.metadata['code']?.toString().trim();
  if (code != null && code.isNotEmpty) return code;
  return school.tenantId.isEmpty ? '—' : school.tenantId;
}

String _studentCount(School school) {
  final raw =
      school.metadata['studentCount'] ?? school.metadata['students'] ?? 0;
  final count = raw is num ? raw.toInt() : int.tryParse('$raw') ?? 0;
  return count == 0 ? '—' : NumberFormat.decimalPattern().format(count);
}

String _renewsLabel(School school) =>
    'Renews: ${DateFormat('MMM d, y').format(school.subscriptionExpiry)}';

String _location(School school) {
  final district = school.metadata['district']?.toString().trim();
  return district?.isNotEmpty == true
      ? district!
      : (school.address.trim().isEmpty
            ? 'Location unavailable'
            : school.address);
}

String _adminValue(School school) =>
    school.metadata['adminName']?.toString().trim().isNotEmpty == true
    ? school.metadata['adminName'].toString()
    : (school.contactEmail.isEmpty ? 'Contact unavailable' : school.contactEmail);

String _fallbackPlan(School school) => school.subscriptionPlanId.isEmpty
    ? 'Unassigned'
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
      fontSize: 24,
      fontWeight: FontWeight.w800,
    );

TextStyle _cardTitle(BuildContext context) =>
    AppTypography.titleMedium.copyWith(
      color: AppColors.textPrimary(context),
      fontSize: 16,
      fontWeight: FontWeight.w800,
    );

TextStyle _label(BuildContext context) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(context),
  fontSize: 11.5,
);

TextStyle _body(BuildContext context) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(context),
  fontSize: 13,
);

TextStyle _cellText(BuildContext context) => AppTypography.bodySmall.copyWith(
  color: AppColors.textPrimary(context),
  fontSize: 13,
  fontWeight: FontWeight.w500,
);
