import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/datasources/entitlements_remote_data_source.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_forms.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart';

const _financeRoles = {'bursar', 'schoolAdmin', 'headTeacher', 'director'};
const _leadershipRoles = {'schoolAdmin', 'headTeacher', 'director'};

/// The 12 fee-gateable services (safety services can never appear here).
const kEntitlementServices = <String, String>{
  'dining': 'Dining & meals',
  'boarding': 'Boarding',
  'transport': 'School transport',
  'internalExams': 'Internal examinations',
  'reportCards': 'Report cards',
  'library': 'Library borrowing',
  'ict': 'ICT & printing',
  'practicals': 'Practical materials',
  'activities': 'Sports & clubs',
  'trips': 'Trips & excursions',
  'remedial': 'Remedial classes',
  'certificates': 'Certificates',
};

/// Bursar Financial Entitlements workspace — learner filter table, learner /
/// service detail panel, bulk grant/revoke/renew, the service-policy
/// builder, and the entitlement reports. Reads `student_financials` for the
/// filter bands (matching the server's `compute()` derivation) and drives
/// every write through the deployed `financial_entitlements.js` callables.
class FinancialEntitlementsScreen extends StatefulWidget {
  const FinancialEntitlementsScreen({super.key});

  @override
  State<FinancialEntitlementsScreen> createState() =>
      _FinancialEntitlementsScreenState();
}

class _FinancialEntitlementsScreenState
    extends State<FinancialEntitlementsScreen> {
  _EntitlementsController? _ctl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _ctl = _EntitlementsController(
        schoolId: auth.user.schoolId,
        roles: auth.user.roles.map((r) => r.name).toSet(),
        ds: sl<EntitlementsRemoteDataSource>(),
        students: sl<StudentRepository>(),
      )..load();
    }
  }

  @override
  void dispose() {
    _ctl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated ||
        !auth.user.roles.map((r) => r.name).any(_financeRoles.contains)) {
      return const FinanceScaffold(
        title: 'Financial entitlements',
        body: Center(
          child: Text(
            'You do not have permission to view financial entitlements.',
          ),
        ),
      );
    }
    final ctl = _ctl!;
    return AnimatedBuilder(
      animation: ctl,
      builder: (context, _) => ResponsiveBuilder(
        builder: (context, layout) {
          if (layout == ResponsiveLayout.mobile) {
            return _MobileView(ctl: ctl);
          }
          return _WideView(ctl: ctl, tablet: layout == ResponsiveLayout.tablet);
        },
      ),
    );
  }
}

// ===========================================================================
//  Controller — filter state + loaded data
// ===========================================================================

class _EntitlementsController extends ChangeNotifier {
  final String schoolId;
  final Set<String> roles;
  final EntitlementsRemoteDataSource ds;
  final StudentRepository students;

  _EntitlementsController({
    required this.schoolId,
    required this.roles,
    required this.ds,
    required this.students,
  });

  bool get isLeadership => roles.any(_leadershipRoles.contains);

  // ---- loaded data
  bool loading = true;
  String? error;
  Map<String, dynamic> policy = const {};
  List<Student> allStudents = const [];
  Map<String, LearnerFinancials> financials = const {};

  // ---- filters
  String? classId;
  String? streamId;
  String? boarding; // 'boarding' | 'day' | null
  final Set<int> bands = {}; // 0..5
  RangeValues? balanceRange; // in UGX
  bool onlyScholarship = false;
  bool onlyWaiver = false;
  bool onlyPaymentPlan = false;
  bool onlyRestricted = false; // has applicableRestrictions
  String query = '';

  // ---- selection
  String? selectedStudentId;
  Map<String, dynamic>? selectedProfile;
  bool profileLoading = false;

  // ---- bulk
  final Set<String> checked = {};

  List<String> get classIds =>
      (allStudents.map((s) => s.classId).toSet().toList()..sort());

  List<Student> get filtered {
    final q = query.trim().toLowerCase();
    return allStudents.where((s) {
      if (classId != null && s.classId != classId) return false;
      if (streamId != null && s.streamId != streamId) return false;
      if (boarding != null) {
        final isBoarding = (s.boardingType?.name ?? '').toLowerCase().contains(
          'board',
        );
        if (boarding == 'boarding' && !isBoarding) return false;
        if (boarding == 'day' && isBoarding) return false;
      }
      final f = financials[s.id];
      if (bands.isNotEmpty && !bands.contains(f?.band ?? 0)) return false;
      if (balanceRange != null) {
        final b = f?.balance ?? 0;
        if (b < balanceRange!.start || b > balanceRange!.end) return false;
      }
      if (onlyScholarship && !(f?.hasScholarship ?? false)) return false;
      if (onlyWaiver && !(f?.hasWaiver ?? false)) return false;
      if (onlyPaymentPlan && !(f?.hasPaymentPlan ?? false)) return false;
      final restricted = f?.applicableRestrictions.isNotEmpty ?? false;
      if (onlyRestricted && !restricted) return false;
      if (q.isNotEmpty &&
          !s.name.toLowerCase().contains(q) &&
          !s.admissionNumber.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  double get maxBalance {
    var m = 0.0;
    for (final f in financials.values) {
      if (f.balance > m) m = f.balance;
    }
    return m <= 0 ? 1000000 : m;
  }

  List<String> get configuredServices =>
      ((policy['services'] as Map?)?.keys.map((e) => '$e').toList() ?? const [])
        ..sort();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await Future.wait([
        ds.policy(schoolId),
        ds.allFinancials(schoolId),
        students.getAllStudents(schoolId: schoolId),
      ]);
      policy = res[0] as Map<String, dynamic>;
      financials = res[1] as Map<String, LearnerFinancials>;
      (res[2] as dynamic).fold(
        (f) => error = 'Could not load learners.',
        (list) => allStudents = list as List<Student>,
      );
    } catch (_) {
      error = 'Could not load the entitlements workspace.';
    }
    loading = false;
    notifyListeners();
  }

  void setFilter(void Function() mutate) {
    mutate();
    notifyListeners();
  }

  Future<void> select(String studentId) async {
    selectedStudentId = studentId;
    selectedProfile = null;
    profileLoading = true;
    notifyListeners();
    try {
      selectedProfile = await ds.learnerProfile(
        schoolId: schoolId,
        studentId: studentId,
      );
    } catch (_) {
      selectedProfile = {'error': true};
    }
    profileLoading = false;
    notifyListeners();
  }

  void clearSelection() {
    selectedStudentId = null;
    selectedProfile = null;
    notifyListeners();
  }

  // ---- reports (CSV strings) ------------------------------------

  String reportCsv(_EntitlementReport report) {
    final f = DateFormat('yyyy-MM-dd');
    final b = StringBuffer()
      ..writeln('"${report.title}"')
      ..writeln('"Generated","${f.format(DateTime.now())}"')
      ..writeln('');
    b.writeln(report.columns.map(_csv).join(','));
    for (final row in report.rows(this)) {
      b.writeln(row.map(_csv).join(','));
    }
    return b.toString();
  }

  static String _csv(String c) {
    final needs = c.contains(',') || c.contains('"') || c.contains('\n');
    final e = c.replaceAll('"', '""');
    return needs ? '"$e"' : e;
  }

  String nameOf(String studentId) => allStudents
      .firstWhere(
        (s) => s.id == studentId,
        orElse: () => allStudents.isEmpty
            ? throw StateError('no students')
            : allStudents.first,
      )
      .name;
}

// ===========================================================================
//  Reports
// ===========================================================================

class _EntitlementReport {
  final String title;
  final List<String> columns;
  final List<List<String>> Function(_EntitlementsController c) rows;
  const _EntitlementReport(this.title, this.columns, this.rows);
}

final _reports = <_EntitlementReport>[
  _EntitlementReport(
    'Blocked learners',
    const ['Learner', 'Class', 'Overall %', 'Balance'],
    (c) => c.filtered.where((s) => (c.financials[s.id]?.balance ?? 0) > 0).map((
      s,
    ) {
      final f = c.financials[s.id];
      return [
        s.name,
        s.classId,
        '${f?.overallPct ?? 0}%',
        CurrencyFormatter.ugx(f?.balance ?? 0),
      ];
    }).toList(),
  ),
  _EntitlementReport(
    'Learners with a scholarship',
    const ['Learner', 'Class', 'Scholarship', 'Overall %'],
    (c) => c.filtered
        .where((s) => c.financials[s.id]?.hasScholarship ?? false)
        .map((s) {
          final f = c.financials[s.id]!;
          return [
            s.name,
            s.classId,
            CurrencyFormatter.ugx(f.scholarshipAmount),
            '${f.overallPct}%',
          ];
        })
        .toList(),
  ),
  _EntitlementReport(
    'Learners on a payment plan',
    const ['Learner', 'Class', 'Plan', 'Balance'],
    (c) => c.filtered
        .where((s) => c.financials[s.id]?.hasPaymentPlan ?? false)
        .map((s) {
          final f = c.financials[s.id]!;
          return [
            s.name,
            s.classId,
            f.feeStructureId ?? '',
            CurrencyFormatter.ugx(f.balance),
          ];
        })
        .toList(),
  ),
  _EntitlementReport(
    'Learners with a restriction flag',
    const ['Learner', 'Class', 'Restrictions'],
    (c) => c.filtered
        .where(
          (s) =>
              (c.financials[s.id]?.applicableRestrictions.isNotEmpty ?? false),
        )
        .map(
          (s) => [
            s.name,
            s.classId,
            c.financials[s.id]!.applicableRestrictions.join('; '),
          ],
        )
        .toList(),
  ),
];

// ===========================================================================
//  Wide (tablet + desktop)
// ===========================================================================

class _WideView extends StatelessWidget {
  final _EntitlementsController ctl;
  final bool tablet;
  const _WideView({required this.ctl, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return FinanceScaffold(
      title: 'Financial entitlements',
      actions: [
        IconButton(
          tooltip: 'Service policies',
          icon: const Icon(Icons.tune_rounded),
          onPressed: () => _openPolicyBuilder(context, ctl),
        ),
        IconButton(
          tooltip: 'Reports',
          icon: const Icon(Icons.assessment_outlined),
          onPressed: () => _openReports(context, ctl),
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: ctl.load,
        ),
      ],
      body: ctl.loading
          ? FinanceStates.loading()
          : ctl.error != null
          ? FinanceStates.error(context, ctl.error!, onRetry: ctl.load)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: tablet ? 220 : 260,
                  child: _FilterPanel(ctl: ctl),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _BulkToolbar(ctl: ctl),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _LearnerTable(ctl: ctl)),
                            if (ctl.selectedStudentId != null)
                              SizedBox(
                                width: 380,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppColors.border(context),
                                      ),
                                    ),
                                  ),
                                  child: _DetailPanel(ctl: ctl),
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

// ===========================================================================
//  Mobile
// ===========================================================================

class _MobileView extends StatelessWidget {
  final _EntitlementsController ctl;
  const _MobileView({required this.ctl});

  @override
  Widget build(BuildContext context) {
    final sel = ctl.selectedStudentId;
    return FinanceScaffold(
      title: sel == null ? 'Financial entitlements' : 'Learner entitlements',
      showBack: true,
      onBack: sel == null ? null : ctl.clearSelection,
      actions: sel != null
          ? null
          : [
              IconButton(
                tooltip: 'Filters',
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _Sheet(
                    title: 'Filters',
                    child: _FilterPanel(ctl: ctl, scrollable: true),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Policies',
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => _openPolicyBuilder(context, ctl),
              ),
              IconButton(
                tooltip: 'Reports',
                icon: const Icon(Icons.assessment_outlined),
                onPressed: () => _openReports(context, ctl),
              ),
            ],
      body: ctl.loading
          ? FinanceStates.loading()
          : ctl.error != null
          ? FinanceStates.error(context, ctl.error!, onRetry: ctl.load)
          : sel != null
          ? _DetailPanel(ctl: ctl)
          : _LearnerList(ctl: ctl),
    );
  }
}

// ===========================================================================
//  Filter panel
// ===========================================================================

class _FilterPanel extends StatelessWidget {
  final _EntitlementsController ctl;
  final bool scrollable;
  const _FilterPanel({required this.ctl, this.scrollable = false});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      TextField(
        decoration: const InputDecoration(
          hintText: 'Name or admission no.',
          prefixIcon: Icon(Icons.search, size: 18),
          isDense: true,
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => ctl.setFilter(() => ctl.query = v),
      ),
      const SizedBox(height: 12),
      _FilterLabel('Class'),
      DropdownButtonFormField<String?>(
        initialValue: ctl.classId,
        isExpanded: true,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('All classes')),
          for (final c in ctl.classIds)
            DropdownMenuItem(value: c, child: Text(c)),
        ],
        onChanged: (v) => ctl.setFilter(() => ctl.classId = v),
      ),
      const SizedBox(height: 12),
      _FilterLabel('Boarding'),
      Wrap(
        spacing: 6,
        children: [
          for (final e in const {'boarding': 'Boarding', 'day': 'Day'}.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: ctl.boarding == e.key,
              onSelected: (s) =>
                  ctl.setFilter(() => ctl.boarding = s ? e.key : null),
            ),
        ],
      ),
      const SizedBox(height: 12),
      _FilterLabel('Payment %'),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var i = 0; i < kEntitlementBands.length; i++)
            FilterChip(
              label: Text(kEntitlementBands[i]),
              selected: ctl.bands.contains(i),
              onSelected: (s) => ctl.setFilter(
                () => s ? ctl.bands.add(i) : ctl.bands.remove(i),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      _FilterLabel('Balance range (UGX)'),
      RangeSlider(
        values: ctl.balanceRange ?? RangeValues(0, ctl.maxBalance),
        min: 0,
        max: ctl.maxBalance,
        divisions: 20,
        labels: RangeLabels(
          CurrencyFormatter.ugx((ctl.balanceRange?.start ?? 0)),
          CurrencyFormatter.ugx((ctl.balanceRange?.end ?? ctl.maxBalance)),
        ),
        onChanged: (v) => ctl.setFilter(() => ctl.balanceRange = v),
      ),
      const SizedBox(height: 4),
      CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Has scholarship'),
        value: ctl.onlyScholarship,
        onChanged: (v) => ctl.setFilter(() => ctl.onlyScholarship = v ?? false),
      ),
      CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Has waiver'),
        value: ctl.onlyWaiver,
        onChanged: (v) => ctl.setFilter(() => ctl.onlyWaiver = v ?? false),
      ),
      CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('On a payment plan'),
        value: ctl.onlyPaymentPlan,
        onChanged: (v) => ctl.setFilter(() => ctl.onlyPaymentPlan = v ?? false),
      ),
      CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Has a restriction flag'),
        value: ctl.onlyRestricted,
        onChanged: (v) => ctl.setFilter(() => ctl.onlyRestricted = v ?? false),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => ctl.setFilter(() {
          ctl.classId = null;
          ctl.streamId = null;
          ctl.boarding = null;
          ctl.bands.clear();
          ctl.balanceRange = null;
          ctl.onlyScholarship = ctl.onlyWaiver = ctl.onlyPaymentPlan =
              ctl.onlyRestricted = false;
          ctl.query = '';
        }),
        icon: const Icon(Icons.clear_all_rounded, size: 16),
        label: const Text('Clear filters'),
      ),
    ];
    final content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
    if (scrollable) return SingleChildScrollView(child: content);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border(context))),
      ),
      child: SingleChildScrollView(child: content),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: .5,
        color: AppColors.textMuted(context),
      ),
    ),
  );
}

// ===========================================================================
//  Bulk toolbar
// ===========================================================================

class _BulkToolbar extends StatelessWidget {
  final _EntitlementsController ctl;
  const _BulkToolbar({required this.ctl});

  @override
  Widget build(BuildContext context) {
    final n = ctl.checked.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Text(
            '${ctl.filtered.length} learners'
            '${n > 0 ? '  ·  $n selected' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const Spacer(),
          if (n > 0) ...[
            TextButton.icon(
              onPressed: () => _openBulk(context, ctl, 'grant'),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Grant'),
            ),
            TextButton.icon(
              onPressed: () => _openBulk(context, ctl, 'renew'),
              icon: const Icon(Icons.event_repeat_rounded, size: 16),
              label: const Text('Renew'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger(context),
              ),
              onPressed: () => _openBulk(context, ctl, 'revoke'),
              icon: const Icon(Icons.block_rounded, size: 16),
              label: const Text('Revoke'),
            ),
            TextButton(
              onPressed: () => ctl.setFilter(ctl.checked.clear),
              child: const Text('Clear'),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
//  Learner table (wide) + list (mobile)
// ===========================================================================

class _LearnerTable extends StatelessWidget {
  final _EntitlementsController ctl;
  const _LearnerTable({required this.ctl});

  @override
  Widget build(BuildContext context) {
    final rows = ctl.filtered;
    if (rows.isEmpty) {
      return FinanceStates.empty(
        context,
        icon: Icons.people_outline_rounded,
        title: 'No learners match',
        message: 'Adjust the filters on the left.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: rows.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.border(context)),
      itemBuilder: (context, i) {
        final s = rows[i];
        final f = ctl.financials[s.id];
        final selected = ctl.selectedStudentId == s.id;
        return Material(
          color: selected
              ? AppColors.surfaceContainer(context)
              : Colors.transparent,
          child: InkWell(
            onTap: () => ctl.select(s.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: ctl.checked.contains(s.id),
                    onChanged: (v) => ctl.setFilter(
                      () => v == true
                          ? ctl.checked.add(s.id)
                          : ctl.checked.remove(s.id),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${s.admissionNumber} · ${s.classId}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PctPill(pct: f?.overallPct ?? 0),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      CurrencyFormatter.ugx(f?.balance ?? 0),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: (f?.balance ?? 0) > 0
                            ? AppColors.danger(context)
                            : AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (f?.hasScholarship ?? false) const _MiniTag('SCHOL'),
                  if (f?.hasPaymentPlan ?? false) const _MiniTag('PLAN'),
                  if (f?.hasWaiver ?? false) const _MiniTag('WAIVE'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LearnerList extends StatelessWidget {
  final _EntitlementsController ctl;
  const _LearnerList({required this.ctl});
  @override
  Widget build(BuildContext context) {
    final rows = ctl.filtered;
    if (rows.isEmpty) {
      return FinanceStates.empty(
        context,
        icon: Icons.people_outline_rounded,
        title: 'No learners match',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final s in rows)
          FinanceListRow(
            leadingIcon: Icons.person_outline_rounded,
            title: s.name,
            subtitle: '${s.admissionNumber} · ${s.classId}',
            onTap: () => ctl.select(s.id),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PctPill(pct: ctl.financials[s.id]?.overallPct ?? 0),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.ugx(ctl.financials[s.id]?.balance ?? 0),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: (ctl.financials[s.id]?.balance ?? 0) > 0
                        ? AppColors.danger(context)
                        : AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PctPill extends StatelessWidget {
  final int pct;
  const _PctPill({required this.pct});
  @override
  Widget build(BuildContext context) {
    final ok = pct >= 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ok
            ? AppColors.successSurface(context)
            : AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$pct%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ok
              ? AppColors.success(context)
              : AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String text;
  const _MiniTag(this.text);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 4),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border(context)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 8.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted(context),
      ),
    ),
  );
}

// ===========================================================================
//  Detail panel — learner across every service
// ===========================================================================

class _DetailPanel extends StatelessWidget {
  final _EntitlementsController ctl;
  const _DetailPanel({required this.ctl});

  @override
  Widget build(BuildContext context) {
    if (ctl.profileLoading) return FinanceStates.loading();
    final p = ctl.selectedProfile;
    if (p == null || p['error'] == true) {
      return FinanceStates.error(
        context,
        'Could not load this learner.',
        onRetry: () => ctl.select(ctl.selectedStudentId!),
      );
    }
    final name = ctl.nameOf(ctl.selectedStudentId!);
    final services =
        (p['services'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        FinanceCard(
          child: Column(
            children: [
              KeyValueRow(
                'Overall payment',
                '${p['overallPaymentPercentage'] ?? 0}%',
                bold: true,
              ),
              KeyValueRow(
                'Outstanding balance',
                CurrencyFormatter.ugx(((p['balance'] as num?) ?? 0).toDouble()),
                valueColor: ((p['balance'] as num?) ?? 0) > 0
                    ? AppColors.danger(context)
                    : AppColors.success(context),
              ),
              if (((p['scholarshipAmount'] as num?) ?? 0) > 0)
                KeyValueRow(
                  'Scholarship',
                  CurrencyFormatter.ugx(
                    ((p['scholarshipAmount'] as num).toDouble()),
                  ),
                ),
              if (((p['waiverAmount'] as num?) ?? 0) > 0)
                KeyValueRow(
                  'Waiver',
                  CurrencyFormatter.ugx(
                    ((p['waiverAmount'] as num).toDouble()),
                  ),
                ),
              KeyValueRow(
                'Payment plan',
                (p['hasPaymentPlan'] == true) ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Service entitlements',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        if (services.isEmpty)
          Text(
            'No services are fee-gated. Configure a policy first.',
            style: TextStyle(color: AppColors.textMuted(context)),
          )
        else
          for (final e in services.entries)
            _ServiceRow(
              ctl: ctl,
              studentId: ctl.selectedStudentId!,
              service: e.key,
              result: (e.value as Map).cast<String, dynamic>(),
            ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final _EntitlementsController ctl;
  final String studentId;
  final String service;
  final Map<String, dynamic> result;
  const _ServiceRow({
    required this.ctl,
    required this.studentId,
    required this.service,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final status = '${result['status'] ?? '—'}';
    final source = '${result['source'] ?? ''}';
    final chain = ((result['sourceChain'] as List?) ?? const []).join(' → ');
    final exp = result['expiresAt'];
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap:
          ctl.isLeadership ||
              ctl.roles.contains('bursar') ||
              ctl.roles.contains('schoolAdmin')
          ? () => _openOverride(context, ctl, studentId, service, status)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kEntitlementServices[service] ?? service,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 4),
          if (source.isNotEmpty)
            Text(
              'Source: $source${chain.isNotEmpty ? '   ($chain)' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
          if (exp != null)
            Text(
              'Expires ${DateFormat('d MMM yyyy').format(_ts(exp))}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
        ],
      ),
    );
  }

  DateTime _ts(dynamic v) {
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is Map && v['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch((v['_seconds'] as int) * 1000);
    }
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    const green = {'allowed', 'overrideActive'};
    const red = {'blocked', 'expired', 'suspended'};
    const amber = {'expiring', 'pendingApproval'};
    Color fg, bg;
    if (green.contains(status)) {
      fg = AppColors.success(context);
      bg = AppColors.successSurface(context);
    } else if (red.contains(status)) {
      fg = AppColors.danger(context);
      bg = AppColors.dangerSurface(context);
    } else if (amber.contains(status)) {
      fg = AppColors.textSecondary(context);
      bg = AppColors.surfaceContainer(context);
    } else {
      fg = AppColors.textMuted(context);
      bg = AppColors.surfaceContainer(context);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

// ===========================================================================
//  Override / bulk / policy / reports sheets
// ===========================================================================

Future<void> _openOverride(
  BuildContext context,
  _EntitlementsController ctl,
  String studentId,
  String service,
  String currentStatus,
) async {
  var decision = 'allow';
  final reason = TextEditingController();
  final note = TextEditingController();
  DateTime expiry = DateTime.now().add(const Duration(days: 14));
  var requireSecond = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => _Sheet(
        title: '${kEntitlementServices[service] ?? service} · override',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'allow', label: Text('Grant access')),
                ButtonSegment(value: 'deny', label: Text('Suspend')),
              ],
              selected: {decision},
              onSelectionChanged: (s) => setSheet(() => decision = s.first),
            ),
            const SizedBox(height: 12),
            FinanceField(
              controller: reason,
              label: 'Reason code',
              required: true,
            ),
            FinanceField(controller: note, label: 'Note', maxLines: 2),
            if (decision == 'allow')
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Expires: ${DateFormat('d MMM yyyy').format(expiry)}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: sheetContext,
                    initialDate: expiry,
                    firstDate: now,
                    lastDate: DateTime(now.year + 1),
                  );
                  if (picked != null) setSheet(() => expiry = picked);
                },
              ),
            if (decision == 'allow')
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Send for second approval'),
                value: requireSecond,
                onChanged: (v) => setSheet(() => requireSecond = v ?? false),
              ),
            const SizedBox(height: 8),
            FinanceSubmitButton(
              label: decision == 'allow' ? 'Grant' : 'Suspend',
              danger: decision == 'deny',
              onPressed: () async {
                if (reason.text.trim().isEmpty) return;
                await runFinanceAction(
                  sheetContext,
                  successMessage: 'Override recorded',
                  popOnDone: 1,
                  action: () => ctl.ds.setOverride(
                    schoolId: ctl.schoolId,
                    studentId: studentId,
                    service: service,
                    decision: decision,
                    reasonCode: reason.text.trim(),
                    note: note.text.trim().isEmpty ? null : note.text.trim(),
                    expiresAtMs: decision == 'allow'
                        ? expiry.millisecondsSinceEpoch
                        : null,
                    requireSecondApproval: requireSecond,
                  ),
                );
                await ctl.select(studentId);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _openBulk(
  BuildContext context,
  _EntitlementsController ctl,
  String action,
) async {
  final ids = ctl.checked.toList();
  String? service = ctl.configuredServices.isNotEmpty
      ? ctl.configuredServices.first
      : null;
  final reason = TextEditingController();
  DateTime expiry = DateTime.now().add(const Duration(days: 14));
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => _Sheet(
        title: 'Bulk $action · ${ids.length} learners',
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: service,
                decoration: const InputDecoration(
                  labelText: 'Service',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final s in ctl.configuredServices)
                    DropdownMenuItem(
                      value: s,
                      child: Text(kEntitlementServices[s] ?? s),
                    ),
                ],
                onChanged: (v) => setSheet(() => service = v),
              ),
              const SizedBox(height: 12),
              FinanceField(
                controller: reason,
                label: 'Reason code',
                required: true,
              ),
              if (action != 'revoke')
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${action == 'renew' ? 'New expiry' : 'Expires'}: '
                    '${DateFormat('d MMM yyyy').format(expiry)}',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: sheetContext,
                      initialDate: expiry,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) setSheet(() => expiry = picked);
                  },
                ),
              const SizedBox(height: 8),
              FinanceSubmitButton(
                label: 'Confirm bulk $action',
                danger: action == 'revoke',
                onPressed: () async {
                  if (service == null || reason.text.trim().isEmpty) return;
                  await runFinanceAction(
                    sheetContext,
                    successMessage:
                        'Bulk $action queued for ${ids.length} learners',
                    popOnDone: 1,
                    action: () => ctl.ds.bulkAction(
                      schoolId: ctl.schoolId,
                      action: action,
                      service: service!,
                      studentIds: ids,
                      reasonCode: reason.text.trim(),
                      expiresAtMs: action == 'revoke'
                          ? null
                          : expiry.millisecondsSinceEpoch,
                      bulkActionId: '${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  );
                  ctl.setFilter(ctl.checked.clear);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _openPolicyBuilder(
  BuildContext context,
  _EntitlementsController ctl,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _Sheet(
      title: 'Service policies',
      child: SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.7,
        child: _PolicyBuilder(ctl: ctl),
      ),
    ),
  );
}

class _PolicyBuilder extends StatelessWidget {
  final _EntitlementsController ctl;
  const _PolicyBuilder({required this.ctl});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: ctl.ds.watchPolicy(ctl.schoolId),
      builder: (context, snap) {
        final services =
            (snap.data?['services'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return ListView(
          children: [
            Text(
              'Service access is disabled until a policy is explicitly enabled. '
              'Safety services (national exams, emergency healthcare, water, '
              'sanitation, safeguarding, classroom learning, attendance, safe '
              'guardian release) can never be fee-gated.',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            for (final e in kEntitlementServices.entries)
              _PolicyRow(
                ctl: ctl,
                serviceKey: e.key,
                title: e.value,
                rule:
                    (services[e.key] as Map?)?.cast<String, dynamic>() ??
                    const {},
              ),
          ],
        );
      },
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final _EntitlementsController ctl;
  final String serviceKey;
  final String title;
  final Map<String, dynamic> rule;
  const _PolicyRow({
    required this.ctl,
    required this.serviceKey,
    required this.title,
    required this.rule,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = rule['enabled'] == true;
    final min = (rule['minimumPaymentPercentage'] as num?)?.toInt() ?? 100;
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => _save({
                  ...rule,
                  'enabled': v,
                  'minimumPaymentPercentage': min,
                }),
              ),
            ],
          ),
          if (enabled)
            Row(
              children: [
                Text(
                  'Minimum payment',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                DropdownButton<int>(
                  value: min,
                  items: const [0, 25, 50, 75, 100]
                      .map(
                        (v) => DropdownMenuItem(value: v, child: Text('$v%')),
                      )
                      .toList(),
                  onChanged: (v) => _save({
                    ...rule,
                    'enabled': true,
                    'minimumPaymentPercentage': v ?? min,
                  }),
                ),
              ],
            ),
          if (enabled)
            Wrap(
              spacing: 6,
              children: [
                _honorChip(context, 'Scholarship', 'honorScholarship'),
                _honorChip(context, 'Waiver', 'honorWaiver'),
                _honorChip(context, 'Payment plan', 'honorPaymentPlan'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _honorChip(BuildContext context, String label, String key) =>
      FilterChip(
        label: Text(label),
        selected: rule[key] == true,
        onSelected: (s) => _save({...rule, 'enabled': true, key: s}),
      );

  Future<void> _save(Map<String, dynamic> next) async {
    try {
      await ctl.ds.savePolicy(
        schoolId: ctl.schoolId,
        services: {serviceKey: next},
      );
    } catch (_) {
      /* surfaced by the stream refetch failing is unlikely */
    }
  }
}

Future<void> _openReports(
  BuildContext context,
  _EntitlementsController ctl,
) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => _Sheet(
      title: 'Entitlement reports',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in _reports)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(r.title),
              subtitle: Text('${r.rows(ctl).length} rows · current filters'),
              trailing: const Icon(Icons.download_outlined, size: 18),
              onTap: () async {
                final bytes = utf8.encode(ctl.reportCsv(r));
                final name =
                    '${r.title.toLowerCase().replaceAll(' ', '_')}.csv';
                await Share.shareXFiles([
                  XFile.fromData(bytes, name: name, mimeType: 'text/csv'),
                ], subject: r.title);
              },
            ),
        ],
      ),
    ),
  );
}

class _Sheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _Sheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(child: child),
        ],
      ),
    );
  }
}
