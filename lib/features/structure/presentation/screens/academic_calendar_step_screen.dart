import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/structure_entities.dart';
import '../../domain/services/structure_integrity_validator.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';

const _validator = StructureIntegrityValidator();

/// Names for the required periods of a chosen calendar system, in order.
/// Terms use 3 required periods, Semesters use 2 - matching the reference
/// screenshots (Term 1/2/3 accordions, or Semester 1/2).
List<String> _requiredPeriodNames(AcademicPeriodType system) {
  return system == AcademicPeriodType.semester
      ? const ['Semester 1', 'Semester 2']
      : const ['Term 1', 'Term 2', 'Term 3'];
}

/// One in-progress edit of a term/semester accordion row. Kept separate from
/// [AcademicTerm] so an incomplete or invalid row never gets dispatched to
/// the bloc - only [toTermIfValid] materialises a real entity once both
/// dates are present.
class _PeriodDraft {
  _PeriodDraft({
    required this.slotIndex,
    required this.periodType,
    required this.defaultName,
    AcademicTerm? existing,
  }) : id = existing?.id ?? const Uuid().v4(),
       name = existing?.name ?? defaultName,
       startDate = existing?.startDate,
       endDate = existing?.endDate,
       closureStartDate = existing?.closureStartDate,
       closureEndDate = existing?.closureEndDate,
       isCurrent = existing?.isCurrent ?? false,
       order = existing?.order ?? (slotIndex + 1);

  final String id;
  final int slotIndex;
  final AcademicPeriodType periodType;
  final String defaultName;
  final int order;
  String name;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? closureStartDate;
  DateTime? closureEndDate;
  bool isCurrent;

  bool get hasRequiredDates => startDate != null && endDate != null;

  /// Builds the candidate entity for validation/dispatch. Only meaningful
  /// once [hasRequiredDates] is true.
  AcademicTerm toCandidate({
    required String schoolId,
    required String academicYearId,
  }) {
    return AcademicTerm(
      id: id,
      schoolId: schoolId,
      academicYearId: academicYearId,
      name: name.trim().isEmpty ? defaultName : name.trim(),
      order: order,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now(),
      isCurrent: isCurrent,
      periodType: periodType,
      closureStartDate: closureStartDate,
      closureEndDate: closureEndDate,
    );
  }
}

/// Step 3 of School Setup: "Academic calendar". Redesigned per the reference
/// screenshots as its own focused wizard step (compact "N of 16" header +
/// step rail on wide/web layouts, like Step 1's [_InstitutionProfileStep]),
/// replacing the previous timeline-list + bottom-sheet editor with inline
/// Term/Semester accordions on one scrollable page.
class AcademicCalendarStepScreen extends StatefulWidget {
  const AcademicCalendarStepScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.stepIndex,
    required this.stepCount,
  });

  final Future<void> Function() onBack;
  final Future<void> Function() onContinue;
  final int stepIndex;
  final int stepCount;

  @override
  State<AcademicCalendarStepScreen> createState() =>
      _AcademicCalendarStepScreenState();
}

class _AcademicCalendarStepScreenState
    extends State<AcademicCalendarStepScreen> {
  AcademicPeriodType? _selectedSystem;
  final Map<int, _PeriodDraft> _drafts = {};
  final Set<int> _expanded = {};
  bool _isSaving = false;
  bool _initialisedFromState = false;
  String? _lastYearId;

  AcademicYear? _currentYear(StructureState state) => state.academicYears
      .where((year) => year.isCurrent && !year.isArchived)
      .firstOrNull;

  List<AcademicTerm> _termsForYear(StructureState state, String yearId) =>
      state.academicTerms
          .where((t) => t.academicYearId == yearId && !t.isArchived)
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  void _seedFromExisting(StructureState state, AcademicYear year) {
    final existing = _termsForYear(state, year.id);
    if (existing.isNotEmpty) {
      _selectedSystem = existing.first.periodType;
    }
    if (_selectedSystem != null) {
      _rebuildDrafts(existing);
    }
    _initialisedFromState = true;
    _lastYearId = year.id;
  }

  void _rebuildDrafts(List<AcademicTerm> existing) {
    final names = _requiredPeriodNames(_selectedSystem!);
    _drafts.clear();
    for (var i = 0; i < names.length; i++) {
      final match = i < existing.length ? existing[i] : null;
      _drafts[i] = _PeriodDraft(
        slotIndex: i,
        periodType: _selectedSystem!,
        defaultName: names[i],
        existing: match,
      );
    }
    // Auto-expand the first required period missing its dates.
    final firstIncomplete = _drafts.values
        .firstWhere(
          (d) => !d.hasRequiredDates,
          orElse: () => _drafts.values.first,
        )
        .slotIndex;
    _expanded
      ..clear()
      ..add(firstIncomplete);
  }

  void _selectSystem(AcademicPeriodType type) {
    setState(() {
      _selectedSystem = type;
      _rebuildDrafts(const []);
    });
  }

  String? _validateDraft(
    _PeriodDraft draft,
    StructureState state,
    AcademicYear year,
  ) {
    if (!draft.hasRequiredDates) return 'Set both a start and end date.';
    final candidate = draft.toCandidate(
      schoolId: year.schoolId,
      academicYearId: year.id,
    );
    final otherTerms = state.academicTerms
        .where((t) => t.id != candidate.id)
        .toList();
    final baseError = _validator.validateAcademicTerm(
      candidate,
      state.academicYears,
      otherTerms,
    );
    if (baseError != null) return baseError;
    if (draft.closureStartDate != null || draft.closureEndDate != null) {
      if (draft.closureStartDate == null || draft.closureEndDate == null) {
        return 'Set both a closure start and end date, or leave both empty.';
      }
      if (draft.closureStartDate!.isAfter(draft.closureEndDate!)) {
        return 'Closure end date must be on or after the closure start date.';
      }
      if (draft.closureStartDate!.isBefore(candidate.startDate) ||
          draft.closureEndDate!.isAfter(candidate.endDate)) {
        return 'The closure range must fall within ${candidate.name}.';
      }
    }
    return null;
  }

  bool _allRequiredValid(StructureState state, AcademicYear year) {
    if (_selectedSystem == null || _drafts.isEmpty) return false;
    for (final draft in _drafts.values) {
      if (_validateDraft(draft, state, year) != null) return false;
    }
    return true;
  }

  Future<void> _save(StructureState state, AcademicYear year) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final bloc = context.read<StructureBloc>();
    try {
      for (final draft in _drafts.values) {
        final candidate = draft.toCandidate(
          schoolId: year.schoolId,
          academicYearId: year.id,
        );
        bloc.add(SaveAcademicTermRequested(candidate));
      }
      // Give the bloc a tick to process each dispatched event before
      // deciding whether to advance - saves are fire-and-forget events,
      // not awaited futures, matching the rest of this bloc's usage.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      await widget.onContinue();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changeYear(BuildContext context, StructureState state) async {
    final bloc = context.read<StructureBloc>();
    final picked = await showModalBottomSheet<AcademicYear>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _YearPickerSheet(years: state.academicYears),
    );
    if (picked == null) return;
    if (!mounted) return;
    if (!picked.isCurrent) {
      bloc.add(SetCurrentAcademicYearRequested(picked.id, picked.schoolId));
    }
    setState(() {
      _initialisedFromState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StructureBloc, StructureState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => context.read<StructureBloc>().add(
                  LoadStructureData(state.academicYears.firstOrNull?.schoolId ?? ''),
                ),
              ),
            ),
          );
      },
      child: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          if (state.isLoading && state.academicYears.isEmpty) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final year = _currentYear(state);
          if (year == null) {
            return _NoYearScaffold(onBack: widget.onBack);
          }
          if (!_initialisedFromState || _lastYearId != year.id) {
            _seedFromExisting(state, year);
          }
          return _CalendarStepShell(
            stepIndex: widget.stepIndex,
            stepCount: widget.stepCount,
            onBack: widget.onBack,
            body: _CalendarBody(
              state: state,
              year: year,
              selectedSystem: _selectedSystem,
              drafts: _drafts,
              expanded: _expanded,
              onSelectSystem: _selectSystem,
              onToggleExpand: (index) => setState(() {
                _expanded.contains(index)
                    ? _expanded.remove(index)
                    : _expanded.add(index);
              }),
              onChangeYear: () => _changeYear(context, state),
              validateDraft: (draft) => _validateDraft(draft, state, year),
              onDraftChanged: () => setState(() {}),
            ),
            footer: _CalendarFooter(
              isSaving: _isSaving,
              continueEnabled: _allRequiredValid(state, year),
              onBack: widget.onBack,
              onContinue: () => _save(state, year),
            ),
          );
        },
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _NoYearScaffold extends StatelessWidget {
  const _NoYearScaffold({required this.onBack});

  final Future<void> Function() onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic calendar'),
        leading: BackButton(onPressed: () => onBack()),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Center(
            child: Text(
              'Return to Academic Years and select one current year first.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile/tablet compact header + web step-rail shell, mirroring the
/// treatment `_InstitutionProfileStep` gives Step 1 in structure_screen.dart.
/// This step has no draft-save concept (live Firestore saves via bloc events
/// already are the persistence), so unlike Step 1 there is no "Save draft"
/// action here.
class _CalendarStepShell extends StatelessWidget {
  const _CalendarStepShell({
    required this.stepIndex,
    required this.stepCount,
    required this.onBack,
    required this.body,
    required this.footer,
  });

  final int stepIndex;
  final int stepCount;
  final Future<void> Function() onBack;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StepRail(stepIndex: stepIndex, stepCount: stepCount),
                  VerticalDivider(width: 1, color: scheme.outlineVariant),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
                          child: Row(
                            children: [
                              TextButton.icon(
                                onPressed: onBack,
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                ),
                                label: const Text('Back'),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Academic calendar',
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _CompactHeader(
                  onBack: onBack,
                  stepIndex: stepIndex,
                  stepCount: stepCount,
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                Expanded(child: body),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(top: false, child: footer),
    );
  }
}

/// Mobile/tablet sticky top bar: Back, then "N of 16 · Academic calendar"
/// with a percent and a thin progress bar - same treatment as Step 1's
/// `_WizardCompactHeader` in structure_screen.dart, without the Save-draft
/// action (this step has no draft concept).
class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.onBack,
    required this.stepIndex,
    required this.stepCount,
  });

  final Future<void> Function() onBack;
  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (((stepIndex + 1) / stepCount) * 100).round();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    color: scheme.onSurface,
                  ),
                  const Expanded(
                    child: Text(
                      'School setup',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${stepIndex + 1} of $stepCount · Academic calendar',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (stepIndex + 1) / stepCount,
                  minHeight: 5,
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Narrow left step rail shown on wide/web layouts - a condensed version of
/// structure_screen.dart's `_WizardStepNavigator`, without the full step
/// title list (which lives only in the main wizard shell) or Save-draft.
class _StepRail extends StatelessWidget {
  const _StepRail({required this.stepIndex, required this.stepCount});

  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (((stepIndex + 1) / stepCount) * 100).round();
    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School setup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              '${stepIndex + 1} of $stepCount · $percent% complete',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (stepIndex + 1) / stepCount,
                minHeight: 4,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarFooter extends StatelessWidget {
  const _CalendarFooter({
    required this.isSaving,
    required this.continueEnabled,
    required this.onBack,
    required this.onContinue,
  });

  final bool isSaving;
  final bool continueEnabled;
  final Future<void> Function() onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: isSaving ? null : onBack,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: (!continueEnabled || isSaving)
                              ? null
                              : onContinue,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save & continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The scrollable form canvas: year card, system chooser, accordions,
/// info note, copy-from-another-year row. On wide/web layouts a right-hand
/// "Calendar summary" panel is shown alongside; mobile shows only the form.
class _CalendarBody extends StatelessWidget {
  const _CalendarBody({
    required this.state,
    required this.year,
    required this.selectedSystem,
    required this.drafts,
    required this.expanded,
    required this.onSelectSystem,
    required this.onToggleExpand,
    required this.onChangeYear,
    required this.validateDraft,
    required this.onDraftChanged,
  });

  final StructureState state;
  final AcademicYear year;
  final AcademicPeriodType? selectedSystem;
  final Map<int, _PeriodDraft> drafts;
  final Set<int> expanded;
  final ValueChanged<AcademicPeriodType> onSelectSystem;
  final ValueChanged<int> onToggleExpand;
  final VoidCallback onChangeYear;
  final String? Function(_PeriodDraft) validateDraft;
  final VoidCallback onDraftChanged;

  bool get _hasOtherYearData => state.academicYears.any(
    (y) =>
        y.id != year.id &&
        state.academicTerms.any((t) => t.academicYearId == y.id && !t.isArchived),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final form = _CalendarForm(
          state: state,
          year: year,
          selectedSystem: selectedSystem,
          drafts: drafts,
          expanded: expanded,
          onSelectSystem: onSelectSystem,
          onToggleExpand: onToggleExpand,
          onChangeYear: onChangeYear,
          validateDraft: validateDraft,
          onDraftChanged: onDraftChanged,
          showCopyRow: _hasOtherYearData,
        );
        if (!isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: form,
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: form,
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 280,
                    child: _CalendarSummaryPanel(
                      year: year,
                      selectedSystem: selectedSystem,
                      drafts: drafts,
                      validateDraft: validateDraft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CalendarForm extends StatelessWidget {
  const _CalendarForm({
    required this.state,
    required this.year,
    required this.selectedSystem,
    required this.drafts,
    required this.expanded,
    required this.onSelectSystem,
    required this.onToggleExpand,
    required this.onChangeYear,
    required this.validateDraft,
    required this.onDraftChanged,
    required this.showCopyRow,
  });

  final StructureState state;
  final AcademicYear year;
  final AcademicPeriodType? selectedSystem;
  final Map<int, _PeriodDraft> drafts;
  final Set<int> expanded;
  final ValueChanged<AcademicPeriodType> onSelectSystem;
  final ValueChanged<int> onToggleExpand;
  final VoidCallback onChangeYear;
  final String? Function(_PeriodDraft) validateDraft;
  final VoidCallback onDraftChanged;
  final bool showCopyRow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _YearCard(
          year: year,
          dateLabel: '${fmt.format(year.startDate)} – ${fmt.format(year.endDate)}',
          onChangeYear: onChangeYear,
        ),
        const SizedBox(height: 20),
        Text(
          'How is your year organised?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose one calendar system for this academic year.',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        _SystemChoiceCard(
          key: const Key('academicCalendar_termsCard'),
          icon: Icons.calendar_view_month_outlined,
          title: 'Terms',
          subtitle: 'Usually 3 periods',
          badge: 'Recommended',
          selected: selectedSystem == AcademicPeriodType.term,
          onTap: () => onSelectSystem(AcademicPeriodType.term),
        ),
        const SizedBox(height: 12),
        _SystemChoiceCard(
          key: const Key('academicCalendar_semestersCard'),
          icon: Icons.menu_book_outlined,
          title: 'Semesters',
          subtitle: 'Usually 2 periods',
          selected: selectedSystem == AcademicPeriodType.semester,
          onTap: () => onSelectSystem(AcademicPeriodType.semester),
        ),
        if (selectedSystem != null) ...[
          const SizedBox(height: 24),
          for (final entry in drafts.entries) ...[
            _PeriodAccordion(
              key: ValueKey('period-${entry.key}'),
              draft: entry.value,
              year: year,
              isExpanded: expanded.contains(entry.key),
              onToggle: () => onToggleExpand(entry.key),
              error: validateDraft(entry.value),
              onChanged: onDraftChanged,
            ),
            const SizedBox(height: 12),
          ],
          _InfoNote(
            text:
                'Changing the current academic calendar can affect existing '
                'schedules, timetables and reports. Review carefully before '
                'saving.',
          ),
          if (showCopyRow) ...[
            const SizedBox(height: 12),
            _CopyFromYearRow(
              onTap: () => _showCopyFromYearSheet(context),
            ),
          ],
        ],
      ],
    );
  }

  void _showCopyFromYearSheet(BuildContext context) {
    final otherYears = state.academicYears.where((y) => y.id != year.id).toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _CopyFromYearSheet(
        years: otherYears,
        terms: state.academicTerms,
        onPick: (sourceTerms) {
          for (var i = 0; i < drafts.length && i < sourceTerms.length; i++) {
            final draft = drafts[i]!;
            final source = sourceTerms[i];
            draft.startDate = source.startDate;
            draft.endDate = source.endDate;
            draft.closureStartDate = source.closureStartDate;
            draft.closureEndDate = source.closureEndDate;
          }
          onDraftChanged();
        },
      ),
    );
  }
}

class _YearCard extends StatelessWidget {
  const _YearCard({
    required this.year,
    required this.dateLabel,
    required this.onChangeYear,
  });

  final AcademicYear year;
  final String dateLabel;
  final VoidCallback onChangeYear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic year ${year.name}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  dateLabel,
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          TextButton(
            key: const Key('academicCalendar_changeYear'),
            onPressed: onChangeYear,
            child: const Text('Change year'),
          ),
        ],
      ),
    );
  }
}

class _SystemChoiceCard extends StatelessWidget {
  const _SystemChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodAccordion extends StatelessWidget {
  const _PeriodAccordion({
    super.key,
    required this.draft,
    required this.year,
    required this.isExpanded,
    required this.onToggle,
    required this.error,
    required this.onChanged,
  });

  final _PeriodDraft draft;
  final AcademicYear year;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? error;
  final VoidCallback onChanged;

  String get _statusLabel {
    if (!draft.hasRequiredDates) return 'Not set';
    if (error != null) return 'Error';
    return 'Complete';
  }

  Color _statusColor(ColorScheme scheme) {
    if (!draft.hasRequiredDates) return scheme.onSurfaceVariant;
    if (error != null) return scheme.error;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd MMM yyyy');
    final dateRangeLabel = draft.hasRequiredDates
        ? '${fmt.format(draft.startDate!)} – ${fmt.format(draft.endDate!)}'
        : 'No dates set';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.name.trim().isEmpty ? draft.defaultName : draft.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        if (!isExpanded) ...[
                          const SizedBox(height: 2),
                          Text(
                            dateRangeLabel,
                            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(scheme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(scheme),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: draft.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      draft.name = value;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AcademicYearDateField(
                          label: 'Start date',
                          value: draft.startDate == null
                              ? 'Select start date'
                              : fmt.format(draft.startDate!),
                          isPlaceholder: draft.startDate == null,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: draft.startDate ?? year.startDate,
                              firstDate: year.startDate,
                              lastDate: year.endDate,
                            );
                            if (picked == null) return;
                            draft.startDate = picked;
                            onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AcademicYearDateField(
                          label: 'End date',
                          value: draft.endDate == null
                              ? 'Select end date'
                              : fmt.format(draft.endDate!),
                          isPlaceholder: draft.endDate == null,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: draft.endDate ?? year.endDate,
                              firstDate: year.startDate,
                              lastDate: year.endDate,
                            );
                            if (picked == null) return;
                            draft.endDate = picked;
                            onChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'School closure (optional)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: AcademicYearDateField(
                          label: 'From',
                          value: draft.closureStartDate == null
                              ? 'Optional'
                              : fmt.format(draft.closureStartDate!),
                          isPlaceholder: draft.closureStartDate == null,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  draft.closureStartDate ??
                                  draft.startDate ??
                                  year.startDate,
                              firstDate: draft.startDate ?? year.startDate,
                              lastDate: draft.endDate ?? year.endDate,
                            );
                            if (picked == null) return;
                            draft.closureStartDate = picked;
                            onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AcademicYearDateField(
                          label: 'To',
                          value: draft.closureEndDate == null
                              ? 'Optional'
                              : fmt.format(draft.closureEndDate!),
                          isPlaceholder: draft.closureEndDate == null,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  draft.closureEndDate ??
                                  draft.endDate ??
                                  year.endDate,
                              firstDate: draft.startDate ?? year.startDate,
                              lastDate: draft.endDate ?? year.endDate,
                            );
                            if (picked == null) return;
                            draft.closureEndDate = picked;
                            onChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, size: 16, color: scheme.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            error!,
                            style: TextStyle(fontSize: 12, color: scheme.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Pale-blue informational note. No shared `InfoBanner` widget exists yet in
/// the design system (grep found only outline-bordered info containers), so
/// this is a small local widget matching the reference's pale-blue styling.
class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.blue.shade900.withValues(alpha: 0.25) : Colors.blue.shade50;
    final fg = isDark ? Colors.blue.shade100 : Colors.blue.shade900;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.5, color: fg, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _CopyFromYearRow extends StatelessWidget {
  const _CopyFromYearRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      key: const Key('academicCalendar_copyFromYear'),
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.copy_all_outlined, size: 18, color: scheme.primary),
            const SizedBox(width: 10),
            const Expanded(child: Text('Copy dates from another year')),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

/// Web-only right-hand panel summarising each period's status and the
/// academic year range. Never shown on mobile per the reference screenshots.
class _CalendarSummaryPanel extends StatelessWidget {
  const _CalendarSummaryPanel({
    required this.year,
    required this.selectedSystem,
    required this.drafts,
    required this.validateDraft,
  });

  final AcademicYear year;
  final AcademicPeriodType? selectedSystem;
  final Map<int, _PeriodDraft> drafts;
  final String? Function(_PeriodDraft) validateDraft;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd MMM yyyy');
    return Container(
      key: const Key('academicCalendar_summaryPanel'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar summary',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: scheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            '${fmt.format(year.startDate)} – ${fmt.format(year.endDate)}',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (selectedSystem == null)
            Text(
              'Choose a calendar system to see a summary.',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            )
          else
            for (final draft in drafts.values) ...[
              _SummaryRow(draft: draft, error: validateDraft(draft)),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.draft, required this.error});

  final _PeriodDraft draft;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd MMM');
    final status = !draft.hasRequiredDates
        ? 'Not set'
        : (error != null ? 'Error' : 'Complete');
    final color = !draft.hasRequiredDates
        ? scheme.onSurfaceVariant
        : (error != null ? scheme.error : Colors.green.shade700);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft.name.trim().isEmpty ? draft.defaultName : draft.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (draft.hasRequiredDates)
                Text(
                  '${fmt.format(draft.startDate!)} – ${fmt.format(draft.endDate!)}',
                  style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        Text(
          status,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _YearPickerSheet extends StatelessWidget {
  const _YearPickerSheet({required this.years});

  final List<AcademicYear> years;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final sorted = [...years]..sort((a, b) => b.startDate.compareTo(a.startDate));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change year',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final year in sorted)
              ListTile(
                key: Key('academicCalendar_yearOption_${year.id}'),
                title: Text(year.name),
                subtitle: Text('${fmt.format(year.startDate)} – ${fmt.format(year.endDate)}'),
                trailing: year.isCurrent ? const Icon(Icons.check_circle) : null,
                onTap: () => Navigator.pop(context, year),
              ),
          ],
        ),
      ),
    );
  }
}

class _CopyFromYearSheet extends StatefulWidget {
  const _CopyFromYearSheet({
    required this.years,
    required this.terms,
    required this.onPick,
  });

  final List<AcademicYear> years;
  final List<AcademicTerm> terms;
  final ValueChanged<List<AcademicTerm>> onPick;

  @override
  State<_CopyFromYearSheet> createState() => _CopyFromYearSheetState();
}

class _CopyFromYearSheetState extends State<_CopyFromYearSheet> {
  @override
  Widget build(BuildContext context) {
    final eligibleYears = widget.years
        .where((y) => widget.terms.any((t) => t.academicYearId == y.id && !t.isArchived))
        .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copy dates from another year',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (eligibleYears.isEmpty)
              const Text('No other year has calendar data yet.')
            else
              for (final year in eligibleYears)
                ListTile(
                  key: Key('academicCalendar_copySource_${year.id}'),
                  title: Text(year.name),
                  onTap: () {
                    final sourceTerms =
                        widget.terms
                            .where((t) => t.academicYearId == year.id && !t.isArchived)
                            .toList()
                          ..sort((a, b) => a.startDate.compareTo(b.startDate));
                    widget.onPick(sourceTerms);
                    Navigator.pop(context);
                  },
                ),
          ],
        ),
      ),
    );
  }
}
