import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  List<ManualSubscriptionPayment> _items = const [];
  bool _loading = true;
  String? _error;
  ManualPaymentStatus? _filter = ManualPaymentStatus.pendingVerification;
  String? _workingPaymentId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await _payments.getPayments();
      if (!mounted) return;
      setState(() {
        _items = items;
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

  List<ManualSubscriptionPayment> get _visibleItems => _filter == null
      ? _items
      : _items.where((payment) => payment.status == _filter).toList();

  int _count(ManualPaymentStatus status) =>
      _items.where((payment) => payment.status == status).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Billing'),
        actions: [
          IconButton(
            tooltip: 'Refresh payments',
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
          if (!isSuperAdminWide(context)) const SuperAdminLogoutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(child: _summary(theme)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(child: _filters()),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: SchoolPulseLoader()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(message: _error!, onRetry: _reload),
              )
            else if (_visibleItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(filter: _filter),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                sliver: SliverList.separated(
                  itemCount: _visibleItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final payment = _visibleItems[index];
                    return _PaymentCard(
                      payment: payment,
                      amount: _money.format(payment.submittedAmount),
                      submittedAt: _dateTime.format(payment.submittedAt),
                      isWorking: _workingPaymentId == payment.id,
                      onTap: () => _showPayment(payment),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summary(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manual payment verification',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'A school is activated or renewed only after you confirm that the money was actually received.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _SummaryChip(
              label: 'Pending verification',
              value: _count(ManualPaymentStatus.pendingVerification),
              icon: Icons.schedule_rounded,
            ),
            _SummaryChip(
              label: 'Approved',
              value: _count(ManualPaymentStatus.approved),
              icon: Icons.verified_rounded,
            ),
            _SummaryChip(
              label: 'Rejected',
              value: _count(ManualPaymentStatus.rejected),
              icon: Icons.cancel_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'pending', label: Text('Pending')),
          ButtonSegment(value: 'approved', label: Text('Approved')),
          ButtonSegment(value: 'rejected', label: Text('Rejected')),
          ButtonSegment(value: 'all', label: Text('All')),
        ],
        selected: {
          switch (_filter) {
            ManualPaymentStatus.pendingVerification => 'pending',
            ManualPaymentStatus.approved => 'approved',
            ManualPaymentStatus.rejected => 'rejected',
            null => 'all',
          },
        },
        onSelectionChanged: (selection) {
          final value = selection.first;
          setState(() {
            _filter = switch (value) {
              'pending' => ManualPaymentStatus.pendingVerification,
              'approved' => ManualPaymentStatus.approved,
              'rejected' => ManualPaymentStatus.rejected,
              _ => null,
            };
          });
        },
      ),
    );
  }

  Future<void> _showPayment(ManualSubscriptionPayment payment) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => _PaymentDetailsSheet(
        payment: payment,
        amount: _money.format(payment.submittedAmount),
        expectedAmount: _money.format(payment.expectedAmount),
        paidAt: _dateTime.format(payment.paidAt),
        submittedAt: _dateTime.format(payment.submittedAt),
        onOpenProof: payment.hasProof
            ? () async {
                Navigator.pop(sheetContext);
                await _openProof(payment);
              }
            : null,
        onApprove: payment.status == ManualPaymentStatus.pendingVerification
            ? () async {
                Navigator.pop(sheetContext);
                await _approve(payment);
              }
            : null,
        onReject: payment.status == ManualPaymentStatus.pendingVerification
            ? () async {
                Navigator.pop(sheetContext);
                await _reject(payment);
              }
            : null,
      ),
    );
  }

  Future<void> _openProof(ManualSubscriptionPayment payment) async {
    setState(() => _workingPaymentId = payment.id);
    try {
      final uri = await _payments.getProofUrl(payment.id);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('Could not open the proof document.');
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _workingPaymentId = null);
    }
  }

  Future<void> _approve(ManualSubscriptionPayment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve payment?'),
        content: Text(
          'Confirm that ${_money.format(payment.submittedAmount)} from ${payment.payerName} has actually arrived. This will ${payment.paymentType == ManualPaymentType.activation ? 'activate the school for the first time' : 'renew the school subscription'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.verified_rounded),
            label: const Text('Money Received — Approve'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _workingPaymentId = payment.id);
    try {
      await _payments.approve(payment.id);
      if (!mounted) return;
      _showSnack(
        payment.paymentType == ManualPaymentType.activation
            ? '${payment.schoolName} is now active.'
            : '${payment.schoolName} subscription renewed.',
      );
      await _reload();
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _workingPaymentId = null);
    }
  }

  Future<void> _reject(ManualSubscriptionPayment payment) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject payment proof'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'e.g. Transaction not found, wrong amount, unreadable proof',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              final value = controller.text.trim();
              if (value.length >= 3) Navigator.pop(dialogContext, value);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;

    setState(() => _workingPaymentId = payment.id);
    try {
      await _payments.reject(payment.id, reason);
      if (!mounted) return;
      _showSnack('Payment rejected. The school can submit corrected proof.');
      await _reload();
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _workingPaymentId = null);
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can perform this action.';
    }
    if (text.contains('unauthenticated')) return 'Your owner session expired. Sign in again.';
    return text.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label  ', style: theme.textTheme.bodySmall),
          Text('$value', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.amount,
    required this.submittedAt,
    required this.isWorking,
    required this.onTap,
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String submittedAt;
  final bool isWorking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = switch (payment.status) {
      ManualPaymentStatus.pendingVerification => 'Pending',
      ManualPaymentStatus.approved => 'Approved',
      ManualPaymentStatus.rejected => 'Rejected',
    };
    final statusColor = switch (payment.status) {
      ManualPaymentStatus.pendingVerification => Colors.orange,
      ManualPaymentStatus.approved => Colors.green,
      ManualPaymentStatus.rejected => theme.colorScheme.error,
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isWorking ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  payment.method == ManualPaymentMethod.mtn
                      ? Icons.phone_android_rounded
                      : Icons.account_balance_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            payment.schoolName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payment.planName} • ${payment.paymentType == ManualPaymentType.activation ? 'First activation' : 'Renewal'}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(amount, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          payment.method == ManualPaymentMethod.mtn ? 'MTN MoMo' : 'Centenary Bank',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(submittedAt, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isWorking
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentDetailsSheet extends StatelessWidget {
  const _PaymentDetailsSheet({
    required this.payment,
    required this.amount,
    required this.expectedAmount,
    required this.paidAt,
    required this.submittedAt,
    this.onOpenProof,
    this.onApprove,
    this.onReject,
  });

  final ManualSubscriptionPayment payment;
  final String amount;
  final String expectedAmount;
  final String paidAt;
  final String submittedAt;
  final VoidCallback? onOpenProof;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment verification', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(payment.schoolName, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          _DetailRow(label: 'Plan', value: payment.planName),
          _DetailRow(label: 'Payment type', value: payment.paymentType == ManualPaymentType.activation ? 'First activation' : 'Renewal'),
          _DetailRow(label: 'Method', value: payment.method == ManualPaymentMethod.mtn ? 'MTN Mobile Money' : 'Centenary Bank'),
          _DetailRow(label: 'Expected', value: expectedAmount),
          _DetailRow(label: 'Submitted', value: amount, emphasize: true),
          _DetailRow(label: 'Amount check', value: payment.amountMatches ? 'Exact amount ✓' : 'Amount mismatch'),
          _DetailRow(label: 'Payer', value: payment.payerName),
          _DetailRow(label: 'Reference', value: payment.reference),
          _DetailRow(label: 'Payment date', value: paidAt),
          _DetailRow(label: 'Submitted', value: submittedAt),
          if ((payment.note ?? '').isNotEmpty) _DetailRow(label: 'School note', value: payment.note!),
          if ((payment.rejectionReason ?? '').isNotEmpty) _DetailRow(label: 'Rejection reason', value: payment.rejectionReason!),
          const SizedBox(height: 18),
          if (onOpenProof != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenProof,
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Open Payment Proof'),
              ),
            ),
          if (onApprove != null && onReject != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: payment.amountMatches ? onApprove : null,
                    icon: const Icon(Icons.verified_rounded),
                    label: const Text('Approve Payment'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.emphasize = false});
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final ManualPaymentStatus? filter;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      ManualPaymentStatus.pendingVerification => 'No payments are waiting for verification.',
      ManualPaymentStatus.approved => 'No approved payments yet.',
      ManualPaymentStatus.rejected => 'No rejected payments.',
      null => 'No manual subscription payments have been submitted yet.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payments_outlined, size: 44, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 42, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
