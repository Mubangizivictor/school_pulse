import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/structure_entities.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';

class YearsTermsScreen extends StatefulWidget {
  const YearsTermsScreen({super.key});

  @override
  State<YearsTermsScreen> createState() => _YearsTermsScreenState();
}

class _YearsTermsScreenState extends State<YearsTermsScreen> {
  int _tab = 0;
  String _query = '';
  final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        return Scaffold(
          appBar: const AdminAppBar(title: 'Years & Terms'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage academic years and their associated terms or semesters.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    AcademicsSegmentedTabs(
                      labels: const ['Years', 'Terms/Semesters'],
                      selectedIndex: _tab,
                      onSelected: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 12),
                    AppSearchFieldCompat(
                      hint: _tab == 0 ? 'Search years...' : 'Search terms...',
                      onChanged: (v) => setState(() => _query = v),
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
                      )
                    : _TermsList(
                        state: state,
                        bloc: bloc,
                        schoolId: schoolId,
                        query: _query,
                        dateFmt: _dateFmt,
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _tab == 0
                ? _openYearForm(context, schoolId: schoolId, bloc: bloc)
                : _openTermForm(
                    context,
                    schoolId: schoolId,
                    bloc: bloc,
                    years: state.academicYears,
                  ),
            icon: const Icon(Icons.add),
            label: Text(_tab == 0 ? 'Add Year' : 'Add Term'),
          ),
        );
      },
    );
  }
}

/// Thin wrapper kept local to this screen so search styling matches other
/// Academics screens exactly without depending on AppSearchField's default
/// hint text.
class AppSearchFieldCompat extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const AppSearchFieldCompat({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
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

  const _YearsList({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    final years = state.academicYears
        .where((y) => y.name.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    if (years.isEmpty) {
      return StructureEmptyHint(
        query.isEmpty
            ? 'No academic years yet.\nAdd your school\'s current year to get started.'
            : 'No years match "$query".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final termCount = state.academicTerms
            .where((t) => t.academicYearId == year.id)
            .length;
        return AppCardTapRow(
          icon: Icons.calendar_today_outlined,
          color: Colors.blue,
          title: year.name,
          statusChip: year.isCurrent
              ? const AcademicsStatusChip(label: 'Current', color: Colors.green)
              : (year.isArchived
                    ? const AcademicsStatusChip(
                        label: 'Completed',
                        color: Colors.grey,
                      )
                    : null),
          subtitle:
              '${dateFmt.format(year.startDate)} - ${dateFmt.format(year.endDate)}',
          trailingLabel: '$termCount Term${termCount == 1 ? '' : 's'}',
          onTap: () => _openYearForm(
            context,
            schoolId: schoolId,
            bloc: bloc,
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

  const _TermsList({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    if (state.academicYears.isEmpty) {
      return const StructureEmptyHint('Add an academic year first.');
    }
    final terms = state.academicTerms
        .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (terms.isEmpty) {
      return StructureEmptyHint(
        query.isEmpty
            ? 'No terms defined yet.\nAdd Term 1/2/3, Semester 1/2, or whatever system this school uses.'
            : 'No terms match "$query".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final term = terms[index];
        final year = state.academicYears
            .where((y) => y.id == term.academicYearId)
            .firstOrNull;
        return AppCardTapRow(
          icon: Icons.event_note_outlined,
          color: Colors.indigo,
          title: term.name,
          statusChip: term.isCurrent
              ? const AcademicsStatusChip(label: 'Current', color: Colors.green)
              : null,
          subtitle:
              '${year?.name ?? 'Unknown year'} - ${dateFmt.format(term.startDate)} to ${dateFmt.format(term.endDate)}',
          onTap: () => _openTermForm(
            context,
            schoolId: schoolId,
            bloc: bloc,
            years: state.academicYears,
            existing: term,
          ),
        );
      },
    );
  }
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
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.8),
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
                      style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (trailingLabel != null) ...[
                Text(
                  trailingLabel!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 6),
              ],
              Icon(Icons.chevron_right, color: Colors.grey[500]),
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
  AcademicYear? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _YearFormScreen(
        schoolId: schoolId,
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
  AcademicTerm? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _TermFormScreen(
        schoolId: schoolId,
        years: years,
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
  final AcademicYear? existing;
  final void Function(AcademicYear) onSave;
  final VoidCallback? onSetCurrent;
  final VoidCallback? onDelete;

  const _YearFormScreen({
    required this.schoolId,
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
  final _descController = TextEditingController();
  late DateTime? _startDate = widget.existing?.startDate;
  late DateTime? _endDate = widget.existing?.endDate;
  late bool _setCurrent = widget.existing?.isCurrent ?? false;
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
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Year name is required' : null,
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
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Year',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
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
        isCurrent: widget.existing?.isCurrent ?? false,
        isArchived: widget.existing?.isArchived ?? false,
      ),
    );
    if (_setCurrent && widget.onSetCurrent != null) {
      widget.onSetCurrent!();
    }
    Navigator.of(context).pop();
  }
}

class _TermFormScreen extends StatefulWidget {
  final String schoolId;
  final List<AcademicYear> years;
  final AcademicTerm? existing;
  final void Function(AcademicTerm) onSave;
  final VoidCallback? onSetCurrent;
  final VoidCallback? onDelete;

  const _TermFormScreen({
    required this.schoolId,
    required this.years,
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
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Term',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
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
    widget.onSave(
      AcademicTerm(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        academicYearId: _yearId!,
        name: _nameController.text.trim(),
        order: int.tryParse(_orderController.text) ?? 0,
        startDate: _startDate!,
        endDate: _endDate!,
        isCurrent: widget.existing?.isCurrent ?? false,
        periodType: widget.existing?.periodType ?? AcademicPeriodType.term,
        isArchived: widget.existing?.isArchived ?? false,
      ),
    );
    if (_setCurrent && widget.onSetCurrent != null) {
      widget.onSetCurrent!();
    }
    Navigator.of(context).pop();
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
