import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Owner-editable manual payment method configuration (MTN MoMo, Airtel
/// Money, and bank details schools use to pay their subscription). Backed
/// by the owner-scoped `getManualPaymentConfig` / `updateManualPaymentConfig`
/// Cloud Functions — reads and writes go through Firestore server-side,
/// never directly from this client.
///
/// Presented as a list of provider cards (icon, masked summary, Edit) that
/// expand in place — mirrors a "saved payment methods" selector rather than
/// one long always-open form, since owners mostly glance at these, not
/// re-type them.
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
  final _airtelNumberController = TextEditingController();
  final _airtelNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _cashInstructionsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _cashEnabled = false;

  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _expanded;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _momoNumberController.dispose();
    _momoNameController.dispose();
    _airtelNumberController.dispose();
    _airtelNameController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    _cashInstructionsController.dispose();
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
      final airtel = Map<String, dynamic>.from(
        (data['airtelMoney'] as Map?) ?? const {},
      );
      final bank = Map<String, dynamic>.from(data['bank'] as Map);
      final cash = Map<String, dynamic>.from(
        (data['cash'] as Map?) ?? const {},
      );
      if (!mounted) return;
      setState(() {
        _momoNumberController.text = momo['number']?.toString() ?? '';
        _momoNameController.text = momo['accountName']?.toString() ?? '';
        _airtelNumberController.text = airtel['number']?.toString() ?? '';
        _airtelNameController.text = airtel['accountName']?.toString() ?? '';
        _bankNameController.text = bank['bankName']?.toString() ?? '';
        _bankBranchController.text = bank['branch']?.toString() ?? '';
        _bankAccountNameController.text = bank['accountName']?.toString() ?? '';
        _bankAccountNumberController.text =
            bank['accountNumber']?.toString() ?? '';
        _cashInstructionsController.text =
            cash['instructions']?.toString() ?? '';
        _cashEnabled = cash['enabled'] == true;
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
        'airtelMoney': {
          'number': _airtelNumberController.text.trim(),
          'accountName': _airtelNameController.text.trim(),
        },
        'bank': {
          'bankName': _bankNameController.text.trim(),
          'branch': _bankBranchController.text.trim(),
          'accountName': _bankAccountNameController.text.trim(),
          'accountNumber': _bankAccountNumberController.text.trim(),
        },
        'cash': {
          'enabled': _cashEnabled,
          'instructions': _cashInstructionsController.text.trim(),
        },
      });
      if (!mounted) return;
      setState(() {
        _saving = false;
        _expanded = null;
      });
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

  String _mask(String value) {
    if (value.length <= 4) return value;
    return '•••• ${value.substring(value.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(
                            'Schools see these details when submitting a '
                            'manual subscription payment. Changes apply '
                            'immediately for every school.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary(context),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ProviderCard(
                    icon: Icons.phone_android_rounded,
                    iconColor: const Color(0xFFFFCB05),
                    title: 'MTN Mobile Money',
                    summary: _momoNumberController.text.isEmpty
                        ? 'Not set'
                        : '${_mask(_momoNumberController.text)} · '
                              '${_momoNameController.text}',
                    isExpanded: _expanded == 'momo',
                    onTap: () => setState(
                      () => _expanded = _expanded == 'momo' ? null : 'momo',
                    ),
                    fields: [
                      PulseTextField(
                        label: 'MoMo number',
                        controller: _momoNumberController,
                        enabled: !_saving,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (value) {
                          final hasName = _momoNameController.text
                              .trim()
                              .isNotEmpty;
                          if (hasName &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Account name',
                        controller: _momoNameController,
                        enabled: !_saving,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          final hasNumber = _momoNumberController.text
                              .trim()
                              .isNotEmpty;
                          if (hasNumber &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _ProviderCard(
                    icon: Icons.phone_android_rounded,
                    iconColor: const Color(0xFFED1C24),
                    title: 'Airtel Money',
                    summary: _airtelNumberController.text.isEmpty
                        ? 'Not set'
                        : '${_mask(_airtelNumberController.text)} · '
                              '${_airtelNameController.text}',
                    isExpanded: _expanded == 'airtel',
                    onTap: () => setState(
                      () => _expanded = _expanded == 'airtel' ? null : 'airtel',
                    ),
                    fields: [
                      PulseTextField(
                        label: 'Airtel number',
                        controller: _airtelNumberController,
                        enabled: !_saving,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (value) {
                          final hasName = _airtelNameController.text
                              .trim()
                              .isNotEmpty;
                          if (hasName &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Account name',
                        controller: _airtelNameController,
                        enabled: !_saving,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          final hasNumber = _airtelNumberController.text
                              .trim()
                              .isNotEmpty;
                          if (hasNumber &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _ProviderCard(
                    icon: Icons.account_balance_rounded,
                    iconColor: AppColors.primary(context),
                    title: 'Bank Transfer',
                    summary: _bankNameController.text.isEmpty
                        ? 'Not set'
                        : '${_bankNameController.text} · '
                              '${_mask(_bankAccountNumberController.text)}',
                    isExpanded: _expanded == 'bank',
                    onTap: () => setState(
                      () => _expanded = _expanded == 'bank' ? null : 'bank',
                    ),
                    fields: [
                      PulseTextField(
                        label: 'Bank name',
                        controller: _bankNameController,
                        enabled: !_saving,
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (value) {
                          final hasOther =
                              _bankAccountNameController.text
                                  .trim()
                                  .isNotEmpty ||
                              _bankAccountNumberController.text
                                  .trim()
                                  .isNotEmpty;
                          if (hasOther &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Branch',
                        controller: _bankBranchController,
                        enabled: !_saving,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Account name',
                        controller: _bankAccountNameController,
                        enabled: !_saving,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          final hasOther =
                              _bankNameController.text.trim().isNotEmpty ||
                              _bankAccountNumberController.text
                                  .trim()
                                  .isNotEmpty;
                          if (hasOther &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Account number',
                        controller: _bankAccountNumberController,
                        enabled: !_saving,
                        prefixIcon: Icons.numbers_outlined,
                        validator: (value) {
                          final hasOther =
                              _bankNameController.text.trim().isNotEmpty ||
                              _bankAccountNameController.text.trim().isNotEmpty;
                          if (hasOther &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _ProviderCard(
                    icon: Icons.payments_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    title: 'Cash',
                    summary: !_cashEnabled
                        ? 'Disabled'
                        : (_cashInstructionsController.text.isEmpty
                              ? 'Enabled · no instructions set'
                              : _cashInstructionsController.text),
                    isExpanded: _expanded == 'cash',
                    onTap: () => setState(
                      () => _expanded = _expanded == 'cash' ? null : 'cash',
                    ),
                    fields: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _cashEnabled,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _cashEnabled = value),
                        title: Text(
                          'Accept cash payments',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PulseTextField(
                        label: 'Instructions for schools',
                        controller: _cashInstructionsController,
                        enabled: !_saving,
                        maxLines: 3,
                        prefixIcon: Icons.notes_outlined,
                        validator: (value) {
                          if (_cashEnabled &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Required when cash is enabled';
                          }
                          return null;
                        },
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Saving…' : 'Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// A collapsible "saved payment method" row: icon + title + masked summary
/// with an Edit affordance, expanding in place to reveal its form fields.
class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.summary,
    required this.isExpanded,
    required this.onTap,
    required this.fields,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String summary;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary(context)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isExpanded ? 'Close' : 'Edit',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                0,
                AppSpacing.m,
                AppSpacing.m,
              ),
              child: Column(children: fields),
            ),
        ],
      ),
    );
  }
}
