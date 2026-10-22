import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/finance/domain/entities/bursar_student_view.dart';
import 'package:school_pulse/features/finance/domain/services/bursar_student_projection_service.dart';
import 'package:school_pulse/features/finance/presentation/screens/student_billing/student_bills_screen.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_web_kit.dart';

/// Students & fees — desktop split-pane: a wide learner table on the left,
/// the selected learner's live statement (Statement / Payment history,
/// Print / Communicate, Record payment) in a right-hand inspector.
///
/// Reuses [StudentBillsScreen] (`embedded: true`) for the inspector so the
/// statement, adjustment and Receive-Payment flows are the exact same code
/// as mobile. Filter + top-bar `?q=` search apply.
class BursarWebStudentsScreen extends StatefulWidget {
  const BursarWebStudentsScreen({super.key});

  @override
  State<BursarWebStudentsScreen> createState() =>
      _BursarWebStudentsScreenState();
}

enum _Band { all, paid, partial, overdue }

class _BursarWebStudentsScreenState extends State<BursarWebStudentsScreen> {
  final _repo = sl<StudentRepository>();
  final _projection = sl<BursarStudentProjectionService>();

  List<Student> _all = const [];
  final Map<String, BursarStudentView> _views = {};
  bool _loading = true;
  String? _error;
  String _query = '';
  _Band _band = _Band.all;
  Student? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final q = _routeQuery();
    if (q != _query) setState(() => _query = q);
  }

  String _routeQuery() {
    try {
      return GoRouterState.of(context).uri.queryParameters['q']?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _repo.getAllStudents(schoolId: auth.user.schoolId);
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (students) {
        students.sort((a, b) => a.name.compareTo(b.name));
        setState(() {
          _all = students;
          _loading = false;
        });
        _loadViews(auth, students);
      },
    );
  }

  Future<void> _loadViews(
    AuthAuthenticated auth,
    List<Student> students,
  ) async {
    for (final s in students) {
      if (_views.containsKey(s.id)) continue;
      final r = await _projection.getStudentView(
        studentId: s.id,
        schoolId: auth.user.schoolId,
        operatorUser: auth.user,
      );
      if (!mounted) return;
      r.fold((_) {}, (v) => setState(() => _views[s.id] = v));
    }
  }

  ({String label, FinanceStatusTone tone}) _status(BursarStudentView? v) {
    if (v == null) return (label: '…', tone: FinanceStatusTone.neutral);
    if (v.isFullyPaid) {
      return (label: 'Paid', tone: FinanceStatusTone.positive);
    }
    if (v.totalPaid > 0) {
      return (label: 'Partial', tone: FinanceStatusTone.warning);
    }
    return (label: 'Overdue', tone: FinanceStatusTone.negative);
  }

  bool _matches(Student s) {
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      final hit =
          s.name.toLowerCase().contains(q) ||
          s.admissionNumber.toLowerCase().contains(q) ||
          s.studentCode.toLowerCase().contains(q) ||
          s.className.toLowerCase().contains(q);
      if (!hit) return false;
    }
    if (_band == _Band.all) return true;
    final v = _views[s.id];
    if (v == null) return true;
    return switch (_band) {
      _Band.paid => v.isFullyPaid,
      _Band.partial => !v.isFullyPaid && v.totalPaid > 0,
      _Band.overdue => !v.isFullyPaid && v.totalPaid <= 0 && v.balance > 0,
      _Band.all => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final rows = _all.where(_matches).toList();

    return FinanceWorkspace(
      title: 'Students & fees',
      updatedLabel: '${_all.length} learners',
      padding: const EdgeInsets.fromLTRB(32, 24, 0, 0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 180,
        child: FinanceSplitPane(
          detailWidth: 460,
          detail: _selected == null
              ? null
              : _Inspector(
                  key: ValueKey(_selected!.id),
                  schoolId: schoolId,
                  student: _selected!,
                  onClose: () => setState(() => _selected = null),
                ),
          list: Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (_query.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Chip(
                          label: Text('“$_query”'),
                          onDeleted: () {
                            GoRouter.of(context).go('/staff/bursar/students');
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    const Spacer(),
                    SegmentedButton<_Band>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: _Band.all, label: Text('All')),
                        ButtonSegment(value: _Band.paid, label: Text('Paid')),
                        ButtonSegment(
                          value: _Band.partial,
                          label: Text('Partial'),
                        ),
                        ButtonSegment(
                          value: _Band.overdue,
                          label: Text('Overdue'),
                        ),
                      ],
                      selected: {_band},
                      onSelectionChanged: (s) =>
                          setState(() => _band = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated(context),
                      borderRadius: AppRadius.large,
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _loading
                        ? FinanceStates.loading()
                        : _error != null
                        ? FinanceStates.error(context, _error!, onRetry: _load)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: FinanceDataTable<Student>(
                              rows: rows,
                              total: _all.length,
                              emptyMessage: 'No learners match.',
                              isSelected: (s) => s.id == _selected?.id,
                              onRowTap: (s) => setState(() => _selected = s),
                              columns: [
                                FinanceColumn.text(
                                  'Adm no.',
                                  (s) => s.admissionNumber.isNotEmpty
                                      ? s.admissionNumber
                                      : s.studentCode,
                                  flex: 2,
                                ),
                                FinanceColumn.text(
                                  'Student name',
                                  (s) => s.name,
                                  flex: 3,
                                  bold: true,
                                ),
                                FinanceColumn.text(
                                  'Class',
                                  (s) => s.className,
                                  flex: 1,
                                ),
                                FinanceColumn(
                                  label: 'Balance (UGX)',
                                  flex: 2,
                                  align: TextAlign.right,
                                  cell: (s) {
                                    final bal = _views[s.id]?.balance ?? 0;
                                    return Text(
                                      CurrencyFormatter.ugx(bal),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: bal > 0
                                            ? AppColors.danger(context)
                                            : AppColors.textPrimary(context),
                                      ),
                                    );
                                  },
                                ),
                                FinanceColumn(
                                  label: 'Status',
                                  flex: 2,
                                  cell: (s) {
                                    final st = _status(_views[s.id]);
                                    return FinanceStatusChip(
                                      label: st.label,
                                      tone: st.tone,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Inspector extends StatelessWidget {
  final String schoolId;
  final Student student;
  final VoidCallback onClose;

  const _Inspector({
    super.key,
    required this.schoolId,
    required this.student,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      '${student.admissionNumber.isNotEmpty ? student.admissionNumber : student.studentCode} · ${student.className}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StudentBillsScreen(
              schoolId: schoolId,
              studentId: student.id,
              studentName: student.name,
              embedded: true,
            ),
          ),
        ],
      ),
    );
  }
}
