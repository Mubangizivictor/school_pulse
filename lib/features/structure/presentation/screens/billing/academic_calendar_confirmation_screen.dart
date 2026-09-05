import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/services/structure_validation_service.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/billing/data/datasources/subscription_cycle_remote_data_source.dart';
import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';
import 'package:school_pulse/features/billing/presentation/utils/subscription_cycle_status_ui.dart';

/// School-admin-facing "Academic Calendar" setup screen: confirms the
/// current academic year's terms so functions/academic_calendar_billing.js
/// can generate one subscription_cycles doc per term. This is Phase 1 of
/// term-based SaaS billing - it does NOT invoice, remind, suspend, apply
/// discounts, or handle offline queueing (all Phase 2).
///
/// Lazily offers a draft 3-term template (clearly labeled "Review before
/// confirming") when the school has no years/terms yet - drafts are only
/// ever local edits via the existing SaveAcademicTermRequested/
/// SaveAcademicYearRequested plain-write path; nothing is treated as
/// confirmed until "Confirm academic calendar" succeeds server-side.
class AcademicCalendarConfirmationScreen extends StatefulWidget {
  const AcademicCalendarConfirmationScreen({super.key, this.cycleDataSource});

  /// Injectable for widget tests, which don't run Firebase.initializeApp -
  /// defaults to the real Firestore-backed data source in production.
  final SubscriptionCycleRemoteDataSource? cycleDataSource;

  @override
  State<AcademicCalendarConfirmationScreen> createState() =>
      _AcademicCalendarConfirmationScreenState();
}

class _AcademicCalendarConfirmationScreenState
    extends State<AcademicCalendarConfirmationScreen> {
  final _dateFmt = DateFormat('MMM d, yyyy');
  final _uuid = const Uuid();
  late final _cycleDataSource =
      widget.cycleDataSource ?? SubscriptionCycleRemoteDataSource();
  bool _draftGenerated = false;
  bool _wasConfirming = false;

  bool _loadingCycles = true;
  List<SubscriptionCycle> _cycles = const [];
  String? _loadedForSchoolId;

  Future<void> _loadCycles(String schoolId) async {
    setState(() => _loadingCycles = true);
    try {
      final cycles = await _cycleDataSource.getSubscriptionCyclesForSchool(
        schoolId,
      );
      if (!mounted) return;
      setState(() {
        _cycles = cycles;
        _loadingCycles = false;
        _loadedForSchoolId = schoolId;
      });
    } catch (_) {
      if (!mounted) return;
      // Best-effort: absence of cycle data just means the empty state
      // shows below - this screen's core confirm flow doesn't depend on it.
      setState(() {
        _loadingCycles = false;
        _loadedForSchoolId = schoolId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;

    if (_loadedForSchoolId != schoolId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadCycles(schoolId);
      });
    }

    return BlocConsumer<StructureBloc, StructureState>(
      listener: (context, state) {
        if (_wasConfirming && !state.isConfirmingCalendar) {
          if (state.calendarConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Academic calendar confirmed.'),
              ),
            );
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        }
        _wasConfirming = state.isConfirmingCalendar;
      },
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        final currentYear = state.academicYears
            .where((y) => y.isCurrent && !y.isArchived)
            .cast<AcademicYear?>()
            .firstWhere((_) => true, orElse: () => null);

        final hasAnyCalendar =
            state.academicYears.isNotEmpty && state.academicTerms.isNotEmpty;

        if (!hasAnyCalendar && !_draftGenerated) {
          // Offer to generate a draft template rather than silently doing
          // it - the button below drives the actual write.
        }

        final relevantYear = currentYear ??
            (state.academicYears.isEmpty ? null : state.academicYears.first);
        final relevantTerms = relevantYear == null
            ? <AcademicTerm>[]
            : state.academicTerms
                .where(
                  (t) =>
                      t.academicYearId == relevantYear.id && !t.isArchived,
                )
                .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        final validationIssues = StructureValidationService()
            .validate(state)
            .where((issue) => issue.category == 'Terms')
            .toList();

        final canConfirm = relevantYear != null &&
            relevantTerms.isNotEmpty &&
            validationIssues.isEmpty &&
            !state.isConfirmingCalendar;

        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: const AdminAppBar(title: 'Academic Calendar'),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Your confirmed term dates are used to prepare future '
                'renewal cycles.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (relevantYear == null) ...[
                AppCard(
                  showShadow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No academic year set up yet',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate a draft academic year with three terms '
                        'using placeholder dates. Review and adjust before '
                        'confirming - nothing is confirmed automatically.',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            _generateDraftTemplate(context, bloc, schoolId),
                        child: const Text('Generate draft calendar'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                AppCard(
                  showShadow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              relevantYear.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (relevantTerms.every((t) => !t.isConfirmed))
                            const _DraftBadge(),
                        ],
                      ),
                      Text(
                        '${_dateFmt.format(relevantYear.startDate)} - '
                        '${_dateFmt.format(relevantYear.endDate)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final term in relevantTerms) ...[
                  _TermCard(term: term, dateFmt: _dateFmt),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 4),
                _UpcomingRenewalSection(
                  loading: _loadingCycles,
                  cycles: _cycles,
                  confirmedTermIds: relevantTerms
                      .where((t) => t.isConfirmed)
                      .map((t) => t.id)
                      .toSet(),
                  dateFmt: _dateFmt,
                ),
                if (validationIssues.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppCard(
                    showShadow: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fix before confirming',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.error,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (final issue in validationIssues)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${issue.message}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.isConfirmingCalendar
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Draft already saved - edit terms above and they save automatically.',
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Save draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: canConfirm
                            ? () => bloc.add(
                                  ConfirmAcademicCalendarRequested(
                                    schoolId,
                                    termIds:
                                        relevantTerms.map((t) => t.id).toList(),
                                  ),
                                )
                            : null,
                        child: state.isConfirmingCalendar
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Confirm academic calendar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _generateDraftTemplate(
    BuildContext context,
    StructureBloc bloc,
    String schoolId,
  ) {
    final now = DateTime.now();
    final yearId = _uuid.v4();
    final year = AcademicYear(
      id: yearId,
      schoolId: schoolId,
      name: '${now.year} Academic Year (Draft)',
      startDate: DateTime(now.year, 1, 1),
      endDate: DateTime(now.year, 12, 15),
      description: 'Draft template - review before confirming.',
      isCurrent: true,
    );
    bloc.add(SaveAcademicYearRequested(year));

    // Three roughly-even generic terms across the draft year. Placeholder
    // dates only - deliberately not real term dates, per spec.
    final termSpans = [
      (DateTime(now.year, 1, 1), DateTime(now.year, 4, 10)),
      (DateTime(now.year, 5, 1), DateTime(now.year, 8, 10)),
      (DateTime(now.year, 9, 1), DateTime(now.year, 12, 10)),
    ];
    for (var i = 0; i < termSpans.length; i++) {
      final (start, end) = termSpans[i];
      bloc.add(
        SaveAcademicTermRequested(
          AcademicTerm(
            id: _uuid.v4(),
            schoolId: schoolId,
            academicYearId: yearId,
            name: 'Term ${i + 1} (Draft)',
            order: i + 1,
            startDate: start,
            endDate: end,
          ),
        ),
      );
    }
    setState(() => _draftGenerated = true);
  }
}

/// Compact read-only "Upcoming renewal" section for confirmed terms only.
/// Never shows plan price/discount - School Admin can see status and dates
/// only, never full financial detail of a cycle (that's Super Admin's job,
/// surfaced on school_subscription_screen.dart). Renders nothing (not even
/// an empty-state card) while cycles are still loading or there simply
/// aren't any yet, matching this screen's existing terse, no-filler style.
class _UpcomingRenewalSection extends StatelessWidget {
  const _UpcomingRenewalSection({
    required this.loading,
    required this.cycles,
    required this.confirmedTermIds,
    required this.dateFmt,
  });

  final bool loading;
  final List<SubscriptionCycle> cycles;
  final Set<String> confirmedTermIds;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox.shrink();

    final relevant = cycles.where((c) => confirmedTermIds.contains(c.termId)).toList()
      ..sort((a, b) => a.termStart.compareTo(b.termStart));
    if (relevant.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AppCard(
        showShadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming renewal',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            for (final (i, cycle) in relevant.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              _CycleRenewalRow(cycle: cycle, dateFmt: dateFmt),
            ],
          ],
        ),
      ),
    );
  }
}

class _CycleRenewalRow extends StatelessWidget {
  const _CycleRenewalRow({required this.cycle, required this.dateFmt});

  final SubscriptionCycle cycle;
  final DateFormat dateFmt;

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
                'Term ${cycle.termNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Due ${dateFmt.format(cycle.paymentDueAt)} · '
                'Grace ends ${dateFmt.format(cycle.graceEndsAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        StatusBadge(
          label: cycleStatusLabel(cycle.cycleStatus),
          color: cycleStatusColor(context, cycle.cycleStatus),
        ),
      ],
    );
  }
}

class _DraftBadge extends StatelessWidget {
  const _DraftBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Draft - review before confirming',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.term, required this.dateFmt});

  final AcademicTerm term;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFmt.format(term.startDate)} - ${dateFmt.format(term.endDate)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (term.isConfirmed)
            const _StatusChip(label: 'Confirmed', color: Colors.green)
          else
            const _StatusChip(label: 'Draft', color: Colors.amber),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.shade800,
        ),
      ),
    );
  }
}
