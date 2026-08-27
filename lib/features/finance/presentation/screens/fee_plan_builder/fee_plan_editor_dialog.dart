import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/features/finance/domain/entities/fee_catalogue_item.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_plan.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_billing_repository.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_catalogue_repository.dart';
import 'package:school_pulse/features/finance/presentation/bloc/fee_plan_builder/fee_plan_builder_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/fee_plan_builder/fee_plan_builder_event.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

/// Pure validation for a fee-plan draft, extracted out of the dialog's
/// State so it's unit-testable without pumping a widget tree / registering
/// GetIt fakes. Mirrors exactly what the Publish button in
/// [FeePlanEditorDialog] checks before dispatching
/// `FeePlanPublishRequested`. Returns a user-facing error string, or null
/// when the draft is valid.
///
/// [hasOverlap] is the result of the dialog's own
/// `findPublishedPlansForSelector` pre-check (a client-side UX nicety on
/// top of the server's own uniqueness guarantee in `findMatchingFeePlan` -
/// see `functions/student_fee_billing.js`).
String? validateFeePlanDraft({
  required String name,
  required String? academicYearId,
  required String? termId,
  required String? classId,
  required List<String> lineNames,
  required List<String> lineAmountTexts,
  required bool hasOverlap,
}) {
  if (name.trim().isEmpty) return 'Enter a plan name.';
  if (academicYearId == null) return 'Select an academic year.';
  if (termId == null) return 'Select a term.';
  if (classId == null) return 'Select a class.';
  if (lineNames.isEmpty) return 'Add at least one fee line.';
  for (var i = 0; i < lineNames.length; i++) {
    final name = lineNames[i];
    final amountText = i < lineAmountTexts.length ? lineAmountTexts[i] : '';
    if (name.trim().isEmpty) return 'Every fee line needs a name.';
    final trimmed = amountText.trim();
    if (trimmed.isEmpty) return 'Every fee line needs an amount.';
    // int.tryParse (never double.tryParse) is the money-integrity gate:
    // "12000.50" parses as a double but not as an int, so it's rejected
    // outright here rather than silently truncated/rounded.
    if (double.tryParse(trimmed) != null && int.tryParse(trimmed) == null) {
      return '$name amount must be a whole number of UGX (no decimals).';
    }
    final amount = int.tryParse(trimmed);
    if (amount == null || amount < 0) {
      return '$name amount must be a non-negative whole number.';
    }
  }
  if (hasOverlap) {
    return 'A published fee plan already exists for this exact class, '
        'term and category. Archive it first or edit that plan instead.';
  }
  return null;
}

/// Composes and publishes a fee plan. Money is strictly integer UGX - line
/// amounts are parsed with `int.tryParse`, never `double.tryParse`, and
/// non-integer input is rejected outright rather than rounded.
///
/// When [existingPlan] is a published plan, submitting always calls
/// `publishFeePlan` with `createNewVersion: true` and the same planId - this
/// dialog never mutates a published version's lines directly.
class FeePlanEditorDialog extends StatefulWidget {
  final String schoolId;
  final FeePlan? existingPlan;

  const FeePlanEditorDialog({
    super.key,
    required this.schoolId,
    this.existingPlan,
  });

  @override
  State<FeePlanEditorDialog> createState() => _FeePlanEditorDialogState();
}

class _FeePlanLineDraft {
  String chargeId = '';
  String name = '';
  String amountText = '';
  bool required = true;
}

class _FeePlanEditorDialogState extends State<FeePlanEditorDialog> {
  final _nameController = TextEditingController();
  String? _academicYearId;
  String? _termId;
  String? _classId;
  String _studentCategory = 'day';
  final List<_FeePlanLineDraft> _lines = [_FeePlanLineDraft()];

  bool _checkingOverlap = false;
  List<FeePlan> _overlapping = const [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPlan;
    if (existing != null) {
      _nameController.text = existing.name;
      _academicYearId = existing.selector.academicYearId;
      _termId = existing.selector.termId;
      _classId = existing.selector.classId;
      _studentCategory = existing.selector.studentCategory;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _totalUgx => _lines.fold(
    0,
    (sum, l) => sum + (int.tryParse(l.amountText.trim()) ?? 0),
  );

  bool get _isNewVersionOfPublished =>
      widget.existingPlan != null && widget.existingPlan!.status == 'published';

  Future<void> _checkOverlap() async {
    if (_academicYearId == null || _termId == null || _classId == null) return;
    setState(() => _checkingOverlap = true);
    final overlapping = await sl<FeeBillingRepository>()
        .findPublishedPlansForSelector(
          schoolId: widget.schoolId,
          academicYearId: _academicYearId!,
          termId: _termId!,
          classId: _classId!,
          studentCategory: _studentCategory,
          excludePlanId: widget.existingPlan?.id,
        );
    if (!mounted) return;
    setState(() {
      _overlapping = overlapping;
      _checkingOverlap = false;
    });
  }

  String? _validate() => validateFeePlanDraft(
    name: _nameController.text,
    academicYearId: _academicYearId,
    termId: _termId,
    classId: _classId,
    lineNames: _lines.map((l) => l.name).toList(),
    lineAmountTexts: _lines.map((l) => l.amountText).toList(),
    hasOverlap: _overlapping.isNotEmpty,
  );

  void _submit() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final lines = _lines
        .map(
          (l) => FeePlanLine(
            chargeId: l.chargeId.isEmpty ? l.name : l.chargeId,
            name: l.name.trim(),
            amountUgx: int.parse(l.amountText.trim()),
            required: l.required,
          ),
        )
        .toList();
    context.read<FeePlanBuilderBloc>().add(
      FeePlanPublishRequested(
        schoolId: widget.schoolId,
        planId: widget.existingPlan?.id,
        academicYearId: _academicYearId!,
        termId: _termId!,
        classId: _classId!,
        studentCategory: _studentCategory,
        name: _nameController.text.trim(),
        lines: lines,
        createNewVersion: _isNewVersionOfPublished,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isNewVersionOfPublished ? 'Publish New Version' : 'New Fee Plan',
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plan name'),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<AcademicYear>>(
                stream: sl<StructureRepository>().watchAcademicYears(
                  widget.schoolId,
                ),
                builder: (context, snap) {
                  final years = snap.data ?? const <AcademicYear>[];
                  return DropdownButtonFormField<String>(
                    initialValue: _academicYearId,
                    items: years
                        .map(
                          (y) =>
                              DropdownMenuItem(value: y.id, child: Text(y.name)),
                        )
                        .toList(),
                    onChanged: widget.existingPlan != null
                        ? null
                        : (v) {
                            setState(() => _academicYearId = v);
                            _checkOverlap();
                          },
                    decoration: const InputDecoration(labelText: 'Academic year'),
                  );
                },
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<AcademicTerm>>(
                stream: sl<StructureRepository>().watchAcademicTerms(
                  widget.schoolId,
                ),
                builder: (context, snap) {
                  final terms = (snap.data ?? const <AcademicTerm>[])
                      .where((t) => t.academicYearId == _academicYearId)
                      .toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _termId,
                    items: terms
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t.id, child: Text(t.name)),
                        )
                        .toList(),
                    onChanged: widget.existingPlan != null
                        ? null
                        : (v) {
                            setState(() => _termId = v);
                            _checkOverlap();
                          },
                    decoration: const InputDecoration(labelText: 'Term'),
                  );
                },
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<SchoolClass>>(
                stream: sl<StructureRepository>().watchClasses(widget.schoolId),
                builder: (context, snap) {
                  final classes = snap.data ?? const <SchoolClass>[];
                  return DropdownButtonFormField<String>(
                    initialValue: _classId,
                    items: classes
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c.id, child: Text(c.name)),
                        )
                        .toList(),
                    onChanged: widget.existingPlan != null
                        ? null
                        : (v) {
                            setState(() => _classId = v);
                            _checkOverlap();
                          },
                    decoration: const InputDecoration(labelText: 'Class'),
                  );
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _studentCategory,
                items: const [
                  DropdownMenuItem(value: 'day', child: Text('Day')),
                  DropdownMenuItem(value: 'boarding', child: Text('Boarding')),
                ],
                onChanged: widget.existingPlan != null
                    ? null
                    : (v) {
                        setState(() => _studentCategory = v ?? 'day');
                        _checkOverlap();
                      },
                decoration: const InputDecoration(labelText: 'Student category'),
              ),
              if (_checkingOverlap)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              if (!_checkingOverlap && _overlapping.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'A published plan already exists for this exact '
                    'selection: "${_overlapping.first.name}".',
                    style: TextStyle(color: AppColors.danger(context)),
                  ),
                ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fee Lines',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(CurrencyFormatter.ugx(_totalUgx.toDouble())),
                ],
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < _lines.length; i++)
                _LineEditor(
                  key: ValueKey(i),
                  schoolId: widget.schoolId,
                  draft: _lines[i],
                  onChanged: () => setState(() {}),
                  onRemove: _lines.length > 1
                      ? () => setState(() => _lines.removeAt(i))
                      : null,
                ),
              TextButton.icon(
                onPressed: () => setState(() => _lines.add(_FeePlanLineDraft())),
                icon: const Icon(Icons.add),
                label: const Text('Add line'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isNewVersionOfPublished ? 'Publish version' : 'Publish'),
        ),
      ],
    );
  }
}

class _LineEditor extends StatefulWidget {
  final String schoolId;
  final _FeePlanLineDraft draft;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  const _LineEditor({
    super.key,
    required this.schoolId,
    required this.draft,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends State<_LineEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.name);
    _amountController = TextEditingController(text: widget.draft.amountText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: StreamBuilder<List<FeeCatalogueItem>>(
              stream: sl<FeeCatalogueRepository>().watchCatalogue(
                widget.schoolId,
              ),
              builder: (context, snap) {
                final items = snap.data ?? const <FeeCatalogueItem>[];
                return Autocomplete<FeeCatalogueItem>(
                  optionsBuilder: (textValue) {
                    if (textValue.text.isEmpty) return items;
                    return items.where(
                      (i) => i.name.toLowerCase().contains(
                        textValue.text.toLowerCase(),
                      ),
                    );
                  },
                  displayStringForOption: (i) => i.name,
                  fieldViewBuilder: (context, controller, focusNode, _) {
                    controller.text = _nameController.text;
                    controller.addListener(() {
                      _nameController.text = controller.text;
                      widget.draft.name = controller.text;
                      widget.onChanged();
                    });
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Fee name'),
                    );
                  },
                  onSelected: (item) {
                    _nameController.text = item.name;
                    widget.draft.name = item.name;
                    widget.draft.chargeId = item.id;
                    widget.onChanged();
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (UGX)'),
              onChanged: (value) {
                widget.draft.amountText = value;
                widget.onChanged();
              },
            ),
          ),
          Checkbox(
            value: widget.draft.required,
            onChanged: (v) {
              setState(() => widget.draft.required = v ?? true);
              widget.onChanged();
            },
          ),
          if (widget.onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: widget.onRemove,
            ),
        ],
      ),
    );
  }
}
