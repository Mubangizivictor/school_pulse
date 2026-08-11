import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/subscription_plan.dart';

/// Full subscription plan editor covering everything the SaaS Owner can
/// configure for a plan: identity, pricing/billing, limits, features and
/// visibility. Complements the narrower price-only dialog on
/// [SubscriptionPlansScreen] with the fields the public website and app
/// signup flow also depend on (isPublic/isActive/isPopular/displayOrder).
Future<bool?> showPlanEditSheet(BuildContext context, SubscriptionPlan plan) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlanEditSheet(plan: plan),
  );
}

class _PlanEditSheet extends StatefulWidget {
  const _PlanEditSheet({required this.plan});
  final SubscriptionPlan plan;

  @override
  State<_PlanEditSheet> createState() => _PlanEditSheetState();
}

class _PlanEditSheetState extends State<_PlanEditSheet> {
  final ManualPaymentService _service = ManualPaymentService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _daysController;
  late final TextEditingController _maxStudentsController;
  late final TextEditingController _maxStaffController;
  late final TextEditingController _storageController;
  late final TextEditingController _displayOrderController;
  final _featureController = TextEditingController();
  late List<String> _features;
  late BillingCycle _cycle;
  late bool _isPublic;
  late bool _isActive;
  late bool _isPopular;

  bool _saving = false;
  String? _error;

  bool get _isEnterprise => widget.plan.id.toLowerCase() == 'enterprise';

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _nameController = TextEditingController(text: plan.name);
    _descriptionController = TextEditingController(text: plan.description);
    _priceController = TextEditingController(
      text: plan.price.round().toString(),
    );
    _daysController = TextEditingController(
      text: plan.termLengthDays.toString(),
    );
    _maxStudentsController = TextEditingController(
      text: plan.maxStudents.toString(),
    );
    _maxStaffController = TextEditingController(text: plan.maxStaff.toString());
    _storageController = TextEditingController(
      text: plan.storageLimitGb % 1 == 0
          ? plan.storageLimitGb.toStringAsFixed(0)
          : plan.storageLimitGb.toString(),
    );
    _displayOrderController = TextEditingController(
      text: plan.displayOrder.toString(),
    );
    _features = List.of(plan.includedFeatures);
    _cycle = plan.billingCycle;
    _isPublic = plan.isPublic;
    _isActive = plan.isActive;
    _isPopular = plan.isPopular;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _daysController.dispose();
    _maxStudentsController.dispose();
    _maxStaffController.dispose();
    _storageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.l,
                    AppSpacing.xl,
                    AppSpacing.m,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit ${widget.plan.name}',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    children: [
                      PulseTextField(
                        label: 'Plan name',
                        controller: _nameController,
                        enabled: !_saving,
                        isRequired: true,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        enabled: !_saving,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Price (UGX)',
                        controller: _priceController,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        helperText: _isEnterprise
                            ? 'Use 0 to keep Enterprise as custom pricing.'
                            : 'Full payment is required; partial payments are disabled.',
                        validator: _validatePrice,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      DropdownButtonFormField<BillingCycle>(
                        initialValue: _cycle,
                        decoration: const InputDecoration(
                          labelText: 'Billing cycle',
                        ),
                        items: BillingCycle.values
                            .map(
                              (cycle) => DropdownMenuItem(
                                value: cycle,
                                child: Text(_cycleLabel(cycle)),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
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
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        validator: _validateDays,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Row(
                        children: [
                          Expanded(
                            child: PulseTextField(
                              label: 'Max students',
                              controller: _maxStudentsController,
                              enabled: !_saving,
                              keyboardType: TextInputType.number,
                              validator: _validateNonNegativeInt,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: PulseTextField(
                              label: 'Max staff',
                              controller: _maxStaffController,
                              enabled: !_saving,
                              keyboardType: TextInputType.number,
                              validator: _validateNonNegativeInt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Storage limit (GB)',
                        controller: _storageController,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || parsed < 0) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.l),
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
                                onDeleted: _saving
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
                              enabled: !_saving,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          IconButton(
                            onPressed: _saving ? null : _addFeature,
                            icon: const Icon(Icons.add_circle_outline_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.l),
                      PulseTextField(
                        label: 'Display order',
                        controller: _displayOrderController,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        helperText:
                            'Lower numbers appear first on the website.',
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
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _isPublic = value),
                        title: const Text('Visible on public website'),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _isActive,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _isActive = value),
                        title: const Text('Active (available for new signups)'),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _isPopular,
                        onChanged: _saving
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
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_saving ? 'Saving…' : 'Save Plan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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

  String? _validateNonNegativeInt(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) return 'Enter a valid number';
    return null;
  }

  static String _cycleLabel(BillingCycle cycle) => switch (cycle) {
    BillingCycle.monthly => 'Monthly',
    BillingCycle.termly => 'Per term',
    BillingCycle.yearly => 'Yearly',
  };

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.updatePlan(
        planId: widget.plan.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        priceUgx: int.parse(_priceController.text.replaceAll(',', '').trim()),
        billingCycle: _cycle,
        termLengthDays: int.parse(_daysController.text.trim()),
        maxStudents: int.parse(
          _maxStudentsController.text.trim().isEmpty
              ? '0'
              : _maxStudentsController.text.trim(),
        ),
        maxStaff: int.parse(
          _maxStaffController.text.trim().isEmpty
              ? '0'
              : _maxStaffController.text.trim(),
        ),
        storageLimitGb: double.parse(
          _storageController.text.trim().isEmpty
              ? '0'
              : _storageController.text.trim(),
        ),
        includedFeatures: _features,
        isPublic: _isPublic,
        isActive: _isActive,
        isPopular: _isPopular,
        displayOrder: int.parse(
          _displayOrderController.text.trim().isEmpty
              ? '0'
              : _displayOrderController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }
}
