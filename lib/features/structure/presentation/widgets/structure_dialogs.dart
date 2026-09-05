import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/structure_entities.dart';

const List<Color> kSubjectColorSwatches = [
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
  Color(0xFF00897B),
  Color(0xFF3949AB),
  Color(0xFF6D4C41),
];

String _colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2)}';

/// Add-or-edit bottom sheet for a custom [EducationalLevel]. `existingLevels`
/// must be the full current list (in teaching order) so name/code
/// uniqueness can be checked and "position in school order" can be offered.
Future<void> showLevelFormDialog(
  BuildContext context, {
  EducationalLevel? existing,
  required String schoolId,
  required List<EducationalLevel> existingLevels,
  required void Function(List<EducationalLevel> toSave) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final others = existingLevels
      .where((level) => level.id != existing?.id)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  String placement = 'after';
  String? relativeToId = others.isNotEmpty ? others.last.id : null;

  String? validateName(String? v) {
    final name = v?.trim() ?? '';
    if (name.isEmpty) return 'Enter a level name.';
    if (others.any((l) => l.name.trim().toLowerCase() == name.toLowerCase())) {
      return 'A level with this name already exists.';
    }
    return null;
  }

  String? validateCode(String? v) {
    final code = v?.trim() ?? '';
    if (code.isEmpty) return null;
    if (others.any(
      (l) => l.code.trim().toLowerCase() == code.toLowerCase(),
    )) {
      return 'This short code is already in use.';
    }
    return null;
  }

  int resolveOrder() {
    if (others.isEmpty) return 0;
    others.sort((a, b) => a.order.compareTo(b.order));
    final index = others.indexWhere((l) => l.id == relativeToId);
    final anchor = index == -1 ? others.length - 1 : index;
    final insertAt = placement == 'before' ? anchor : anchor + 1;
    return insertAt;
  }

  List<EducationalLevel> resequence(EducationalLevel inserted) {
    final all = [...others];
    final insertIndex = resolveOrder().clamp(0, all.length);
    all.insert(insertIndex, inserted);
    return [
      for (var i = 0; i < all.length; i++) all[i].copyWith(order: i),
    ];
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        existing != null
                            ? 'Edit level'
                            : 'Add custom level',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Use this only if your school offers a level not listed above.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Level name',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'e.g., Sixth Form'),
                  validator: validateName,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Short code (optional)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(hintText: 'e.g., SF'),
                  validator: validateCode,
                ),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Position in school order',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose where this level should appear.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<String>(
                          initialValue: placement,
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(
                              value: 'before',
                              child: Text('Before'),
                            ),
                            DropdownMenuItem(
                              value: 'after',
                              child: Text('After'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => placement = v ?? 'after'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: relativeToId,
                          isExpanded: true,
                          decoration: const InputDecoration(),
                          items: [
                            for (final level in others)
                              DropdownMenuItem(
                                value: level.id,
                                child: Text(
                                  level.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(() => relativeToId = v),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final base = EducationalLevel(
                        id: existing?.id ?? const Uuid().v4(),
                        schoolId: schoolId,
                        name: nameController.text.trim(),
                        code: codeController.text.trim(),
                        isActive: true,
                      );
                      final ordered = resequence(base);
                      final changed = [
                        for (final level in ordered)
                          if (level.id == base.id ||
                              level.order !=
                                  others
                                      .firstWhere((l) => l.id == level.id)
                                      .order)
                            level,
                      ];
                      onSave(changed);
                      Navigator.pop(context);
                    },
                    child: Text(existing != null ? 'Save changes' : 'Add level'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showAcademicYearFormDialog(
  BuildContext context, {
  AcademicYear? existing,
  required String schoolId,
  required void Function(AcademicYear) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  DateTime? startDate = existing?.startDate;
  DateTime? endDate = existing?.endDate;
  bool isCurrent = existing?.isCurrent ?? true;
  bool showDateOrderError = false;
  bool showDateRequiredError = false;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        final dateFormat = DateFormat('dd MMM yyyy');

        Future<void> pickDate({required bool isStart}) async {
          final picked = await showDatePicker(
            context: context,
            initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked == null) return;
          setState(() {
            if (isStart) {
              startDate = picked;
            } else {
              endDate = picked;
            }
            showDateRequiredError = false;
            showDateOrderError =
                startDate != null &&
                endDate != null &&
                !startDate!.isBefore(endDate!);
          });
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Material(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.outlineVariant,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  existing == null
                                      ? 'Add academic year'
                                      : 'Edit academic year',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Set the dates for one school calendar year.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Year name',
                          hintText: 'e.g. 2026',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AcademicYearDateField(
                              label: 'Start date',
                              value: startDate == null
                                  ? 'Select start date'
                                  : dateFormat.format(startDate!),
                              isPlaceholder: startDate == null,
                              onTap: () => pickDate(isStart: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AcademicYearDateField(
                              label: 'End date',
                              value: endDate == null
                                  ? 'Select end date'
                                  : dateFormat.format(endDate!),
                              isPlaceholder: endDate == null,
                              onTap: () => pickDate(isStart: false),
                            ),
                          ),
                        ],
                      ),
                      if (showDateRequiredError || showDateOrderError) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: scheme.outlineVariant,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  showDateRequiredError
                                      ? 'Select a start and end date.'
                                      : 'End date must be after start date.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => isCurrent = !isCurrent),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Switch(
                                value: isCurrent,
                                onChanged: (value) =>
                                    setState(() => isCurrent = value),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Set as current academic year'),
                                    const SizedBox(height: 2),
                                    Text(
                                      'This will be used for new enrolments and terms.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            if (startDate == null || endDate == null) {
                              setState(() => showDateRequiredError = true);
                              return;
                            }
                            if (!startDate!.isBefore(endDate!)) {
                              setState(() => showDateOrderError = true);
                              return;
                            }
                            onSave(
                              AcademicYear(
                                id: existing?.id ?? const Uuid().v4(),
                                schoolId: existing?.schoolId ?? schoolId,
                                name: nameController.text.trim(),
                                startDate: startDate!,
                                endDate: endDate!,
                                isCurrent: isCurrent,
                                isArchived: existing?.isArchived ?? false,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            existing == null
                                ? 'Save academic year'
                                : 'Save changes',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class AcademicYearDateField extends StatelessWidget {
  const AcademicYearDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isPlaceholder ? scheme.onSurfaceVariant : null,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAcademicTermFormDialog(
  BuildContext context, {
  AcademicTerm? existing,
  required List<AcademicYear> years,
  required String schoolId,
  required void Function(AcademicTerm) onSave,
  AcademicPeriodType? fixedPeriodType,
  int existingCount = 0,
}) {
  final formKey = GlobalKey<FormState>();
  final year = years.first;
  final periodType =
      existing?.periodType ?? fixedPeriodType ?? AcademicPeriodType.term;
  final periodWord = periodType == AcademicPeriodType.semester
      ? 'Semester'
      : 'Term';
  // The sequence number in the title/button ("Add Term 2") reflects how
  // many non-archived periods already exist for this year - it does not
  // persist as data, purely a label matching the reference's numbering.
  final sequence = existing == null ? existingCount + 1 : existing.order;
  final nameController = TextEditingController(
    text: existing?.name ?? '$periodWord $sequence',
  );
  DateTime? startDate = existing?.startDate;
  DateTime? endDate = existing?.endDate;
  bool isCurrent = existing?.isCurrent ?? false;
  bool showDateRequiredError = false;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Material(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.outlineVariant,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                existing == null
                                    ? 'Add $periodWord $sequence'
                                    : 'Edit $periodWord',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${periodWord}s • Academic year ${year.name}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: '$periodWord name',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AcademicYearDateField(
                                label: 'Start date',
                                value: startDate == null
                                    ? 'Select start date'
                                    : DateFormat(
                                        'dd MMM yyyy',
                                      ).format(startDate!),
                                isPlaceholder: startDate == null,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: startDate ?? year.startDate,
                                    firstDate: year.startDate,
                                    lastDate: year.endDate,
                                  );
                                  if (picked == null) return;
                                  setState(() {
                                    startDate = picked;
                                    showDateRequiredError = false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AcademicYearDateField(
                                label: 'End date',
                                value: endDate == null
                                    ? 'Select end date'
                                    : DateFormat(
                                        'dd MMM yyyy',
                                      ).format(endDate!),
                                isPlaceholder: endDate == null,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: endDate ?? year.endDate,
                                    firstDate: year.startDate,
                                    lastDate: year.endDate,
                                  );
                                  if (picked == null) return;
                                  setState(() {
                                    endDate = picked;
                                    showDateRequiredError = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  showDateRequiredError
                                      ? 'Select a start and end date.'
                                      : 'Dates must fall within ${year.name} and cannot overlap.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => isCurrent = !isCurrent),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: scheme.outlineVariant),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Switch(
                                  value: isCurrent,
                                  onChanged: (value) =>
                                      setState(() => isCurrent = value),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Set as current ${periodWord.toLowerCase()} (optional)',
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Mark this ${periodWord.toLowerCase()} as the current one for reporting and timetables.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              if (startDate == null || endDate == null) {
                                setState(() => showDateRequiredError = true);
                                return;
                              }
                              onSave(
                                AcademicTerm(
                                  id: existing?.id ?? const Uuid().v4(),
                                  schoolId: existing?.schoolId ?? schoolId,
                                  academicYearId: year.id,
                                  name: nameController.text.trim(),
                                  order: existing?.order ?? sequence,
                                  startDate: startDate!,
                                  endDate: endDate!,
                                  isCurrent: isCurrent,
                                  periodType: periodType,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              existing == null
                                  ? 'Save $periodWord $sequence'
                                  : 'Save changes',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showClassFormDialog(
  BuildContext context, {
  SchoolClass? existing,
  required List<EducationalLevel> levels,
  required String schoolId,
  required void Function(SchoolClass) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final capacityController = TextEditingController(
    text: existing?.capacity.toString() ?? '0',
  );
  final descController = TextEditingController(text: existing?.description);
  String? selectedLevelId = existing?.levelId.isNotEmpty == true
      ? existing!.levelId
      : (levels.isNotEmpty ? levels.first.id : null);
  bool isActive = existing?.isActive ?? true;

  if (existing != null) {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Class'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Class Name (e.g. P1, S1, Grade 12)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code (optional)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLevelId,
                    decoration: const InputDecoration(
                      labelText: 'Educational Level',
                    ),
                    items: levels
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedLevelId = v),
                    validator: (v) => v == null ? 'Select a level' : null,
                  ),
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 2,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
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
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                onSave(
                  SchoolClass(
                    id: existing.id,
                    schoolId: existing.schoolId,
                    name: nameController.text,
                    code: codeController.text,
                    levelId: selectedLevelId ?? '',
                    capacity: int.tryParse(capacityController.text) ?? 0,
                    description: descController.text,
                    isActive: isActive,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add class',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create a class under an education level.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Class name',
                      hintText: 'e.g. P1, S1, Grade 12',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLevelId,
                    decoration: const InputDecoration(
                      labelText: 'Education level',
                    ),
                    items: levels
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedLevelId = v),
                    validator: (v) => v == null ? 'Select a level' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      suffixText: '(optional)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Teachers are assigned later.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        onSave(
                          SchoolClass(
                            id: const Uuid().v4(),
                            schoolId: schoolId,
                            name: nameController.text.trim(),
                            code: '',
                            levelId: selectedLevelId ?? '',
                            capacity:
                                int.tryParse(capacityController.text) ?? 0,
                            description: '',
                            isActive: true,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Add class'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showStreamFormDialog(
  BuildContext context, {
  ClassStream? existing,
  required List<SchoolClass> classes,
  required List<ClassStream> streams,
  required String schoolId,
  required void Function(ClassStream) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final capacityController = TextEditingController(
    text: existing?.capacity.toString() ?? '0',
  );
  String? selectedClassId =
      existing?.classId ?? (classes.isNotEmpty ? classes.first.id : null);
  bool isActive = existing?.isActive ?? true;

  if (existing != null) {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Stream / Section'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Stream Name (e.g. East, A, Blue)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code (optional)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedClassId,
                    decoration: const InputDecoration(labelText: 'Class'),
                    items: classes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedClassId = v),
                    validator: (v) => v == null ? 'Select a class' : null,
                  ),
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
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
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                onSave(
                  ClassStream(
                    id: existing.id,
                    schoolId: existing.schoolId,
                    name: nameController.text,
                    code: codeController.text,
                    classId: selectedClassId ?? '',
                    capacity: int.tryParse(capacityController.text) ?? 0,
                    isActive: isActive,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        final parent = classes
            .where((c) => c.id == selectedClassId)
            .firstOrNull;
        final allocated = parent == null
            ? 0
            : streams
                  .where((s) => s.classId == parent.id && s.isActive)
                  .fold<int>(0, (sum, s) => sum + s.capacity);
        final capacity = int.tryParse(capacityController.text) ?? 0;
        final projected = allocated + capacity;
        final classCapacity = parent?.capacity ?? 0;
        final remaining = (classCapacity - projected).clamp(0, classCapacity);
        final progress = classCapacity > 0
            ? (projected / classCapacity).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add stream',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          shape: const CircleBorder(),
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Divide a class into a smaller group.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: selectedClassId,
                    decoration: const InputDecoration(labelText: 'Class'),
                    items: classes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.name} · Capacity ${c.capacity}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedClassId = v),
                    validator: (v) => v == null ? 'Select a class' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Stream name',
                      hintText: 'e.g. East, A, Blue',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      suffixText: '(optional)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  if (parent != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$projected of $classCapacity allocated',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: scheme.surfaceContainerHigh,
                              color: progress > 1.0
                                  ? scheme.error
                                  : scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$remaining places remaining in ${parent.name}.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        onSave(
                          ClassStream(
                            id: const Uuid().v4(),
                            schoolId: schoolId,
                            name: nameController.text.trim(),
                            code: '',
                            classId: selectedClassId ?? '',
                            capacity: capacity,
                            isActive: true,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Add stream'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showSubjectFormDialog(
  BuildContext context, {
  Subject? existing,
  required List<Department> departments,
  required String schoolId,
  required void Function(Subject) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final creditController = TextEditingController(
    text: existing?.creditUnits.toString() ?? '0',
  );
  final descController = TextEditingController(text: existing?.description);
  String? selectedDepartmentId = existing?.departmentId.isNotEmpty == true
      ? existing!.departmentId
      : (departments.isNotEmpty ? departments.first.id : null);
  Color selectedColor = existing?.color.isNotEmpty == true
      ? Color(int.parse(existing!.color.replaceFirst('#', '0xff')))
      : kSubjectColorSwatches.first;
  bool isElective = existing?.isElective ?? false;
  bool isPractical = existing?.isPractical ?? false;
  bool isActive = existing?.isActive ?? true;

  if (existing != null) {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Subject'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Subject Name',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code (optional)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDepartmentId,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: departments
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedDepartmentId = v),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: kSubjectColorSwatches.map((c) {
                      final selected = c.toARGB32() == selectedColor.toARGB32();
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = c),
                        child: CircleAvatar(
                          backgroundColor: c,
                          radius: 14,
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: creditController,
                    decoration: const InputDecoration(
                      labelText: 'Credit Units (optional)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 2,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Elective'),
                    value: isElective,
                    onChanged: (v) => setState(() => isElective = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Practical'),
                    value: isPractical,
                    onChanged: (v) => setState(() => isPractical = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
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
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                onSave(
                  Subject(
                    id: existing.id,
                    schoolId: existing.schoolId,
                    name: nameController.text,
                    code: codeController.text,
                    departmentId: selectedDepartmentId ?? '',
                    color: _colorToHex(selectedColor),
                    description: descController.text,
                    isElective: isElective,
                    isPractical: isPractical,
                    creditUnits: int.tryParse(creditController.text) ?? 0,
                    isActive: isActive,
                    assignedLevelIds: existing.assignedLevelIds,
                    assignedClassIds: existing.assignedClassIds,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add subject',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add a subject to your school catalogue.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Subject name',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: codeController,
                          decoration: const InputDecoration(
                            labelText: 'Short code (optional)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedDepartmentId,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                          ),
                          items: departments
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(d.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedDepartmentId = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Elective'),
                          value: isElective,
                          onChanged: (v) => setState(() => isElective = v),
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Practical'),
                          value: isPractical,
                          onChanged: (v) => setState(() => isPractical = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'More subject settings can be added later.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        onSave(
                          Subject(
                            id: const Uuid().v4(),
                            schoolId: schoolId,
                            name: nameController.text.trim(),
                            code: codeController.text.trim(),
                            departmentId: selectedDepartmentId ?? '',
                            color: _colorToHex(selectedColor),
                            description: '',
                            isElective: isElective,
                            isPractical: isPractical,
                            creditUnits: 0,
                            isActive: true,
                            assignedLevelIds: const [],
                            assignedClassIds: const [],
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Add subject'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showDepartmentFormDialog(
  BuildContext context, {
  Department? existing,
  required String schoolId,
  required void Function(Department) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  if (existing != null) {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Department'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Department Name',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code (optional)',
                    ),
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 2,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
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
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                onSave(
                  Department(
                    id: existing.id,
                    schoolId: existing.schoolId,
                    name: nameController.text,
                    code: codeController.text,
                    description: descController.text,
                    headOfDepartmentStaffId: existing.headOfDepartmentStaffId,
                    isActive: isActive,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add department',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Create a department for related staff and subjects.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Department name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code (optional)'),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Short description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    onSave(
                      Department(
                        id: const Uuid().v4(),
                        schoolId: schoolId,
                        name: nameController.text.trim(),
                        code: codeController.text.trim(),
                        description: descController.text.trim(),
                        headOfDepartmentStaffId: '',
                        isActive: true,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Add department'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showDesignationFormDialog(
  BuildContext context, {
  StaffDesignation? existing,
  required String schoolId,
  required void Function(StaffDesignation) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          existing == null ? 'Add Staff Designation' : 'Edit Staff Designation',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Designation (e.g. Principal, Bursar)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ),
                if (existing != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
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
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                StaffDesignation(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  description: descController.text,
                  isActive: isActive,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? impactMessage,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (impactMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              impactMessage,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );
}
