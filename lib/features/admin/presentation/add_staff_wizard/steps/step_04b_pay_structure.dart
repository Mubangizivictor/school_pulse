import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/features/hr/domain/entities/salary_structure.dart';
import 'package:school_pulse/features/hr/domain/repositories/salary_structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../add_staff_wizard_controller.dart';

/// Pay Structure step, inserted right after Employment Information since the
/// matched salary structure is keyed on the designationId set there. Mirrors
/// the enrollment wizard's Finance step: a read-only matched-structure
/// snapshot with checkboxes for optional pay components, never a
/// client-typed amount.
class Step04bPayStructure extends StatefulWidget {
  const Step04bPayStructure({super.key});

  @override
  State<Step04bPayStructure> createState() => _Step04bPayStructureState();
}

class _Step04bPayStructureState extends State<Step04bPayStructure> {
  Future<MatchedSalaryStructure?>? _matchFuture;
  String? _matchedForDesignationId;

  void _lookupMatch(AddStaffWizardController controller) {
    final designationId = controller.draft.designationId;
    if (_matchedForDesignationId == designationId) return;
    _matchedForDesignationId = designationId;
    if (designationId == null || designationId.isEmpty) {
      _matchFuture = Future.value(null);
      return;
    }
    _matchFuture = di.sl<SalaryStructureRepository>()
        .findMatchingSalaryStructure(
          schoolId: controller.schoolId,
          designationId: designationId,
        )
        .then((result) => result.fold((_) => null, (m) => m));
  }

  int _billedTotalUgx(
    MatchedSalaryStructure match,
    Set<String> selectedComponentIds,
  ) => match.lines
      .where((l) => l.required || selectedComponentIds.contains(l.componentId))
      .fold(0, (sum, l) => sum + l.amountUgx);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    _lookupMatch(controller);

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.payStructure),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStepCaption(
            number: 3,
            title: 'Pay Structure',
            subtitle: "Set up this staff member's pay.",
          ),
          const SizedBox(height: 20),
          FutureBuilder<MatchedSalaryStructure?>(
            future: _matchFuture,
            builder: (context, snapshot) {
              final loading = snapshot.connectionState != ConnectionState.done;
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
        ],
      ),
    );
  }

  Widget _pendingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hourglass_top_outlined,
                  color: Theme.of(context).colorScheme.error,
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
            const Text(
              'No published salary structure matches this designation yet. '
              'You can continue adding this staff member - pay setup will '
              'stay pending until a salary structure is published in '
              'Structure > People > Salary Structures.',
            ),
          ],
        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final line in requiredLines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(line.name)),
                    Text(CurrencyFormatter.ugx(line.amountUgx.toDouble())),
                  ],
                ),
              ),
            if (optionalLines.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Optional components',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final line in optionalLines)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  value: draft.selectedPayComponentIds.contains(
                    line.componentId,
                  ),
                  title: Text(line.name),
                  subtitle: Text(CurrencyFormatter.ugx(line.amountUgx.toDouble())),
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
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total monthly pay',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  CurrencyFormatter.ugx(
                    _billedTotalUgx(
                      match,
                      draft.selectedPayComponentIds,
                    ).toDouble(),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
