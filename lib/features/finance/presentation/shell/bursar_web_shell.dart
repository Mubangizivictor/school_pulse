import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import 'package:school_pulse/injection_container.dart';
import 'bursar_top_bar.dart';

// Section screens.
import 'package:school_pulse/features/finance/presentation/screens/web/bursar_web_overview_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_student_lookup_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_cash_bank_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/budget_details_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/expenditure_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_suppliers_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_petty_cash_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_payroll_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/financial_reports_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_audit_trail_screen.dart';

/// The Bursar console for tablet-rail-and-up widths (used by `BursarShell`'s
/// `ResponsiveBuilder` branch at >= 1024px; the tablet 600-1023 branch uses
/// the same widget with a narrower sidebar).
///
/// Structure mirrors `SuperAdminDashboard`: a fixed left sidebar + a top bar
/// + an `IndexedStack` of per-section nested `Navigator`s, with the active
/// section derived from the URL so every section is deep-linkable and
/// refresh-safe on web.
class BursarWebShell extends StatefulWidget {
  /// When true (tablet), the sidebar collapses to an icon rail.
  final bool compact;

  /// A deep-linked student statement. Keeping it in this shell preserves the
  /// finance navigation chrome on every bursar route.
  final Widget? studentDetail;

  const BursarWebShell({super.key, this.compact = false, this.studentDetail});

  @override
  State<BursarWebShell> createState() => _BursarWebShellState();
}

enum _Section {
  overview('overview', 'Finance overview', Icons.pie_chart_outline_rounded),
  students('students', 'Students & fees', Icons.people_outline_rounded),
  approvals('approvals', 'Approvals', Icons.verified_outlined),
  cashBank('cash-bank', 'Cash & bank', Icons.account_balance_outlined),
  budget('budget', 'Budget', Icons.bar_chart_rounded),
  expenses('expenses', 'Expenses', Icons.description_outlined),
  suppliers('suppliers', 'Suppliers', Icons.local_shipping_outlined),
  pettyCash('petty-cash', 'Petty cash', Icons.account_balance_wallet_outlined),
  payroll('payroll', 'Payroll & compliance', Icons.badge_outlined),
  reports('reports', 'Reports', Icons.assessment_outlined),
  audit('audit', 'Audit trail', Icons.fact_check_outlined);

  const _Section(this.slug, this.label, this.icon);
  final String slug;
  final String label;
  final IconData icon;
}

const _mainNav = [
  _Section.overview,
  _Section.students,
  _Section.approvals,
  _Section.cashBank,
];
const _toolsNav = [
  _Section.budget,
  _Section.expenses,
  _Section.suppliers,
  _Section.pettyCash,
  _Section.payroll,
  _Section.reports,
  _Section.audit,
];

class _BursarWebShellState extends State<BursarWebShell> {
  final _navKeys = {
    for (final s in _Section.values) s: GlobalKey<NavigatorState>(),
  };
  String _termLabel = 'This term';

  @override
  void initState() {
    super.initState();
    _loadTerm();
  }

  Future<void> _loadTerm() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    try {
      final period = await sl<AcademicCalendarService>().getCurrentPeriod(
        auth.user.schoolId,
      );
      if (!mounted) return;
      final year = period.academicYearName;
      final term = period.termName;
      if (term.isNotEmpty || year.isNotEmpty) {
        setState(
          () => _termLabel = [term, year].where((s) => s.isNotEmpty).join(', '),
        );
      }
    } catch (_) {
      // Keep the fallback label.
    }
  }

  _Section _sectionForLocation(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    for (final s in _Section.values) {
      if (path == '/staff/bursar/${s.slug}') return s;
    }
    if (path.startsWith('/staff/bursar/student/')) return _Section.students;
    if (path.startsWith('/staff/bursar/students')) return _Section.students;
    if (path.startsWith('/staff/bursar/approvals')) return _Section.approvals;
    return _Section.overview;
  }

  Widget _screenFor(_Section s) {
    switch (s) {
      case _Section.overview:
        return const BursarWebOverviewScreen();
      case _Section.students:
        return widget.studentDetail ?? const BursarStudentLookupScreen();
      case _Section.approvals:
        return const BursarApprovalsScreen();
      case _Section.cashBank:
        return const BursarCashBankScreen();
      case _Section.budget:
        return const BudgetDetailsScreen();
      case _Section.expenses:
        return const ExpenditureScreen();
      case _Section.suppliers:
        return const BursarSuppliersScreen();
      case _Section.pettyCash:
        return const BursarPettyCashScreen();
      case _Section.payroll:
        return const BursarPayrollScreen();
      case _Section.reports:
        return const FinancialReportsScreen();
      case _Section.audit:
        return const BursarAuditTrailScreen();
    }
  }

  void _go(_Section s) {
    final current = _sectionForLocation(context);
    if (current == s) {
      _navKeys[s]!.currentState?.popUntil((r) => r.isFirst);
      return;
    }
    context.go('/staff/bursar/${s.slug}');
  }

  @override
  Widget build(BuildContext context) {
    final active = _sectionForLocation(context);
    final sidebarWidth = widget.compact ? 76.0 : 248.0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sidebar(
            width: sidebarWidth,
            compact: widget.compact,
            active: active,
            onSelect: _go,
          ),
          Expanded(
            child: Column(
              children: [
                BursarTopBar(sectionLabel: active.label, termLabel: _termLabel),
                Expanded(
                  child: IndexedStack(
                    index: _Section.values.indexOf(active),
                    children: [
                      for (final s in _Section.values)
                        Navigator(
                          key: _navKeys[s],
                          onGenerateRoute: (rs) => MaterialPageRoute(
                            builder: (_) => _screenFor(s),
                            settings: rs,
                          ),
                        ),
                    ],
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

class _Sidebar extends StatelessWidget {
  final double width;
  final bool compact;
  final _Section active;
  final ValueChanged<_Section> onSelect;

  const _Sidebar({
    required this.width,
    required this.compact,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(right: BorderSide(color: AppColors.border(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 16, 18, 16, 16),
            child: _SchoolHeader(compact: compact),
          ),
          Divider(height: 1, color: AppColors.border(context)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
              children: [
                if (!compact) _GroupLabel('MAIN'),
                for (final s in _mainNav)
                  _Item(
                    section: s,
                    compact: compact,
                    selected: s == active,
                    onTap: () => onSelect(s),
                  ),
                const SizedBox(height: 14),
                if (!compact) _GroupLabel('FINANCE TOOLS'),
                for (final s in _toolsNav)
                  _Item(
                    section: s,
                    compact: compact,
                    selected: s == active,
                    onTap: () => onSelect(s),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border(context)),
          _FooterRow(compact: compact),
        ],
      ),
    );
  }
}

/// School badge + name at the top of the sidebar, from the live
/// [BrandingBloc] (falls back to the auth user's `schoolName`).
class _SchoolHeader extends StatelessWidget {
  final bool compact;
  const _SchoolHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    final brandingState = context.watch<BrandingBloc>().state;
    final branding = brandingState is BrandingLoaded
        ? brandingState.branding
        : null;
    final auth = context.watch<AuthBloc>().state;
    final name = branding?.schoolName.isNotEmpty == true
        ? branding!.schoolName
        : (auth is AuthAuthenticated
              ? (auth.user.schoolName ?? 'School Pulse')
              : 'School Pulse');
    final badge = SchoolBadge(
      badgeUrl: branding?.badgeUrl ?? branding?.logoUrl,
      size: compact ? 34 : 30,
    );

    if (compact) return Center(child: badge);

    return Row(
      children: [
        badge,
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textMuted(context),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final _Section section;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  const _Item({
    required this.section,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? AppColors.background(context)
        : AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? AppColors.primary(context) : Colors.transparent,
        borderRadius: AppRadius.medium,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.medium,
          child: Tooltip(
            message: compact ? section.label : '',
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 0 : 12,
                vertical: 9,
              ),
              child: Row(
                mainAxisAlignment: compact
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(section.icon, size: 19, color: fg),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        section.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  final bool compact;
  const _FooterRow({required this.compact});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth is AuthAuthenticated ? auth.user.name : 'Bursar';
    final initials = name.trim().isEmpty
        ? 'B'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join();

    return InkWell(
      onTap: () => _confirmLogout(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 18,
          vertical: 16,
        ),
        child: Row(
          mainAxisAlignment: compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary(context),
              ),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background(context),
                ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Bursar',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(dialogContext);
              context.go('/welcome');
            },
            child: Text(
              'Sign out',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
  }
}
