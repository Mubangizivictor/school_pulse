import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/bursar_student_view.dart';
import '../../domain/services/bursar_student_projection_service.dart';
import '../widgets/finance_kit.dart';

/// Which fee-status band a learner falls in - drives the row chip and the
/// filter control on the Students & Fees list.
enum _FeeFilter { all, paid, partial, overdue }

/// Students & Fees list (bottom-nav slot 1).
///
/// Matches the reference "Student Fees" screenshot: a search field + filter,
/// then a scrollable list of learners with `name`, `admissionNumber · class`,
/// a Paid/Partial/Overdue chip and their outstanding balance. Tapping a row
/// opens that learner's statement (`/staff/bursar/student/:id/bills`).
/// Balances come from [BursarStudentProjectionService] (permission-gated).
class BursarStudentLookupScreen extends StatefulWidget {
  const BursarStudentLookupScreen({super.key});

  @override
  State<BursarStudentLookupScreen> createState() =>
      _BursarStudentLookupScreenState();
}

class _BursarStudentLookupScreenState extends State<BursarStudentLookupScreen> {
  final _searchController = TextEditingController();
  final _studentRepository = sl<StudentRepository>();
  final _projectionService = sl<BursarStudentProjectionService>();

  List<Student> _results = const [];
  final Map<String, BursarStudentView> _views = {};
  bool _searching = false;
  String? _error;
  _FeeFilter _filter = _FeeFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
      });
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    final result = await _studentRepository.searchStudents(
      schoolId: auth.user.schoolId,
      query: query,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _searching = false;
      }),
      (students) {
        setState(() {
          _results = students;
          _searching = false;
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
      final result = await _projectionService.getStudentView(
        studentId: s.id,
        schoolId: auth.user.schoolId,
        operatorUser: auth.user,
      );
      if (!mounted) return;
      result.fold((_) {}, (view) => setState(() => _views[s.id] = view));
    }
  }

  bool _matchesFilter(BursarStudentView? v) {
    if (_filter == _FeeFilter.all || v == null) return true;
    switch (_filter) {
      case _FeeFilter.paid:
        return v.isFullyPaid;
      case _FeeFilter.partial:
        return !v.isFullyPaid && v.totalPaid > 0;
      case _FeeFilter.overdue:
        return !v.isFullyPaid && v.totalPaid <= 0 && v.balance > 0;
      case _FeeFilter.all:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _results
        .where((s) => _matchesFilter(_views[s.id]))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.l,
        title: Text(
          'Student Fees',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: [
          PopupMenuButton<_FeeFilter>(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _filter == _FeeFilter.all
                  ? AppColors.textPrimary(context)
                  : AppColors.primary(context),
            ),
            onSelected: (f) => setState(() => _filter = f),
            itemBuilder: (context) => const [
              PopupMenuItem(value: _FeeFilter.all, child: Text('All learners')),
              PopupMenuItem(value: _FeeFilter.paid, child: Text('Paid')),
              PopupMenuItem(value: _FeeFilter.partial, child: Text('Partial')),
              PopupMenuItem(value: _FeeFilter.overdue, child: Text('Overdue')),
            ],
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.s,
                AppSpacing.l,
                AppSpacing.m,
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                onChanged: (v) {
                  if (v.trim().isEmpty) _search();
                },
                decoration: InputDecoration(
                  hintText: 'Search learner by name or admission no.',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceElevated(context),
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide(color: AppColors.primary(context)),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(visible)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<Student> visible) {
    if (_error != null) {
      return FinanceStates.error(context, _error!, onRetry: _search);
    }
    if (_searchController.text.trim().isEmpty) {
      return FinanceStates.empty(
        context,
        icon: Icons.search_rounded,
        title: 'Find a learner',
        message:
            'Search by name or admission number to view fees, record a '
            'payment, or open a statement.',
      );
    }
    if (visible.isEmpty && !_searching) {
      return FinanceStates.empty(
        context,
        icon: Icons.person_off_outlined,
        title: 'No matching learners',
        message:
            'Try a different name or admission number, or clear the filter.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        0,
        AppSpacing.l,
        AppSpacing.x3l,
      ),
      itemCount: visible.length + 1,
      itemBuilder: (context, i) {
        if (i == visible.length) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.m),
            child: Center(
              child: Text(
                '${visible.length} learner${visible.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
          );
        }
        final s = visible[i];
        final v = _views[s.id];
        return _StudentRow(
          student: s,
          view: v,
          onTap: () => context.push('/staff/bursar/student/${s.id}/bills'),
        );
      },
    );
  }
}

class _StudentRow extends StatelessWidget {
  final Student student;
  final BursarStudentView? view;
  final VoidCallback onTap;

  const _StudentRow({
    required this.student,
    required this.view,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final v = view;
    final ({String label, FinanceStatusTone tone}) status = v == null
        ? (label: '…', tone: FinanceStatusTone.neutral)
        : v.isFullyPaid
        ? (label: 'Paid', tone: FinanceStatusTone.positive)
        : v.totalPaid > 0
        ? (label: 'Partial', tone: FinanceStatusTone.neutral)
        : (label: 'Overdue', tone: FinanceStatusTone.negative);

    final balance = v?.balance ?? 0;

    return FinanceListRow(
      title: student.name,
      subtitle:
          '${student.admissionNumber.isNotEmpty ? student.admissionNumber : student.studentCode} · ${student.className}',
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FinanceStatusChip(label: status.label, tone: status.tone),
          const SizedBox(width: AppSpacing.m),
          Text(
            CurrencyFormatter.ugx(balance),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: balance > 0
                  ? AppColors.danger(context)
                  : AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textMuted(context),
          ),
        ],
      ),
    );
  }
}
