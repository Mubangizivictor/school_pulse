import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/features/hr/domain/entities/pay_component_catalogue_item.dart';
import 'package:school_pulse/features/hr/domain/entities/salary_structure.dart';
import 'package:school_pulse/features/hr/domain/repositories/pay_component_catalogue_repository.dart';
import 'package:school_pulse/features/hr/domain/repositories/salary_structure_repository.dart';
import 'package:school_pulse/features/hr/presentation/bloc/salary_structure_builder/salary_structure_builder_bloc.dart';
import 'package:school_pulse/features/hr/presentation/bloc/salary_structure_builder/salary_structure_builder_event.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

/// Pure validation for a salary-structure draft, extracted out of the
/// dialog's State so it's unit-testable, mirroring `validateFeePlanDraft`.
String? validateSalaryStructureDraft({
  required String name,
  required String? designationId,
  required List<String> lineNames,
  required List<String> lineAmountTexts,
  required bool hasOverlap,
}) {
  if (name.trim().isEmpty) return 'Enter a structure name.';
  if (designationId == null) return 'Select a staff designation.';
  if (lineNames.isEmpty) return 'Add at least one pay component.';
  for (var i = 0; i < lineNames.length; i++) {
    final name = lineNames[i];
    final amountText = i < lineAmountTexts.length ? lineAmountTexts[i] : '';
    if (name.trim().isEmpty) return 'Every pay component needs a name.';
    final trimmed = amountText.trim();
    if (trimmed.isEmpty) return 'Every pay component needs an amount.';
    if (double.tryParse(trimmed) != null && int.tryParse(trimmed) == null) {
      return '$name amount must be a whole number of UGX (no decimals).';
    }
    final amount = int.tryParse(trimmed);
    if (amount == null || amount < 0) {
      return '$name amount must be a non-negative whole number.';
    }
  }
  if (hasOverlap) {
    return 'A published salary structure already exists for this exact '
        'designation. Archive it first or edit that structure instead.';
  }
  return null;
}

/// Composes and publishes a salary structure. Money is strictly integer
/// UGX - mirrors FeePlanEditorDialog exactly, but keyed on designation.
class SalaryStructureEditorDialog extends StatefulWidget {
  final String schoolId;
  final SalaryStructure? existingStructure;

  const SalaryStructureEditorDialog({
    super.key,
    required this.schoolId,
    this.existingStructure,
  });

  @override
  State<SalaryStructureEditorDialog> createState() =>
      _SalaryStructureEditorDialogState();
}

class _SalaryStructureLineDraft {
  String componentId = '';
  String name = '';
  String amountText = '';
  bool required = true;
}

class _SalaryStructureEditorDialogState
    extends State<SalaryStructureEditorDialog> {
  final _nameController = TextEditingController();
  String? _designationId;
  final List<_SalaryStructureLineDraft> _lines = [_SalaryStructureLineDraft()];

  bool _checkingOverlap = false;
  List<SalaryStructure> _overlapping = const [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingStructure;
    if (existing != null) {
      _nameController.text = existing.name;
      _designationId = existing.selector.designationId;
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
      widget.existingStructure != null &&
      widget.existingStructure!.status == 'published';

  Future<void> _checkOverlap() async {
    if (_designationId == null) return;
    setState(() => _checkingOverlap = true);
    final overlapping = await sl<SalaryStructureRepository>()
        .findPublishedStructuresForSelector(
          schoolId: widget.schoolId,
          designationId: _designationId!,
          excludeStructureId: widget.existingStructure?.id,
        );
    if (!mounted) return;
    setState(() {
      _overlapping = overlapping;
      _checkingOverlap = false;
    });
  }

  String? _validate() => validateSalaryStructureDraft(
    name: _nameController.text,
    designationId: _designationId,
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
          (l) => SalaryStructureLine(
            componentId: l.componentId.isEmpty ? l.name : l.componentId,
            name: l.name.trim(),
            amountUgx: int.parse(l.amountText.trim()),
            required: l.required,
          ),
        )
        .toList();
    context.read<SalaryStructureBuilderBloc>().add(
      SalaryStructurePublishRequested(
        schoolId: widget.schoolId,
        structureId: widget.existingStructure?.id,
        designationId: _designationId!,
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
        _isNewVersionOfPublished
            ? 'Publish New Version'
            : 'New Salary Structure',
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
                decoration: const InputDecoration(labelText: 'Structure name'),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<StaffDesignation>>(
                stream: sl<StructureRepository>().watchDesignations(
                  widget.schoolId,
                ),
                builder: (context, snap) {
                  final designations = snap.data ?? const <StaffDesignation>[];
                  return DropdownButtonFormField<String>(
                    initialValue: _designationId,
                    items: designations
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: widget.existingStructure != null
                        ? null
                        : (v) {
                            setState(() => _designationId = v);
                            _checkOverlap();
                          },
                    decoration: const InputDecoration(labelText: 'Designation'),
                  );
                },
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
                    'A published structure already exists for this exact '
                    'designation: "${_overlapping.first.name}".',
                    style: TextStyle(color: AppColors.danger(context)),
                  ),
                ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pay Components',
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
                onPressed: () =>
                    setState(() => _lines.add(_SalaryStructureLineDraft())),
                icon: const Icon(Icons.add),
                label: const Text('Add component'),
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
  final _SalaryStructureLineDraft draft;
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
            child: StreamBuilder<List<PayComponentCatalogueItem>>(
              stream: sl<PayComponentCatalogueRepository>().watchCatalogue(
                widget.schoolId,
              ),
              builder: (context, snap) {
                final items = snap.data ?? const <PayComponentCatalogueItem>[];
                return Autocomplete<PayComponentCatalogueItem>(
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
                      decoration: const InputDecoration(
                        labelText: 'Component name',
                      ),
                    );
                  },
                  onSelected: (item) {
                    _nameController.text = item.name;
                    widget.draft.name = item.name;
                    widget.draft.componentId = item.id;
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
          Tooltip(
            message: widget.draft.required
                ? 'Required: always paid'
                : 'Optional: chosen per staff member at onboarding '
                      '(e.g. responsibility allowance)',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: widget.draft.required,
                  onChanged: (v) {
                    setState(() => widget.draft.required = v ?? true);
                    widget.onChanged();
                  },
                ),
                Text('Required', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
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
