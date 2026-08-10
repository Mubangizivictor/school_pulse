import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Owner-editable manual payment method configuration (MTN MoMo / bank
/// details schools use to pay their subscription). Backed by the
/// owner-scoped `getManualPaymentConfig` / `updateManualPaymentConfig`
/// Cloud Functions — reads and writes go through Firestore server-side,
/// never directly from this client.
class ManualPaymentConfigScreen extends StatefulWidget {
  const ManualPaymentConfigScreen({super.key});

  @override
  State<ManualPaymentConfigScreen> createState() =>
      _ManualPaymentConfigScreenState();
}

class _ManualPaymentConfigScreenState extends State<ManualPaymentConfigScreen> {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  final _momoNumberController = TextEditingController();
  final _momoNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _momoNumberController.dispose();
    _momoNameController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _functions
          .httpsCallable('getManualPaymentConfig')
          .call<Map<String, dynamic>>();
      final data = result.data;
      final momo = Map<String, dynamic>.from(data['mobileMoney'] as Map);
      final bank = Map<String, dynamic>.from(data['bank'] as Map);
      if (!mounted) return;
      setState(() {
        _momoNumberController.text = momo['number']?.toString() ?? '';
        _momoNameController.text = momo['accountName']?.toString() ?? '';
        _bankNameController.text = bank['bankName']?.toString() ?? '';
        _bankBranchController.text = bank['branch']?.toString() ?? '';
        _bankAccountNameController.text = bank['accountName']?.toString() ?? '';
        _bankAccountNumberController.text =
            bank['accountNumber']?.toString() ?? '';
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _functions.httpsCallable('updateManualPaymentConfig').call({
        'mobileMoney': {
          'number': _momoNumberController.text.trim(),
          'accountName': _momoNameController.text.trim(),
        },
        'bank': {
          'bankName': _bankNameController.text.trim(),
          'branch': _bankBranchController.text.trim(),
          'accountName': _bankAccountNameController.text.trim(),
          'accountNumber': _bankAccountNumberController.text.trim(),
        },
      });
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manual payment methods updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _friendlyError(error);
      });
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can perform this action.';
    }
    if (text.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    return text.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Payment Configuration'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: SchoolPulseLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.x2l),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'These are the MTN MoMo and bank details schools see '
                      'when submitting a manual subscription payment. '
                      'Changes take effect immediately for every school.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _sectionCard(
                      context,
                      icon: Icons.phone_android_rounded,
                      title: 'MTN Mobile Money',
                      children: [
                        TextFormField(
                          controller: _momoNumberController,
                          enabled: !_saving,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'MoMo number',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextFormField(
                          controller: _momoNameController,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Account name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _sectionCard(
                      context,
                      icon: Icons.account_balance_rounded,
                      title: 'Bank Transfer',
                      children: [
                        TextFormField(
                          controller: _bankNameController,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Bank name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextFormField(
                          controller: _bankBranchController,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextFormField(
                          controller: _bankAccountNameController,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Account name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextFormField(
                          controller: _bankAccountNumberController,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Account number',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.l),
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
                        label: Text(_saving ? 'Saving…' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary(context)),
              const SizedBox(width: AppSpacing.m),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          ...children,
        ],
      ),
    );
  }
}
