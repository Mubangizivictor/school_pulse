import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/hr/domain/entities/salary_structure.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../add_staff_wizard_controller.dart';

const _employmentTypes = ['Permanent', 'Contract', 'Part-Time', 'Volunteer'];

/// Stage 2 - Work: "Where will they work?" Combines Employment Information
/// and Pay Structure (previously separate steps) into one stage, matching
/// the reference design.
class Stage02Work extends StatefulWidget {
  final VoidCallback onSaveDraft;

  const Stage02Work({super.key, required this.onSaveDraft});

  @override
  State<Stage02Work> createState() => _Stage02WorkState();
}

class _Stage02WorkState extends State<Stage02Work> {
  final _formKey = GlobalKey<FormState>();
  late final StructureRepository _structureRepository;

  bool _payEnabled = true;
  Future<MatchedSalaryStructure?>? _matchFuture;
  String? _matchedForDesignationId;

  @override
  void initState() {
    super.initState();
    _structureRepository = di.sl<StructureRepository>();
  }

  void _lookupMatch(AddStaffWizardController controller) {
    // Work details no longer collect a role, so pay is deliberately set up
    // later in HR rather than being matched from an onboarding selection.
    if (_matchedForDesignationId == '') return;
    _matchedForDesignationId = '';
    _matchFuture = Future.value(null);
  }

  int _billedTotalUgx(
    MatchedSalaryStructure match,
    Set<String> selectedComponentIds,
  ) => match.lines
      .where((l) => l.required || selectedComponentIds.contains(l.componentId))
      .fold(0, (sum, l) => sum + l.amountUgx);

  Future<void> _pickDate(AddStaffWizardController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.draft.dateJoined,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.draft.dateJoined = picked;
      controller.notifyDraftChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;
    final schoolId = controller.schoolId;
    _lookupMatch(controller);

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.work),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue',
        onBack: () => controller.back(),
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardStageHeading(
              title: 'Where will they work?',
              subtitle: 'Add their employment details and start date.',
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<Campus>>(
              stream: _structureRepository.watchCampuses(schoolId),
              builder: (context, snapshot) {
                final campuses =
                    (snapshot.data ?? const [])
                        .where((c) => c.isActive)
                        .toList()
                      ..sort((a, b) => a.order.compareTo(b.order));
                if (campuses.isEmpty) return const SizedBox.shrink();
                if (campuses.length == 1) {
                  if (draft.campusId != campuses.first.id) {
                    draft.campusId = campuses.first.id;
                  }
                  return _CampusRow(
                    campusName: campuses.first.name,
                    editable: false,
                  );
                }
                return _CampusRow(
                  campusName: campuses
                      .where((c) => c.id == draft.campusId)
                      .map((c) => c.name)
                      .firstOrNullExt(),
                  editable: true,
                  onChange: () async {
                    final picked = await showModalBottomSheet<String>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: campuses
                              .map(
                                (c) => ListTile(
                                  title: Text(c.name),
                                  trailing: draft.campusId == c.id
                                      ? const Icon(Icons.check)
                                      : null,
                                  onTap: () => Navigator.pop(ctx, c.id),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                    if (picked != null) {
                      draft.campusId = picked;
                      controller.notifyDraftChanged();
                    }
                  },
                );
              },
            ),
            _labeledField(
              'Employment type',
              DropdownButtonFormField<String>(
                initialValue: draft.employmentType,
                decoration: const InputDecoration(
                  hintText: 'Select employment type',
                ),
                items: _employmentTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    draft.employmentType = v;
                    controller.notifyDraftChanged();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            _labeledField(
              'Date joined',
              InkWell(
                onTap: () => _pickDate(controller),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Select date joined',
                  ),
                  child: Text(
                    '${draft.dateJoined.day}/${draft.dateJoined.month}/${draft.dateJoined.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Staff code generated automatically',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),
            const WizardSectionLabel(
              label: 'Pay structure',
              helper: "Choose how you want to handle this staff member's pay.",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PayChoiceCard(
                    title: 'Set up pay now',
                    subtitle: 'Enter pay structure details',
                    selected: _payEnabled,
                    onTap: () => setState(() => _payEnabled = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PayChoiceCard(
                    title: 'Skip for now',
                    subtitle: 'Add pay details later',
                    selected: !_payEnabled,
                    onTap: () => setState(() => _payEnabled = false),
                  ),
                ),
              ],
            ),
            if (_payEnabled) ...[
              const SizedBox(height: 16),
              FutureBuilder<MatchedSalaryStructure?>(
                future: _matchFuture,
                builder: (context, snapshot) {
                  final loading =
                      snapshot.connectionState != ConnectionState.done;
                  if (loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: SchoolPulseLoader()),
                    );
                  }
                  final match = snapshot.data;
                  if (match == null) {
                    return _pendingCard(context);
                  }
                  return _matchedCard(context, controller, match);
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.textMuted(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pay details are only visible to authorised HR and admin users.',
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _labeledField(String label, Widget field, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Builder(
              builder: (context) => RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  children: required
                      ? [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.danger(context)),
                          ),
                        ]
                      : const [],
                ),
              ),
            ),
          ),
          field,
        ],
      ),
    );
  }

  Widget _pendingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_top_outlined,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pay setup pending',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Continue to add this staff member, then set up their pay in HR '
            'when you are ready.',
            style: TextStyle(color: AppColors.textMuted(context)),
          ),
        ],
      ),
    );
  }

  Widget _matchedCard(
    BuildContext context,
    AddStaffWizardController controller,
    MatchedSalaryStructure match,
  ) {
    final draft = controller.draft;
    final requiredLines = match.lines.where((l) => l.required);
    final optionalLines = match.lines.where((l) => !l.required);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  match.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pay summary',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                'Monthly (UGX)',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          for (final line in requiredLines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(line.name)),
                  Text(CurrencyFormatter.ugx(line.amountUgx.toDouble())),
                ],
              ),
            ),
          if (optionalLines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Allowances',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 4),
            for (final line in optionalLines)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: draft.selectedPayComponentIds.contains(line.componentId),
                title: Text(line.name),
                subtitle: Text(
                  CurrencyFormatter.ugx(line.amountUgx.toDouble()),
                ),
                onChanged: (checked) {
                  if (checked ?? false) {
                    draft.selectedPayComponentIds.add(line.componentId);
                  } else {
                    draft.selectedPayComponentIds.remove(line.componentId);
                  }
                  controller.notifyDraftChanged();
                },
              ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total monthly pay',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                CurrencyFormatter.ugx(
                  _billedTotalUgx(
                    match,
                    draft.selectedPayComponentIds,
                  ).toDouble(),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampusRow extends StatelessWidget {
  final String? campusName;
  final bool editable;
  final VoidCallback? onChange;

  const _CampusRow({
    required this.campusName,
    required this.editable,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campus',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                campusName ?? 'Select campus',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              if (editable)
                TextButton.icon(
                  onPressed: onChange,
                  icon: const Icon(Icons.unfold_more, size: 16),
                  label: const Text('Change'),
                ),
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}

class _PayChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PayChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? AppColors.textPrimary(context)
                : AppColors.border(context),
            width: selected ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected
                  ? AppColors.textPrimary(context)
                  : AppColors.textMuted(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? firstOrNullExt() => isEmpty ? null : first;
}
