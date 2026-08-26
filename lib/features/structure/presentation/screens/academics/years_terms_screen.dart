import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/services/structure_dependency_service.dart';
import '../../../domain/services/academic_year_setup_policy.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';
import '../../widgets/structure_wizard_banner.dart';

enum _YearFilter { all, current, upcoming, completed, inactive }

enum _TermFilter { all, current, upcoming, completed, inactive }

enum _YearOrder { newest, oldest, name }

enum _TermOrder { displayOrder, startDate, name }

class YearsTermsScreen extends StatefulWidget {
  const YearsTermsScreen({
    super.key,
    this.showTerms = false,
    this.wizardStep,
    this.wizardTotal,
  });
  final bool showTerms;
  final int? wizardStep;
  final int? wizardTotal;

  @override
  State<YearsTermsScreen> createState() => _YearsTermsScreenState();
}

class _YearsTermsScreenState extends State<YearsTermsScreen> {
  late int _tab;
  String _query = '';
  _YearFilter _yearFilter = _YearFilter.all;
  _TermFilter _termFilter = _TermFilter.all;
  String? _termYearId;
  _YearOrder _yearOrder = _YearOrder.newest;
  _TermOrder _termOrder = _TermOrder.displayOrder;
  final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _tab = widget.showTerms ? 1 : 0;
  }

  @override
  void didUpdateWidget(covariant YearsTermsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showTerms != widget.showTerms) {
      _tab = widget.showTerms ? 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        return Scaffold(
          appBar: AdminAppBar(
            title: _tab == 0 ? 'Academic Years' : 'Terms & Semesters',
            bottom: widget.wizardStep == null || widget.wizardTotal == null
                ? null
                : StructureWizardBanner(
                    stepId: _tab == 0 ? 'academic-years' : 'terms',
                    stepNumber: widget.wizardStep!,
                    totalSteps: widget.wizardTotal!,
                  ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tab == 0
                          ? 'Create and select the current academic year.'
                          : 'Manage terms or semesters for your academic years.',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    AppSearchFieldCompat(
                      hint: _tab == 0 ? 'Search years...' : 'Search terms...',
                      onChanged: (v) => setState(() => _query = v),
                      onFilter: () =>
                          _showFilters(context, state.academicYears),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _tab == 0
                    ? _YearsList(
                        state: state,
                        bloc: bloc,
                        schoolId: schoolId,
                        query: _query,
                        dateFmt: _dateFmt,
                        filter: _yearFilter,
                        order: _yearOrder,
                        onOrderChanged: (value) =>
                            setState(() => _yearOrder = value),
                      )
                    : _TermsList(
                        state: state,
                        bloc: bloc,
                        schoolId: schoolId,
                        query: _query,
                        dateFmt: _dateFmt,
                        filter: _termFilter,
                        academicYearId: _termYearId,
                        order: _termOrder,
                        onOrderChanged: (value) =>
                            setState(() => _termOrder = value),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _tab == 0
                ? _openYearForm(
                    context,
                    schoolId: schoolId,
                    bloc: bloc,
                    years: state.academicYears,
                  )
                : state.academicYears.isEmpty
                ? _openYearForm(
                    context,
                    schoolId: schoolId,
                    bloc: bloc,
                    years: state.academicYears,
                  )
                : _openTermForm(
                    context,
                    schoolId: schoolId,
                    bloc: bloc,
                    years: state.academicYears,
                    terms: state.academicTerms,
                  ),
            icon: const Icon(Icons.add),
            label: Text(_tab == 0 ? 'Add Year' : 'Add Term'),
          ),
        );
      },
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    List<AcademicYear> years,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tab == 0 ? 'Filter academic years' : 'Filter terms',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (_tab == 0)
                ..._YearFilter.values.map(
                  (filter) => RadioListTile<_YearFilter>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_yearFilterLabel(filter)),
                    value: filter,
                    groupValue: _yearFilter,
                    onChanged: (value) {
                      if (value != null) setState(() => _yearFilter = value);
                      Navigator.pop(sheetContext);
                    },
                  ),
                )
              else ...[
                ..._TermFilter.values.map(
                  (filter) => RadioListTile<_TermFilter>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_termFilterLabel(filter)),
                    value: filter,
                    groupValue: _termFilter,
                    onChanged: (value) {
                      if (value != null) setState(() => _termFilter = value);
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
                const Divider(),
                DropdownButtonFormField<String?>(
                  value: _termYearId,
                  decoration: const InputDecoration(labelText: 'Academic year'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All academic years'),
                    ),
                    ...years.map(
                      (year) => DropdownMenuItem<String?>(
                        value: year.id,
                        child: Text(year.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _termYearId = value),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Thin wrapper kept local to this screen so search styling matches other
/// Academics screens exactly without depending on AppSearchField's default
/// hint text.
class AppSearchFieldCompat extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  const AppSearchFieldCompat({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.filter_list_outlined),
          onPressed: onFilter,
          tooltip: 'Filter',
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _YearsList extends StatelessWidget {
  final StructureState state;
  final StructureBloc bloc;
  final String schoolId;
  final String query;
  final DateFormat dateFmt;
  final _YearFilter filter;
  final _YearOrder order;
  final ValueChanged<_YearOrder> onOrderChanged;

  const _YearsList({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
    required this.dateFmt,
    required this.filter,
    required this.order,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final years = state.academicYears.where((y) {
      final matchesQuery =
          y.name.toLowerCase().contains(query.toLowerCase()) ||
          y.description.toLowerCase().contains(query.toLowerCase());
      return matchesQuery && _matchesYearFilter(y, filter);
    }).toList();
    years.sort(
      (a, b) => switch (order) {
        _YearOrder.newest => b.startDate.compareTo(a.startDate),
        _YearOrder.oldest => a.startDate.compareTo(b.startDate),
        _YearOrder.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      },
    );

    if (years.isEmpty) {
      return StructureEmptyHint(
        query.isEmpty
            ? 'No academic years yet.\nAdd your school\'s current year to get started.'
            : 'No years match "$query".',
      );
    }

    final allYears = state.academicYears;
    final totalTerms = state.academicTerms.length;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: years.length + 2,
      itemBuilder: (context, index) {
        if (index == 0)
          return _YearSummary(years: allYears, totalTerms: totalTerms);
        if (index == 1)
          return _SectionHeader<_YearOrder>(
            label: 'ACADEMIC YEARS (${years.length})',
            value: order,
            items: const {
              _YearOrder.newest: 'Newest first',
              _YearOrder.oldest: 'Oldest first',
              _YearOrder.name: 'Name',
            },
            onChanged: onOrderChanged,
          );
        final year = years[index - 2];
        final termCount = state.academicTerms
            .where((t) => t.academicYearId == year.id)
            .length;
        return AppCardTapRow(
          icon: Icons.calendar_today_outlined,
          color: Colors.black,
          title: year.name,
          statusChip: _StatusChip.forYear(year),
          subtitle:
              '${dateFmt.format(year.startDate)} - ${dateFmt.format(year.endDate)}',
          trailingLabel: '$termCount Term${termCount == 1 ? '' : 's'}',
          onTap: () => _openYearForm(
            context,
            schoolId: schoolId,
            bloc: bloc,
            years: state.academicYears,
            existing: year,
          ),
        );
      },
    );
  }
}

class _TermsList extends StatelessWidget {
  final StructureState state;
  final StructureBloc bloc;
  final String schoolId;
  final String query;
  final DateFormat dateFmt;
  final _TermFilter filter;
  final String? academicYearId;
  final _TermOrder order;
  final ValueChanged<_TermOrder> onOrderChanged;

  const _TermsList({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
    required this.dateFmt,
    required this.filter,
    required this.academicYearId,
    required this.order,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (state.academicYears.isEmpty) {
      return const StructureEmptyHint('Add an academic year first.');
    }
    final yearsById = {for (final year in state.academicYears) year.id: year};
    final terms = state.academicTerms.where((term) {
      final yearName = yearsById[term.academicYearId]?.name ?? '';
      return (term.name.toLowerCase().contains(query.toLowerCase()) ||
              yearName.toLowerCase().contains(query.toLowerCase())) &&
          _matchesTermFilter(term, filter) &&
          (academicYearId == null || term.academicYearId == academicYearId);
    }).toList();
    terms.sort(
      (a, b) => switch (order) {
        _TermOrder.displayOrder =>
          a.order != b.order
              ? a.order.compareTo(b.order)
              : a.startDate.compareTo(b.startDate),
        _TermOrder.startDate => a.startDate.compareTo(b.startDate),
        _TermOrder.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      },
    );

    if (terms.isEmpty) {
      return StructureEmptyHint(
        query.isEmpty
            ? 'No terms defined yet.\nAdd Term 1/2/3, Semester 1/2, or whatever system this school uses.'
            : 'No terms match "$query".',
      );
    }

    final grouped = <AcademicYear, List<AcademicTerm>>{};
    for (final year in state.academicYears) {
      final termsForYear = terms
          .where((term) => term.academicYearId == year.id)
          .toList();
      if (termsForYear.isNotEmpty) grouped[year] = termsForYear;
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        _TermSummary(terms: state.academicTerms),
        _SectionHeader<_TermOrder>(
          label: 'TERMS/SEMESTERS (${terms.length})',
          value: order,
          items: const {
            _TermOrder.displayOrder: 'Display order',
            _TermOrder.startDate: 'Start date',
            _TermOrder.name: 'Name',
          },
          onChanged: onOrderChanged,
        ),
        ...grouped.entries.expand(
          (entry) => [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                entry.key.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            ...entry.value.map(
              (term) => AppCardTapRow(
                icon: Icons.event_note_outlined,
                color: Colors.black,
                title: term.name,
                statusChip: _StatusChip.forTerm(term),
                subtitle:
                    '${dateFmt.format(term.startDate)} - ${dateFmt.format(term.endDate)}',
                onTap: () => _openTermForm(
                  context,
                  schoolId: schoolId,
                  bloc: bloc,
                  years: state.academicYears,
                  terms: state.academicTerms,
                  existing: term,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _yearFilterLabel(_YearFilter value) => switch (value) {
  _YearFilter.all => 'All',
  _YearFilter.current => 'Current',
  _YearFilter.upcoming => 'Upcoming',
  _YearFilter.completed => 'Past / completed',
  _YearFilter.inactive => 'Inactive',
};

String _termFilterLabel(_TermFilter value) => switch (value) {
  _TermFilter.all => 'All',
  _TermFilter.current => 'Current',
  _TermFilter.upcoming => 'Upcoming',
  _TermFilter.completed => 'Completed',
  _TermFilter.inactive => 'Inactive',
};

bool _matchesYearFilter(AcademicYear year, _YearFilter filter) {
  final now = DateTime.now();
  return switch (filter) {
    _YearFilter.all => true,
    _YearFilter.current => year.isCurrent,
    _YearFilter.inactive => year.isArchived,
    _YearFilter.upcoming =>
      !year.isArchived && !year.isCurrent && year.startDate.isAfter(now),
    _YearFilter.completed =>
      !year.isArchived && !year.isCurrent && year.endDate.isBefore(now),
  };
}

bool _matchesTermFilter(AcademicTerm term, _TermFilter filter) {
  final now = DateTime.now();
  return switch (filter) {
    _TermFilter.all => true,
    _TermFilter.current => term.isCurrent,
    _TermFilter.inactive => term.isArchived,
    _TermFilter.upcoming =>
      !term.isArchived && !term.isCurrent && term.startDate.isAfter(now),
    _TermFilter.completed =>
      !term.isArchived && !term.isCurrent && term.endDate.isBefore(now),
  };
}

class _StatusChip {
  static Widget? forYear(AcademicYear year) {
    if (year.isCurrent)
      return const AcademicsStatusChip(label: 'Current', color: Colors.black);
    if (year.isArchived)
      return const AcademicsStatusChip(label: 'Inactive', color: Colors.black);
    if (year.startDate.isAfter(DateTime.now()))
      return const AcademicsStatusChip(label: 'Upcoming', color: Colors.black);
    if (year.endDate.isBefore(DateTime.now()))
      return const AcademicsStatusChip(label: 'Completed', color: Colors.black);
    return const AcademicsStatusChip(label: 'Active', color: Colors.black);
  }

  static Widget? forTerm(AcademicTerm term) {
    if (term.isCurrent)
      return const AcademicsStatusChip(label: 'Current', color: Colors.black);
    if (term.isArchived)
      return const AcademicsStatusChip(label: 'Inactive', color: Colors.black);
    if (term.startDate.isAfter(DateTime.now()))
      return const AcademicsStatusChip(label: 'Upcoming', color: Colors.black);
    if (term.endDate.isBefore(DateTime.now()))
      return const AcademicsStatusChip(label: 'Completed', color: Colors.black);
    return const AcademicsStatusChip(label: 'Active', color: Colors.black);
  }
}

class _YearSummary extends StatelessWidget {
  const _YearSummary({required this.years, required this.totalTerms});
  final List<AcademicYear> years;
  final int totalTerms;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: AcademicsOverviewCard(
      tiles: [
        AcademicsStatTile(label: 'Total Years', value: '${years.length}'),
        AcademicsStatTile(
          label: 'Active Years',
          value:
              '${years.where((y) => !y.isArchived && !y.endDate.isBefore(DateTime.now())).length}',
        ),
        AcademicsStatTile(label: 'Terms', value: '$totalTerms'),
        AcademicsStatTile(
          label: 'Current Year',
          value: '${years.where((y) => y.isCurrent).length}',
        ),
      ],
    ),
  );
}

class _TermSummary extends StatelessWidget {
  const _TermSummary({required this.terms});
  final List<AcademicTerm> terms;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: AcademicsOverviewCard(
      tiles: [
        AcademicsStatTile(label: 'Total Terms', value: '${terms.length}'),
        AcademicsStatTile(
          label: 'Active Terms',
          value:
              '${terms.where((t) => !t.isArchived && !t.endDate.isBefore(DateTime.now())).length}',
        ),
        AcademicsStatTile(
          label: 'Current Terms',
          value: '${terms.where((t) => t.isCurrent).length}',
        ),
        AcademicsStatTile(
          label: 'Upcoming',
          value:
              '${terms.where((t) => !t.isArchived && t.startDate.isAfter(DateTime.now())).length}',
        ),
      ],
    ),
  );
}

class _SectionHeader<T> extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
        PopupMenuButton<T>(
          initialValue: value,
          onSelected: onChanged,
          itemBuilder: (context) => items.entries
              .map(
                (entry) =>
                    PopupMenuItem(value: entry.key, child: Text(entry.value)),
              )
              .toList(),
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.sort, size: 16),
            label: const Text('Order'),
          ),
        ),
      ],
    ),
  );
}

/// A tappable record row with an optional status chip - the Years/Terms
/// equivalent of [AcademicsListCard], which doesn't support a chip slot.
class AppCardTapRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? statusChip;
  final String subtitle;
  final String? trailingLabel;
  final VoidCallback onTap;

  const AppCardTapRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.statusChip,
    required this.subtitle,
    this.trailingLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (statusChip != null) ...[
                          const SizedBox(width: 8),
                          statusChip!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: Colors.black),
                    ),
                  ],
                ),
              ),
              if (trailingLabel != null) ...[
                Text(
                  trailingLabel!,
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                const SizedBox(width: 6),
              ],
              Icon(Icons.chevron_right, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}

void _openYearForm(
  BuildContext context, {
  required String schoolId,
  required StructureBloc bloc,
  required List<AcademicYear> years,
  AcademicYear? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _YearFormScreen(
        schoolId: schoolId,
        years: years,
        existing: existing,
        onSave: (year) => bloc.add(SaveAcademicYearRequested(year)),
        onSetCurrent: existing == null
            ? null
            : () => bloc.add(
                SetCurrentAcademicYearRequested(existing.id, existing.schoolId),
              ),
        onDelete: existing == null
            ? null
            : () => bloc.add(DeleteAcademicYearRequested(existing.id)),
      ),
    ),
  );
}

void _openTermForm(
  BuildContext context, {
  required String schoolId,
  required StructureBloc bloc,
  required List<AcademicYear> years,
  required List<AcademicTerm> terms,
  AcademicTerm? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _TermFormScreen(
        schoolId: schoolId,
        years: years,
        terms: terms,
        existing: existing,
        onSave: (term) => bloc.add(SaveAcademicTermRequested(term)),
        onSetCurrent: existing == null
            ? null
            : () => bloc.add(
                SetCurrentAcademicTermRequested(existing.id, existing.schoolId),
              ),
        onDelete: existing == null
            ? null
            : () => bloc.add(DeleteAcademicTermRequested(existing.id)),
      ),
    ),
  );
}

class _YearFormScreen extends StatefulWidget {
  final String schoolId;
  final List<AcademicYear> years;
  final AcademicYear? existing;
  final void Function(AcademicYear) onSave;
  final VoidCallback? onSetCurrent;
  final VoidCallback? onDelete;

  const _YearFormScreen({
    required this.schoolId,
    required this.years,
    this.existing,
    required this.onSave,
    this.onSetCurrent,
    this.onDelete,
  });

  @override
  State<_YearFormScreen> createState() => _YearFormScreenState();
}

class _YearFormScreenState extends State<_YearFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description,
  );
  late DateTime? _startDate = widget.existing?.startDate;
  late DateTime? _endDate = widget.existing?.endDate;
  // A school needs one current year before the rest of its academic setup can
  // be used. Make the first active year current by default, while retaining
  // the saved value whenever an existing year is being edited.
  late bool _setCurrent =
      widget.existing?.isCurrent ??
      AcademicYearSetupPolicy.shouldSetNewYearCurrent(widget.years);
  final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Academic Year' : 'Add Academic Year',
      subtitle: isEdit
          ? 'Update this academic year.'
          : 'Create a new academic year for your school.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Year',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Year Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. 2024/2025'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Year name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Start Date *'),
              _DatePickerField(
                value: _startDate,
                placeholder: 'Select start date',
                formatter: _dateFmt,
                onPick: (d) => setState(() => _startDate = d),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('End Date *'),
              _DatePickerField(
                value: _endDate,
                placeholder: 'Select end date',
                formatter: _dateFmt,
                onPick: (d) => setState(() => _endDate = d),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Description'),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Optional description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Current Year'),
                subtitle: const Text('Only one year can be current'),
                value: _setCurrent,
                onChanged: (v) => setState(() => _setCurrent = v),
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final termCount = await di
                        .sl<StructureDependencyService>()
                        .countTermsInYear(widget.schoolId, widget.existing!.id);
                    if (termCount > 0) {
                      if (mounted) {
                        await showDeleteConfirmDialog(
                          context,
                          title: 'Can\'t Delete Year',
                          message:
                              '"${widget.existing!.name}" still has $termCount '
                              'term(s) configured under it. Delete those '
                              'terms first.',
                        );
                      }
                      return;
                    }
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Year',
                      message: 'Delete "${widget.existing!.name}"?',
                    );
                    if (confirmed == true && mounted) {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  label: const Text(
                    'Delete Year',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }
    final duplicate = widget.years.any(
      (year) =>
          year.id != widget.existing?.id &&
          year.name.trim().toLowerCase() ==
              _nameController.text.trim().toLowerCase(),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An academic year with this name already exists.'),
        ),
      );
      return;
    }
    widget.onSave(
      AcademicYear(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        description: _descController.text.trim(),
        isCurrent: _setCurrent,
        isArchived: widget.existing?.isArchived ?? false,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existing != null
                ? 'Academic year updated.'
                : 'Academic year saved.',
          ),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _TermFormScreen extends StatefulWidget {
  final String schoolId;
  final List<AcademicYear> years;
  final List<AcademicTerm> terms;
  final AcademicTerm? existing;
  final void Function(AcademicTerm) onSave;
  final VoidCallback? onSetCurrent;
  final VoidCallback? onDelete;

  const _TermFormScreen({
    required this.schoolId,
    required this.years,
    required this.terms,
    this.existing,
    required this.onSave,
    this.onSetCurrent,
    this.onDelete,
  });

  @override
  State<_TermFormScreen> createState() => _TermFormScreenState();
}

class _TermFormScreenState extends State<_TermFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _orderController = TextEditingController(
    text: widget.existing?.order.toString() ?? '',
  );
  late String? _yearId =
      widget.existing?.academicYearId ??
      (widget.years.isNotEmpty ? widget.years.first.id : null);
  late DateTime? _startDate = widget.existing?.startDate;
  late DateTime? _endDate = widget.existing?.endDate;
  late bool _setCurrent = widget.existing?.isCurrent ?? false;
  final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  AcademicYear? get _selectedYear =>
      widget.years.where((y) => y.id == _yearId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Term' : 'Add Term',
      subtitle: isEdit
          ? 'Update this term or period.'
          : 'Create a new term, semester or period for an academic year.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Term',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Term 1'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Academic Year *'),
              DropdownButtonFormField<String>(
                initialValue: _yearId,
                items: widget.years
                    .map(
                      (y) => DropdownMenuItem(value: y.id, child: Text(y.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _yearId = v),
                validator: (v) => v == null ? 'Select an academic year' : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Start Date *'),
              _DatePickerField(
                value: _startDate,
                placeholder: 'Select start date',
                formatter: _dateFmt,
                onPick: (d) => setState(() => _startDate = d),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('End Date *'),
              _DatePickerField(
                value: _endDate,
                placeholder: 'Select end date',
                formatter: _dateFmt,
                onPick: (d) => setState(() => _endDate = d),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Display Order'),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(hintText: 'e.g. 1'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Current Term'),
                subtitle: const Text('Only one term can be current'),
                value: _setCurrent,
                onChanged: (v) => setState(() => _setCurrent = v),
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Term',
                      message: 'Delete "${widget.existing!.name}"?',
                    );
                    if (confirmed == true && mounted) {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  label: const Text(
                    'Delete Term',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }
    final year = _selectedYear;
    if (year != null &&
        (_startDate!.isBefore(year.startDate) ||
            _endDate!.isAfter(year.endDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dates must fall within ${year.name}\'s date range'),
        ),
      );
      return;
    }
    final overlaps = widget.terms.any(
      (term) =>
          term.id != widget.existing?.id &&
          term.academicYearId == _yearId &&
          !term.isArchived &&
          _startDate!.isBefore(term.endDate) &&
          _endDate!.isAfter(term.startDate),
    );
    if (overlaps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This term overlaps another term.')),
      );
      return;
    }
    if (_setCurrent && year != null && !year.isCurrent) {
      final setYearCurrent = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Set current academic year?'),
          content: Text(
            'This term belongs to ${year.name}, which is not the current academic year. It will also be set as current.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (setYearCurrent != true) return;
    }
    widget.onSave(
      AcademicTerm(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        academicYearId: _yearId!,
        name: _nameController.text.trim(),
        order: int.tryParse(_orderController.text) ?? 0,
        startDate: _startDate!,
        endDate: _endDate!,
        isCurrent: _setCurrent,
        periodType: widget.existing?.periodType ?? AcademicPeriodType.term,
        isArchived: widget.existing?.isArchived ?? false,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existing != null ? 'Term updated.' : 'Term saved.',
          ),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final String placeholder;
  final DateFormat formatter;
  final ValueChanged<DateTime> onPick;

  const _DatePickerField({
    required this.value,
    required this.placeholder,
    required this.formatter,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          value != null ? formatter.format(value!) : placeholder,
          style: TextStyle(
            color: value != null ? null : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
