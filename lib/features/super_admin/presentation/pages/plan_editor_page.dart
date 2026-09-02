import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

/// Full-screen plan editor covering everything the SaaS Owner can configure
/// for a plan: identity, pricing/billing, trial, limits, included modules,
/// visibility, and archive/reactivate lifecycle. `plan == null` means
/// create mode; otherwise this edits the given plan.
class PlanEditorPage extends StatefulWidget {
  const PlanEditorPage({super.key, required this.plan, this.service});

  final SubscriptionPlan? plan;

  /// Injectable for widget tests, which otherwise crash constructing the
  /// real service's FirebaseFunctions.instanceFor without Firebase.init.
  final ManualPaymentService? service;

  @override
  State<PlanEditorPage> createState() => _PlanEditorPageState();
}

class _PlanEditorPageState extends State<PlanEditorPage> {
  late final ManualPaymentService _service =
      widget.service ?? ManualPaymentService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _daysController;
  late final TextEditingController _trialDaysController;
  late final TextEditingController _maxStudentsController;
  late final TextEditingController _maxStaffController;
  late final TextEditingController _storageController;
  late final TextEditingController _smsLimitController;
  late final TextEditingController _displayOrderController;
  final _featureController = TextEditingController();
  late List<String> _features;
  late Set<String> _includedModules;
  late BillingCycle _cycle;
  late bool _isPublic;
  late bool _isActive;
  late bool _isPopular;

  bool _saving = false;
  bool _archiving = false;
  String? _error;

  bool get _isCreate => widget.plan == null;
  bool get _isEnterprise => widget.plan?.id.toLowerCase() == 'enterprise';
  bool get _isArchived => widget.plan?.isArchived ?? false;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _codeController = TextEditingController(text: plan?.id ?? '');
    _nameController = TextEditingController(text: plan?.name ?? '');
    _descriptionController = TextEditingController(
      text: plan?.description ?? '',
    );
    _priceController = TextEditingController(
      text: plan == null ? '' : plan.price.round().toString(),
    );
    _daysController = TextEditingController(
      text: (plan?.termLengthDays ?? 120).toString(),
    );
    _trialDaysController = TextEditingController(
      text: (plan?.trialDays ?? 0).toString(),
    );
    _maxStudentsController = TextEditingController(
      text: (plan?.maxStudents ?? 0).toString(),
    );
    _maxStaffController = TextEditingController(
      text: (plan?.maxStaff ?? 0).toString(),
    );
    _storageController = TextEditingController(
      text: plan == null
          ? '0'
          : (plan.storageLimitGb % 1 == 0
                ? plan.storageLimitGb.toStringAsFixed(0)
                : plan.storageLimitGb.toString()),
    );
    _smsLimitController = TextEditingController(
      text: (plan?.smsLimitPerMonth ?? 0).toString(),
    );
    _displayOrderController = TextEditingController(
      text: (plan?.displayOrder ?? 0).toString(),
    );
    _features = List.of(plan?.includedFeatures ?? const []);
    _includedModules = Set.of(plan?.includedModules ?? const []);
    _cycle = plan?.billingCycle ?? BillingCycle.monthly;
    _isPublic = plan?.isPublic ?? true;
    _isActive = plan?.isActive ?? true;
    _isPopular = plan?.isPopular ?? false;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _daysController.dispose();
    _trialDaysController.dispose();
    _maxStudentsController.dispose();
    _maxStaffController.dispose();
    _storageController.dispose();
    _smsLimitController.dispose();
    _displayOrderController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  void _addFeature() {
    final value = _featureController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _features = [..._features, value];
      _featureController.clear();
    });
  }

  void _removeFeature(String value) {
    setState(() => _features = _features.where((f) => f != value).toList());
  }

  void _toggleModule(String key, bool selected) {
    setState(() {
      if (selected) {
        _includedModules.add(key);
      } else {
        _includedModules.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = _saving || _archiving;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreate ? 'New plan' : 'Edit plan'),
        actions: [
          TextButton(
            onPressed: busy ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.l,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  children: [
                    PulseTextField(
                      label: 'Plan name',
                      controller: _nameController,
                      enabled: !busy,
                      isRequired: true,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    PulseTextField(
                      label: 'Plan code',
                      controller: _codeController,
                      enabled: !busy && _isCreate,
                      readOnly: !_isCreate,
                      isRequired: true,
                      helperText: _isCreate
                          ? 'Lowercase letters, numbers, underscores. Cannot be changed after creation.'
                          : 'Plan code cannot be changed after creation.',
                      validator: _isCreate ? _validateCode : null,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    PulseTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      enabled: !busy,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    PulseTextField(
                      label: 'Monthly price (UGX)',
                      controller: _priceController,
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      helperText: _isEnterprise
                          ? 'Use 0 to keep Enterprise as custom pricing.'
                          : 'Full payment is required; partial payments are disabled.',
                      validator: _validatePrice,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    if (_isEnterprise) ...[
                      DropdownButtonFormField<BillingCycle>(
                        initialValue: _cycle,
                        decoration: const InputDecoration(
                          labelText: 'Billing interval',
                        ),
                        items: BillingCycle.values
                            .map(
                              (cycle) => DropdownMenuItem(
                                value: cycle,
                                child: Text(_cycleLabel(cycle)),
                              ),
                            )
                            .toList(),
                        onChanged: busy
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _cycle = value);
                                }
                              },
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Paid period length (days)',
                        controller: _daysController,
                        enabled: !busy,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        validator: _validateDays,
                      ),
                    ] else ...[
                      _BillingIntervalToggle(
                        cycle: _cycle,
                        enabled: !busy,
                        onChanged: (value) => setState(() => _cycle = value),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.m),
                    PulseTextField(
                      label: 'Trial days',
                      controller: _trialDaysController,
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      helperText: 'Number of free trial days before billing starts.',
                      validator: _validateTrialDays,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    PulseTextField(
                      label: 'Student limit',
                      controller: _maxStudentsController,
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      validator: _validateNonNegativeInt,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _isActive,
                      onChanged: (!busy && !_isArchived)
                          ? (value) => setState(() => _isActive = value)
                          : null,
                      title: const Text('Active'),
                      subtitle: const Text(
                        'Available for new subscriptions when on.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SectionHeader(title: 'Included modules'),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Modules included in this plan\'s description. Informational only — does not automatically enable modules for a school.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      children: kPlanModuleKeys
                          .map(
                            (key) => FilterChip(
                              label: Text(_moduleLabel(key)),
                              selected: _includedModules.contains(key),
                              onSelected: busy
                                  ? null
                                  : (selected) => _toggleModule(key, selected),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SectionHeader(title: 'Limits'),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      children: [
                        Expanded(
                          child: PulseTextField(
                            label: 'Staff limit',
                            controller: _maxStaffController,
                            enabled: !busy,
                            keyboardType: TextInputType.number,
                            validator: _validateNonNegativeInt,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: PulseTextField(
                            label: 'Storage limit (GB)',
                            controller: _storageController,
                            enabled: !busy,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              final parsed = double.tryParse(
                                (value ?? '').trim(),
                              );
                              if (parsed == null || parsed < 0) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    PulseTextField(
                      label: 'SMS limit per month',
                      controller: _smsLimitController,
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      validator: _validateSmsLimit,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SectionHeader(title: 'Advanced'),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Included features',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      children: _features
                          .map(
                            (feature) => Chip(
                              label: Text(feature),
                              onDeleted: busy
                                  ? null
                                  : () => _removeFeature(feature),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      children: [
                        Expanded(
                          child: PulseTextField(
                            label: 'Add a feature',
                            controller: _featureController,
                            enabled: !busy,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        IconButton(
                          onPressed: busy ? null : _addFeature,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    PulseTextField(
                      label: 'Display order',
                      controller: _displayOrderController,
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      helperText: 'Lower numbers appear first on the website.',
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _isPublic,
                      onChanged: busy
                          ? null
                          : (value) => setState(() => _isPublic = value),
                      title: const Text('Visible on public website'),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _isPopular,
                      onChanged: busy
                          ? null
                          : (value) => setState(() => _isPopular = value),
                      title: const Text('Recommended plan'),
                      subtitle: const Text(
                        'Highlighted as "Recommended" on the website.',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (!_isCreate) ...[
                      const SizedBox(height: AppSpacing.xl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.m),
                      if (_isArchived)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _archiving ? null : _reactivate,
                            icon: _archiving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                            label: const Text('Reactivate plan'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success(context),
                              side: BorderSide(
                                color: AppColors.success(context),
                              ),
                            ),
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _archiving ? null : _archive,
                            icon: _archiving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.archive_outlined),
                            label: const Text('Archive plan'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger(context),
                              side: BorderSide(color: AppColors.danger(context)),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          "You can't delete a plan that is assigned to one or more schools.",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.l,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: busy ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving…' : 'Save plan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _moduleLabel(String key) => switch (key) {
    'attendance' => 'Attendance',
    'reports' => 'Reports',
    'finance' => 'Finance',
    'messaging' => 'Messaging',
    'health' => 'Health',
    'transport' => 'Transport',
    'library' => 'Library',
    'boarding' => 'Boarding',
    _ => key,
  };

  static String _cycleLabel(BillingCycle cycle) => switch (cycle) {
    BillingCycle.monthly => 'Monthly',
    BillingCycle.termly => 'Per term',
    BillingCycle.yearly => 'Yearly',
  };

  String? _validateCode(String? value) {
    final code = (value ?? '').trim().toLowerCase();
    if (!RegExp(r'^[a-z][a-z0-9_]{1,39}$').hasMatch(code)) {
      return 'Lowercase letters, numbers, underscores, 2-40 chars, starting with a letter.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final price = int.tryParse((value ?? '').replaceAll(',', '').trim());
    if (price == null || price < 0) return 'Enter a valid plan price';
    if (!_isEnterprise && price == 0) return 'Price must be greater than zero';
    return null;
  }

  String? _validateDays(String? value) {
    final days = int.tryParse((value ?? '').trim());
    if (days == null || days < 1 || days > 730) {
      return 'Must be between 1 and 730 days';
    }
    return null;
  }

  String? _validateTrialDays(String? value) {
    final days = int.tryParse((value ?? '').trim());
    if (days == null || days < 0 || days > 90) {
      return 'Must be between 0 and 90 days';
    }
    return null;
  }

  String? _validateSmsLimit(String? value) {
    final limit = int.tryParse((value ?? '').trim());
    if (limit == null || limit < 0 || limit > 1000000) {
      return 'Enter a valid limit';
    }
    return null;
  }

  String? _validateNonNegativeInt(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) return 'Enter a valid number';
    return null;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final billingCycle = _cycle;
      final termLengthDays = _isEnterprise
          ? int.parse(_daysController.text.trim())
          : (_cycle == BillingCycle.yearly ? 365 : 30);
      final priceUgx = int.parse(
        _priceController.text.replaceAll(',', '').trim(),
      );
      final trialDays = int.parse(
        _trialDaysController.text.trim().isEmpty
            ? '0'
            : _trialDaysController.text.trim(),
      );
      final maxStudents = int.parse(
        _maxStudentsController.text.trim().isEmpty
            ? '0'
            : _maxStudentsController.text.trim(),
      );
      final maxStaff = int.parse(
        _maxStaffController.text.trim().isEmpty
            ? '0'
            : _maxStaffController.text.trim(),
      );
      final storageLimitGb = double.parse(
        _storageController.text.trim().isEmpty
            ? '0'
            : _storageController.text.trim(),
      );
      final smsLimitPerMonth = int.parse(
        _smsLimitController.text.trim().isEmpty
            ? '0'
            : _smsLimitController.text.trim(),
      );
      final displayOrder = int.parse(
        _displayOrderController.text.trim().isEmpty
            ? '0'
            : _displayOrderController.text.trim(),
      );

      if (_isCreate) {
        await _service.createPlan(
          planId: _codeController.text.trim().toLowerCase(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          priceUgx: priceUgx,
          billingCycle: billingCycle,
          termLengthDays: termLengthDays,
          trialDays: trialDays,
          maxStudents: maxStudents,
          maxStaff: maxStaff,
          storageLimitGb: storageLimitGb,
          smsLimitPerMonth: smsLimitPerMonth,
          includedFeatures: _features,
          includedModules: _includedModules.toList(),
          isPublic: _isPublic,
          isActive: _isActive,
          isPopular: _isPopular,
          displayOrder: displayOrder,
        );
      } else {
        await _service.updatePlan(
          planId: widget.plan!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          priceUgx: priceUgx,
          billingCycle: billingCycle,
          termLengthDays: termLengthDays,
          trialDays: trialDays,
          maxStudents: maxStudents,
          maxStaff: maxStaff,
          storageLimitGb: storageLimitGb,
          smsLimitPerMonth: smsLimitPerMonth,
          includedFeatures: _features,
          includedModules: _includedModules.toList(),
          isPublic: _isPublic,
          isActive: _isActive,
          isPopular: _isPopular,
          displayOrder: displayOrder,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _archive() async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Archive this plan?',
      message:
          'Existing schools keep it, but it won\'t be offered for new subscriptions.',
      confirmLabel: 'Archive',
      isDestructive: true,
    );
    if (confirmed != true) return;
    setState(() {
      _archiving = true;
      _error = null;
    });
    try {
      await _service.archivePlan(widget.plan!.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _archiving = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _reactivate() async {
    setState(() {
      _archiving = true;
      _error = null;
    });
    try {
      await _service.reactivatePlan(widget.plan!.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _archiving = false;
        _error = error.toString();
      });
    }
  }
}

/// 2-option Monthly/Annual toggle mapping to BillingCycle.monthly/yearly for
/// new plans, with a 3rd non-removable "Termly" segment shown only when the
/// plan being edited already uses BillingCycle.termly (the 3 seeded public
/// plans) so existing data isn't silently changed on open+save.
class _BillingIntervalToggle extends StatelessWidget {
  const _BillingIntervalToggle({
    required this.cycle,
    required this.enabled,
    required this.onChanged,
  });

  final BillingCycle cycle;
  final bool enabled;
  final ValueChanged<BillingCycle> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <BillingCycle>[
      BillingCycle.monthly,
      BillingCycle.yearly,
      if (cycle == BillingCycle.termly) BillingCycle.termly,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing interval',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer(context),
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: options
                .map(
                  (option) => Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.s),
                      onTap: enabled ? () => onChanged(option) : null,
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: option == cycle
                              ? AppColors.primary(context)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.s),
                        ),
                        child: Text(
                          option == BillingCycle.yearly
                              ? 'Annual'
                              : option == BillingCycle.termly
                              ? 'Termly'
                              : 'Monthly',
                          style: AppTypography.labelLarge.copyWith(
                            color: option == cycle
                                ? Theme.of(context).colorScheme.onPrimary
                                : AppColors.textSecondary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
