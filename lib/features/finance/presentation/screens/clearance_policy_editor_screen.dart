import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/injection_container.dart';

import '../bloc/clearance_policy/clearance_policy_bloc.dart';

/// School Settings › Financial Clearance Policy.
///
/// Role-protected (bursar / schoolAdmin / headTeacher / director). Every save
/// goes through `saveReportCardClearancePolicy`, which audits the change with
/// an effective timestamp and re-materialises every finalized report's
/// access state. Historical exception snapshots are never touched.
class ClearancePolicyEditorScreen extends StatelessWidget {
  const ClearancePolicyEditorScreen({super.key});

  static const _allowedRoles = {
    'bursar',
    'schoolAdmin',
    'headTeacher',
    'director',
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final roles = auth is AuthAuthenticated
        ? auth.user.roles.map((r) => r.name).toSet()
        : <String>{};
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';

    if (roles.intersection(_allowedRoles).isEmpty) {
      return FinanceScaffold(
        title: 'Financial Clearance Policy',
        body: FinanceStates.empty(
          context,
          icon: Icons.lock_outline,
          title: 'Not available',
          message:
              'Only the Bursar, School Admin, Headteacher or Director can '
              'change the report-card financial-clearance policy.',
        ),
      );
    }

    return BlocProvider(
      create: (_) =>
          sl<ClearancePolicyBloc>()..add(ClearancePolicyLoaded(schoolId)),
      child: const _Editor(),
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClearancePolicyBloc, ClearancePolicyState>(
      listenWhen: (a, b) =>
          a.successMessage != b.successMessage ||
          a.errorMessage != b.errorMessage,
      listener: (context, state) {
        final msg = state.successMessage ?? state.errorMessage;
        if (msg == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: state.errorMessage != null
                  ? AppColors.danger(context)
                  : null,
            ),
          );
        context.read<ClearancePolicyBloc>().add(
          const ClearancePolicyFeedbackCleared(),
        );
      },
      builder: (context, state) {
        final bloc = context.read<ClearancePolicyBloc>();
        final d = state.draft;

        return FinanceScaffold(
          title: 'Financial Clearance Policy',
          bottomBar:
              state.status == ClearancePolicyStatus.ready ||
                  state.status == ClearancePolicyStatus.saving
              ? PrimaryActionBar(
                  label: 'Save policy',
                  loading: state.status == ClearancePolicyStatus.saving,
                  onPressed: state.isDirty
                      ? () => bloc.add(const ClearancePolicySaved())
                      : null,
                )
              : null,
          body: switch (state.status) {
            ClearancePolicyStatus.loading => FinanceStates.loading(),
            ClearancePolicyStatus.error => FinanceStates.error(
              context,
              state.errorMessage ?? 'Could not load the policy.',
            ),
            _ => ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                if (state.meta.effectiveFrom != null)
                  _EffectiveSince(meta: state.meta),
                const SizedBox(height: AppSpacing.m),
                _ModeSelector(
                  value: d.mode,
                  onChanged: (m) => bloc.add(
                    ClearancePolicyDraftChanged(d.copyWith(mode: m)),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                if (d.mode == ClearanceMode.fullBalance)
                  _CompulsoryOnly(
                    value: d.compulsoryOnly,
                    onChanged: (v) => bloc.add(
                      ClearancePolicyDraftChanged(
                        d.copyWith(compulsoryOnly: v),
                      ),
                    ),
                  ),
                if (d.mode == ClearanceMode.minimumPercentage)
                  _PercentageField(
                    value: d.minimumPercentagePaid,
                    onChanged: (v) => bloc.add(
                      ClearancePolicyDraftChanged(
                        d.copyWith(minimumPercentagePaid: v),
                      ),
                    ),
                  ),
                if (d.mode == ClearanceMode.selectedCategories)
                  _CategoryPicker(
                    selected: d.feeCategoryIds,
                    catalogue: state.feeCatalogue,
                    onChanged: (ids) => bloc.add(
                      ClearancePolicyDraftChanged(
                        d.copyWith(feeCategoryIds: ids),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.l),
                _SecondApproverSection(
                  draft: d,
                  onChanged: (nd) => bloc.add(ClearancePolicyDraftChanged(nd)),
                ),
                const SizedBox(height: AppSpacing.l),
                _ExpiryDefault(
                  value: d.defaultExpiryDays,
                  onChanged: (v) => bloc.add(
                    ClearancePolicyDraftChanged(
                      d.copyWith(defaultExpiryDays: v),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                _RestrictionMessageField(
                  value: d.restrictionMessage,
                  onChanged: (v) => bloc.add(
                    ClearancePolicyDraftChanged(
                      d.copyWith(restrictionMessage: v),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                _PreviewCard(policy: d),
                const SizedBox(height: AppSpacing.l),
                _GranularityWarning(mode: d.mode),
                const SizedBox(height: AppSpacing.x3l),
              ],
            ),
          },
        );
      },
    );
  }
}

class _EffectiveSince extends StatelessWidget {
  const _EffectiveSince({required this.meta});
  final ClearancePolicyMeta meta;
  @override
  Widget build(BuildContext context) {
    final dt = meta.effectiveFrom!;
    return Text(
      'In effect since ${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}'
      '${meta.updatedByName != null ? ' · set by ${meta.updatedByName}' : ''}',
      style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.value, required this.onChanged});
  final ClearanceMode value;
  final ValueChanged<ClearanceMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'CLEARANCE RULE',
      child: RadioGroup<ClearanceMode>(
        groupValue: value,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        child: Column(
          children: ClearanceMode.values.map((m) {
            return RadioListTile<ClearanceMode>(
              contentPadding: EdgeInsets.zero,
              value: m,
              title: Text(
                m.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                m.blurb,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CompulsoryOnly extends StatelessWidget {
  const _CompulsoryOnly({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SectionCard(
    child: SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: const Text('Compulsory charges only'),
      subtitle: Text(
        'Ignore optional line items (e.g. transport, clubs) when checking the '
        'balance.',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
      ),
    ),
  );
}

class _PercentageField extends StatelessWidget {
  const _PercentageField({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'MINIMUM PERCENTAGE PAID',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: value.clamp(1, 100).toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          label: '$value%',
          onChanged: (v) => onChanged(v.round()),
        ),
        Text(
          'A learner is cleared once $value% of the term fees is paid.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
        ),
      ],
    ),
  );
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.catalogue,
    required this.onChanged,
  });
  final List<String> selected;
  final List<dynamic> catalogue; // FeeCatalogueItem
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'FEE CATEGORIES THAT MUST BE PAID',
      child: catalogue.isEmpty
          ? Text(
              'No fee catalogue items found. Add fee-catalogue items first, or '
              'switch to another clearance rule.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted(context),
              ),
            )
          : Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: catalogue.map((item) {
                final id = item.id as String;
                final name = item.name as String;
                final on = selected.contains(id);
                return FilterChip(
                  label: Text(name),
                  selected: on,
                  onSelected: (v) {
                    final next = [...selected];
                    if (v) {
                      next.add(id);
                    } else {
                      next.remove(id);
                    }
                    onChanged(next);
                  },
                );
              }).toList(),
            ),
    );
  }
}

class _SecondApproverSection extends StatelessWidget {
  const _SecondApproverSection({required this.draft, required this.onChanged});
  final FinancialClearancePolicy draft;
  final ValueChanged<FinancialClearancePolicy> onChanged;

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(
      text: draft.secondApproverArrearsThresholdUgx == 0
          ? ''
          : draft.secondApproverArrearsThresholdUgx.toString(),
    );
    return SectionCard(
      title: 'SECOND APPROVER',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: draft.secondApproverRequired,
            onChanged: (v) =>
                onChanged(draft.copyWith(secondApproverRequired: v)),
            title: const Text('Require a second approver for large arrears'),
            subtitle: Text(
              'Exceptions above the threshold are held as "pending second '
              'approval" and grant no access until a Headteacher/Director '
              'approves.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted(context),
              ),
            ),
          ),
          if (draft.secondApproverRequired)
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Arrears threshold (UGX)',
                isDense: true,
              ),
              onChanged: (v) => onChanged(
                draft.copyWith(
                  secondApproverArrearsThresholdUgx: int.tryParse(v) ?? 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpiryDefault extends StatelessWidget {
  const _ExpiryDefault({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(
      text: value == 0 ? '' : value.toString(),
    );
    return SectionCard(
      title: 'EXCEPTION EXPIRY DEFAULT',
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Default expiry (days, 0 = none)',
          isDense: true,
          helperText: 'Pre-fills the expiry date when granting an exception.',
          helperStyle: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted(context),
          ),
        ),
        onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
      ),
    );
  }
}

class _RestrictionMessageField extends StatelessWidget {
  const _RestrictionMessageField({
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value);
    return SectionCard(
      title: 'PARENT RESTRICTION MESSAGE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(isDense: true),
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Shown to parents when a report is withheld. Do not include '
            'balances, policy details or staff notes.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.policy});
  final FinancialClearancePolicy policy;

  @override
  Widget build(BuildContext context) {
    final examples = _examples();
    return SectionCard(
      title: 'PREVIEW · WORKED EXAMPLES',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in examples)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    e.cleared ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: e.cleared
                        ? AppColors.success(context)
                        : AppColors.danger(context),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      e.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<({String text, bool cleared})> _examples() {
    switch (policy.mode) {
      case ClearanceMode.fullBalance:
        return [
          (
            text:
                'Term fees UGX 800,000, paid UGX 800,000 → balance 0 → '
                'report auto-releases.',
            cleared: true,
          ),
          (
            text:
                'Term fees UGX 800,000, paid UGX 600,000 → balance '
                '${CurrencyFormatter.ugx(200000)} → withheld until paid or an '
                'exception is granted.',
            cleared: false,
          ),
          (
            text: policy.compulsoryOnly
                ? 'An unpaid optional charge (e.g. clubs) does NOT withhold '
                      'the report — only compulsory charges count.'
                : 'Every charge counts, including optional ones.',
            cleared: policy.compulsoryOnly,
          ),
        ];
      case ClearanceMode.minimumPercentage:
        final p = policy.minimumPercentagePaid;
        return [
          (
            text:
                'Term fees UGX 1,000,000, paid ${p + 5}% → meets the $p% '
                'minimum → report releases.',
            cleared: true,
          ),
          (
            text:
                'Term fees UGX 1,000,000, paid ${(p - 10).clamp(0, 100)}% → '
                'below the $p% minimum → withheld.',
            cleared: false,
          ),
        ];
      case ClearanceMode.selectedCategories:
        final n = policy.feeCategoryIds.length;
        return [
          (
            text:
                'All $n selected categor${n == 1 ? 'y' : 'ies'} fully paid → '
                'report releases even if other charges are outstanding.',
            cleared: true,
          ),
          (
            text:
                'One selected category still owing → withheld regardless of '
                'other payments.',
            cleared: false,
          ),
        ];
    }
  }
}

class _GranularityWarning extends StatelessWidget {
  const _GranularityWarning({required this.mode});
  final ClearanceMode mode;
  @override
  Widget build(BuildContext context) {
    if (mode != ClearanceMode.selectedCategories) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.warningSurface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.warning(context)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Selected-categories clearance currently works at bill '
              'granularity: a bill counts as "paid" only when its whole '
              'balance is zero. Precise per-line-item allocation is not yet '
              'available, so a part-paid bill that mixes a selected and an '
              'unselected charge is treated as unpaid.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
