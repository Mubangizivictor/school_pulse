import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/billing/data/datasources/pricing_band_remote_data_source.dart';
import 'package:school_pulse/features/billing/domain/entities/pricing_band.dart';
import 'package:school_pulse/features/super_admin/domain/entities/audit_log.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../../domain/repositories/super_admin_repository.dart';

/// Action names logged by functions/student_pricing_bands.js - used to
/// filter the platform-wide `super_admin_audit_logs` feed down to just
/// pricing-band history for this screen.
const List<String> _kPricingBandAuditActions = [
  'CREATE_PRICING_BAND',
  'UPDATE_PRICING_BAND',
  'DEACTIVATE_PRICING_BAND',
];

/// Replaces [SubscriptionPlansScreen] on the Billing nav (Phase 3C). There
/// are no plans any more - every active school gets every feature, and
/// price is determined solely by verified enrolled student count against
/// `student_pricing_bands`. This screen is a compact band list (view/add/
/// edit-future/deactivate) plus a pricing-change audit trail; it
/// deliberately shows none of the old plan concepts (name/code, monthly-vs-
/// annual, module chips, seat/storage/SMS limits, recommended/public
/// toggles).
class StudentPricingScreen extends StatefulWidget {
  const StudentPricingScreen({super.key});

  @override
  State<StudentPricingScreen> createState() => _StudentPricingScreenState();
}

class _StudentPricingScreenState extends State<StudentPricingScreen> {
  final PricingBandRemoteDataSource _bands = PricingBandRemoteDataSource();
  SuperAdminRepository get _repository => di.sl<SuperAdminRepository>();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _date = DateFormat('d MMM yyyy');

  bool _loading = true;
  String? _error;
  List<PricingBand> _pricingBands = const [];

  bool _loadingHistory = true;
  List<AuditLog> _history = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadHistory();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bands = await _bands.getPricingBands();
      if (!mounted) return;
      setState(() {
        _pricingBands = bands;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = friendlyErrorMessage(error);
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final logs = await _repository.getAuditLogs();
      if (!mounted) return;
      setState(() {
        _history = logs
            .where((log) => _kPricingBandAuditActions.contains(log.action))
            .toList();
        _loadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_load(), _loadHistory()]);
  }

  Future<void> _openCreate() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PricingBandForm(dataSource: _bands),
    );
    if (created == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _openEdit(PricingBand band) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PricingBandForm(dataSource: _bands, existing: band),
    );
    if (updated == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _deactivate(PricingBand band) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate this band?'),
        content: Text(
          'Schools whose verified student count only matches this band '
          '(${_rangeLabel(band)}) will need a new active band to be priced '
          'at their next term. This does not affect invoices already '
          'issued.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _bands.deactivatePricingBand(band.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pricing band deactivated.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to deactivate band: ${friendlyErrorMessage(error)}'),
        ),
      );
    }
  }

  static String _rangeLabel(PricingBand band) {
    final formatter = NumberFormat('#,##0', 'en_UG');
    if (band.maxStudents == null) {
      return '${formatter.format(band.minStudents)}+ learners';
    }
    return '${formatter.format(band.minStudents)}–'
        '${formatter.format(band.maxStudents)} learners';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    appBar: AppBar(
      title: const Text('Student pricing'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openCreate,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add pricing band'),
    ),
    body: RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.l,
          AppSpacing.xl,
          AppSpacing.x4l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All School Pulse features are included. Price is based only '
              'on verified enrolled learners per term.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _bandsSection(context),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Pricing change history',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _historySection(context),
          ],
        ),
      ),
    ),
  );

  Widget _bandsSection(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: SchoolPulseLoader()),
      );
    }
    if (_error != null) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(child: Text(_error!)),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_pricingBands.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No pricing bands configured yet. Add one to start pricing '
          'schools by verified student count.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      );
    }
    final sorted = [..._pricingBands]
      ..sort((a, b) => a.minStudents.compareTo(b.minStudents));
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sorted.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final band = sorted[index];
          return ListTile(
            title: Text(
              _rangeLabel(band),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            subtitle: Text(
              '${_money.format(band.amountUgx)} / term'
              '${band.effectiveFrom != null ? ' · from ${_date.format(band.effectiveFrom!)}' : ''}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusBadge(
                  label: band.isActive ? 'Active' : 'Inactive',
                  color: band.isActive
                      ? AppColors.success(context)
                      : AppColors.textSecondary(context),
                ),
                if (band.isFutureEffective) ...[
                  const SizedBox(width: AppSpacing.s),
                  IconButton(
                    tooltip: 'Edit future-effective band',
                    onPressed: () => _openEdit(band),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ],
                if (band.isActive)
                  IconButton(
                    tooltip: 'Deactivate band',
                    onPressed: () => _deactivate(band),
                    icon: const Icon(Icons.block_outlined, size: 18),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _historySection(BuildContext context) {
    if (_loadingHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: SchoolPulseLoader()),
      );
    }
    if (_history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No pricing changes recorded yet.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      );
    }
    final sorted = [..._history]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sorted.length.clamp(0, 20),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final log = sorted[index];
          return ListTile(
            title: Text(
              _actionLabel(log.action),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            subtitle: Text(
              _date.format(log.timestamp),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _actionLabel(String action) => switch (action) {
    'CREATE_PRICING_BAND' => 'Pricing band created',
    'UPDATE_PRICING_BAND' => 'Pricing band updated',
    'DEACTIVATE_PRICING_BAND' => 'Pricing band deactivated',
    _ => action,
  };
}

/// Owner-only create/edit form for a pricing band. Purely a thin wrapper
/// around createPricingBand/updatePricingBand - all overlap/immutability
/// validation happens server-side (functions/student_pricing_bands.js); this
/// form only does client-side shape checks (min < max, amount > 0) so
/// obviously-invalid input doesn't round-trip.
class _PricingBandForm extends StatefulWidget {
  const _PricingBandForm({required this.dataSource, this.existing});

  final PricingBandRemoteDataSource dataSource;
  final PricingBand? existing;

  @override
  State<_PricingBandForm> createState() => _PricingBandFormState();
}

class _PricingBandFormState extends State<_PricingBandForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final TextEditingController _amountController;
  bool _unbounded = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _minController = TextEditingController(
      text: existing?.minStudents.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: existing?.maxStudents?.toString() ?? '',
    );
    _amountController = TextEditingController(
      text: existing?.amountUgx.toString() ?? '',
    );
    _unbounded = existing != null && existing.maxStudents == null;
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final minStudents = int.parse(_minController.text.trim());
    final maxStudents = _unbounded
        ? null
        : int.parse(_maxController.text.trim());
    final amountUgx = int.parse(_amountController.text.trim());
    try {
      if (widget.existing == null) {
        await widget.dataSource.createPricingBand(
          minStudents: minStudents,
          maxStudents: maxStudents,
          amountUgx: amountUgx,
        );
      } else {
        await widget.dataSource.updatePricingBand(
          bandId: widget.existing!.id,
          minStudents: minStudents,
          maxStudents: maxStudents,
          maxStudentsProvided: true,
          amountUgx: amountUgx,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = friendlyErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit pricing band' : 'Add pricing band',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            TextFormField(
              controller: _minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minimum learners'),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed < 0) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.m),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _unbounded,
              onChanged: (value) =>
                  setState(() => _unbounded = value ?? false),
              title: const Text('Unbounded (no maximum)'),
            ),
            if (!_unbounded)
              TextFormField(
                controller: _maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maximum learners',
                ),
                validator: (value) {
                  if (_unbounded) return null;
                  final parsed = int.tryParse(value?.trim() ?? '');
                  final min = int.tryParse(_minController.text.trim()) ?? 0;
                  if (parsed == null || parsed < min) {
                    return 'Enter a valid number ≥ minimum';
                  }
                  return null;
                },
              ),
            const SizedBox(height: AppSpacing.m),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Term price (UGX)',
              ),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                _error!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.danger(context),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Save changes' : 'Add band'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
