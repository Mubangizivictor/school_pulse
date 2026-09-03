import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import '../responsive.dart';

/// Full-page (mobile) / wide-panel (desktop) payment verification screen.
///
/// Replaces the old bottom sheet. Preserves the exact approve/reject/proof
/// business logic from the previous `_PaymentDetailsSheet` +
/// `_BillingPageState` implementation: proof URLs are always fetched fresh
/// and opened externally, mutations only go through [ManualPaymentService],
/// and buttons are disabled while a request is in flight.
///
/// Returns `true` via [Navigator.pop] when the payment was approved or
/// rejected, so the caller knows to reload its list.
class PaymentReviewScreen extends StatefulWidget {
  const PaymentReviewScreen({super.key, required this.payment});

  final ManualSubscriptionPayment payment;

  /// Pushes the review screen using a full page route on mobile, or a wide
  /// fixed-width panel dialog (640px) on desktop widths.
  ///
  /// Also syncs the browser URL to `/super-admin/payments/:id` while open,
  /// and back to `/super-admin/payments` once the dialog/page closes by
  /// any means (approve/reject pop, in-app back, or browser Back) — there
  /// is no fetch-by-id path yet, so this is address-bar/history signaling
  /// only, not a route that can be cold-loaded from a refresh.
  static Future<bool?> open(
    BuildContext context,
    ManualSubscriptionPayment payment,
  ) async {
    const sectionUrl = '/super-admin/payments';
    context.go('$sectionUrl/${payment.id}');
    final bool? result;
    if (isSuperAdminWide(context)) {
      result = await showGeneralDialog<bool>(
        context: context,
        barrierLabel: 'Payment Verification',
        barrierDismissible: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, _, _) => Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 8,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SizedBox(
              width: 680,
              height: double.infinity,
              child: PaymentReviewScreen(payment: payment),
            ),
          ),
        ),
        transitionBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      );
    } else {
      result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentReviewScreen(payment: payment),
        ),
      );
    }
    if (context.mounted) context.go(sectionUrl);
    return result;
  }

  @override
  State<PaymentReviewScreen> createState() => _PaymentReviewScreenState();
}

class _PaymentReviewScreenState extends State<PaymentReviewScreen> {
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  late ManualSubscriptionPayment _payment;
  bool _isWorking = false;
  bool _didMutate = false;

  static const _rejectionReasonChips = [
    'Transaction not found',
    'Wrong payment amount',
    'Unreadable proof',
    'Duplicate proof',
    'Incorrect account/payment destination',
  ];

  @override
  void initState() {
    super.initState();
    _payment = widget.payment;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payment = _payment;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && context.mounted) {
          context.go('/super-admin/payments');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Verification'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context, _didMutate),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x3l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      payment.schoolName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: _statusLabel(payment.status),
                    color: _statusColor(context, payment.status),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x3l),
              _amountMatchBanner(context, payment),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'School', value: payment.schoolName),
                    _DetailRow(label: 'Plan', value: payment.planName),
                    _DetailRow(
                      label: 'Payment type',
                      value: payment.paymentType == ManualPaymentType.activation
                          ? 'First Activation'
                          : 'Renewal',
                    ),
                    _DetailRow(
                      label: 'Expected amount',
                      value: _money.format(payment.expectedAmount),
                    ),
                    _DetailRow(
                      label: 'Submitted amount',
                      value: _money.format(payment.submittedAmount),
                      emphasize: true,
                    ),
                    _DetailRow(
                      label: 'Method',
                      value: payment.method == ManualPaymentMethod.mtn
                          ? 'MTN Mobile Money'
                          : 'Centenary Bank',
                    ),
                    _DetailRow(label: 'Payer', value: payment.payerName),
                    _DetailRow(label: 'Reference', value: payment.reference),
                    _DetailRow(
                      label: 'Payment date',
                      value: _dateTime.format(payment.paidAt),
                    ),
                    _DetailRow(
                      label: 'Submitted',
                      value: _dateTime.format(payment.submittedAt),
                    ),
                    if ((payment.note ?? '').isNotEmpty)
                      _DetailRow(label: 'School note', value: payment.note!),
                    if ((payment.rejectionReason ?? '').isNotEmpty)
                      _DetailRow(
                        label: 'Rejection reason',
                        value: payment.rejectionReason!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _proofCard(context, payment),
              const SizedBox(height: AppSpacing.x6l),
            ],
          ),
        ),
        bottomNavigationBar:
            payment.status == ManualPaymentStatus.pendingVerification
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: SafeArea(
                  minimum: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isWorking ? null : _reject,
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger(context),
                            side: BorderSide(color: AppColors.danger(context)),
                            minimumSize: const Size(0, 52),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.l),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: (_isWorking || !payment.amountMatches)
                              ? null
                              : _approve,
                          icon: _isWorking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.verified_rounded),
                          label: const Text('Approve'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success(context),
                            minimumSize: const Size(0, 52),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _amountMatchBanner(
    BuildContext context,
    ManualSubscriptionPayment payment,
  ) {
    final matches = payment.amountMatches;
    return AlertBanner(
      title: matches ? 'Exact amount' : 'Amount mismatch',
      message: matches
          ? 'Submitted amount matches the expected plan price.'
          : 'Submitted amount does not match the expected plan price of '
                '${_money.format(payment.expectedAmount)}. Approval is disabled until this is resolved.',
      color: matches ? AppColors.success(context) : AppColors.danger(context),
      icon: matches ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
    );
  }

  Widget _proofCard(BuildContext context, ManualSubscriptionPayment payment) {
    if (!payment.hasProof) {
      return const EmptyState(
        icon: Icons.image_not_supported_outlined,
        title: 'No proof attached',
        message: 'This school did not attach a payment proof document.',
      );
    }
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment proof',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Opens a time-limited secure link in your browser.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Flexible(
            child: OutlinedButton(
              onPressed: _isWorking ? null : _openProof,
              child: const Text('Open'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProof() async {
    setState(() => _isWorking = true);
    try {
      final uri = await _payments.getProofUrl(_payment.id);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('Could not open the proof document.');
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _approve() async {
    final payment = _payment;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve payment?'),
        content: Text(
          'Confirm that ${_money.format(payment.submittedAmount)} from ${payment.payerName} has actually arrived. This will ${payment.paymentType == ManualPaymentType.activation ? 'activate the school for the first time' : 'renew the school subscription'}.',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success(dialogContext),
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      await _payments.approve(payment.id);
      if (!mounted) return;
      _didMutate = true;
      _showSnack(
        payment.paymentType == ManualPaymentType.activation
            ? 'Payment verified. ${payment.schoolName} is now active.'
            : 'Payment verified. ${payment.schoolName}\'s subscription has been renewed.',
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _reject() async {
    final payment = _payment;
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Reject payment proof'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText:
                      'e.g. Transaction not found, wrong amount, unreadable proof',
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final chip in _rejectionReasonChips)
                    ActionChip(
                      label: Text(chip, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        controller.text = chip;
                        setDialogState(() {});
                      },
                    ),
                ],
              ),
            ],
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
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;

    setState(() => _isWorking = true);
    try {
      await _payments.reject(payment.id, reason);
      if (!mounted) return;
      _didMutate = true;
      _showSnack('Payment rejected. The school can submit corrected proof.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isWorking = false);
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
    if (text.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    return friendlyErrorMessage(error);
  }

  String _statusLabel(ManualPaymentStatus status) => switch (status) {
    ManualPaymentStatus.pendingVerification => 'Pending Verification',
    ManualPaymentStatus.approved => 'Approved',
    ManualPaymentStatus.rejected => 'Rejected',
  };

  Color _statusColor(BuildContext context, ManualPaymentStatus status) =>
      switch (status) {
        ManualPaymentStatus.pendingVerification => AppColors.warning(context),
        ManualPaymentStatus.approved => AppColors.success(context),
        ManualPaymentStatus.rejected => AppColors.danger(context),
      };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
