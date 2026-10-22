import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

/// Light-blue accent, used ONLY for selection state and the primary action
/// (per the redesign brief). The design-system `primary` stays black/white for
/// everything else.
Color paymentAccent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF5B8DEF)
    : const Color(0xFF2F6FED);

String paymentStatusLabel(ManualPaymentStatus status) => switch (status) {
  ManualPaymentStatus.pendingVerification => 'Pending',
  ManualPaymentStatus.approved => 'Approved',
  ManualPaymentStatus.rejected => 'Rejected',
};

/// Approved -> green, pending -> amber, rejected -> red. No other status colours.
Color paymentStatusColor(BuildContext context, ManualPaymentStatus status) =>
    switch (status) {
      ManualPaymentStatus.pendingVerification => AppColors.warning(context),
      ManualPaymentStatus.approved => AppColors.success(context),
      ManualPaymentStatus.rejected => AppColors.danger(context),
    };

String paymentMethodLabel(ManualPaymentMethod method) => switch (method) {
  ManualPaymentMethod.mtn => 'MTN MoMo',
  ManualPaymentMethod.bank => 'Centenary Bank',
};

/// Persistent right-hand inspector (desktop) / bottom-sheet body (mobile).
///
/// All approve / reject / proof business rules are preserved verbatim from the
/// previous `PaymentReviewScreen`: proof URLs are always fetched fresh and
/// opened externally, mutations only go through [ManualPaymentService], every
/// decision requires an explicit confirmation dialog, and the action buttons
/// are locked while a request is in flight (duplicate-action guard). On a
/// successful decision the server writes the immutable audit event.
class PaymentInspector extends StatefulWidget {
  const PaymentInspector({
    super.key,
    required this.payment,
    required this.onMutated,
    this.onClose,
    this.scrollable = true,
  });

  final ManualSubscriptionPayment payment;

  /// Called after a successful approve/reject so the host can reload its list.
  final VoidCallback onMutated;

  /// Optional close affordance (shown as an `x` in the header).
  final VoidCallback? onClose;

  /// When embedded in a sheet the sheet already scrolls; set false there.
  final bool scrollable;

  @override
  State<PaymentInspector> createState() => _PaymentInspectorState();
}

class _PaymentInspectorState extends State<PaymentInspector> {
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');
  final TextEditingController _noteController = TextEditingController();

  bool _isWorking = false;

  static const _rejectionReasonChips = [
    'Transaction not found',
    'Wrong payment amount',
    'Unreadable proof',
    'Duplicate proof',
    'Incorrect account/payment destination',
  ];

  @override
  void didUpdateWidget(covariant PaymentInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payment.id != widget.payment.id) {
      _noteController.clear();
      _isWorking = false;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final border = AppColors.border(context);
    final isPending =
        payment.status == ManualPaymentStatus.pendingVerification;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, payment),
        const SizedBox(height: 16),
        _schoolRow(context, payment),
        const SizedBox(height: 20),
        _sectionLabel(context, 'Submitted proof'),
        const SizedBox(height: 8),
        _proof(context, payment),
        const SizedBox(height: 20),
        Divider(height: 1, color: border),
        const SizedBox(height: 20),
        _sectionLabel(context, 'Payment details'),
        const SizedBox(height: 8),
        _detail(context, 'Plan', payment.planName),
        _detail(
          context,
          'Payment type',
          payment.paymentType == ManualPaymentType.activation
              ? 'Activation'
              : 'Renewal',
        ),
        _detail(context, 'Expected', _money.format(payment.expectedAmount)),
        _detail(
          context,
          'Amount',
          _money.format(payment.submittedAmount),
          emphasize: true,
        ),
        _methodDetail(context, payment),
        _detail(context, 'Payer', payment.payerName),
        _referenceDetail(context, payment),
        _detail(context, 'Payment date', _dateTime.format(payment.paidAt)),
        _detail(context, 'Submitted', _dateTime.format(payment.submittedAt)),
        if ((payment.note ?? '').isNotEmpty)
          _detail(context, 'School note', payment.note!),
        if ((payment.rejectionReason ?? '').isNotEmpty)
          _detail(context, 'Rejection reason', payment.rejectionReason!),
        const SizedBox(height: 20),
        if (!payment.amountMatches) ...[
          _amountMismatch(context, payment),
          const SizedBox(height: 16),
        ],
        if (isPending) ...[
          _sectionLabel(context, 'Audit note (optional)'),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            minLines: 2,
            maxLines: 4,
            maxLength: 300,
            enabled: !_isWorking,
            decoration: InputDecoration(
              hintText: 'Add a note about this payment…',
              filled: true,
              fillColor: AppColors.surfaceContainer(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _actions(context, payment),
        ] else
          _resolvedNote(context, payment),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: widget.scrollable
          ? SingleChildScrollView(child: content)
          : content,
    );
  }

  Widget _header(BuildContext context, ManualSubscriptionPayment payment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusChip(context, payment.status),
        const Spacer(),
        Flexible(
          child: Text(
            'Payment ID: ${payment.id}',
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        if (widget.onClose != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              onTap: widget.onClose,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusChip(BuildContext context, ManualPaymentStatus status) {
    final color = paymentStatusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        paymentStatusLabel(status).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }

  Widget _schoolRow(BuildContext context, ManualSubscriptionPayment payment) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(
            Icons.apartment_rounded,
            size: 20,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.schoolName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                payment.currency,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
  );

  Widget _proof(BuildContext context, ManualSubscriptionPayment payment) {
    if (!payment.hasProof) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 18,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No proof was attached to this payment.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 22,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment proof',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Opens a time-limited secure link.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Open / download proof',
            onPressed: _isWorking ? null : _openProof,
            icon: const Icon(Icons.open_in_full_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _detail(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodDetail(
    BuildContext context,
    ManualSubscriptionPayment payment,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child: Text(
              'Method',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Icon(
            payment.method == ManualPaymentMethod.mtn
                ? Icons.smartphone_rounded
                : Icons.account_balance_rounded,
            size: 15,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 6),
          Text(
            paymentMethodLabel(payment.method),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _referenceDetail(
    BuildContext context,
    ManualSubscriptionPayment payment,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              'Reference',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              payment.reference.isEmpty ? '—' : payment.reference,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          if (payment.reference.isNotEmpty)
            InkWell(
              onTap: () => _copyReference(payment.reference),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _amountMismatch(
    BuildContext context,
    ManualSubscriptionPayment payment,
  ) {
    final color = AppColors.danger(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Submitted amount does not match the expected plan price of '
              '${_money.format(payment.expectedAmount)}. Approval is disabled '
              'until this is resolved.',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resolvedNote(
    BuildContext context,
    ManualSubscriptionPayment payment,
  ) {
    final reviewed = payment.reviewedAt;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Text(
        payment.status == ManualPaymentStatus.approved
            ? 'This payment was approved${reviewed == null ? '' : ' on ${_dateTime.format(reviewed)}'}. Decisions are final and recorded in the audit log.'
            : 'This payment was rejected${reviewed == null ? '' : ' on ${_dateTime.format(reviewed)}'}. The school can submit corrected proof.',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, ManualSubscriptionPayment payment) {
    final canApprove = !_isWorking && payment.amountMatches;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canApprove ? _approve : null,
            icon: _isWorking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: const Text('Approve payment'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success(context),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isWorking ? null : _reject,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Reject payment'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger(context),
              side: BorderSide(color: AppColors.danger(context)),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Business logic (preserved verbatim) ------------------------------------

  Future<void> _openProof() async {
    setState(() => _isWorking = true);
    try {
      final uri = await _payments.getProofUrl(widget.payment.id);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('Could not open the proof document.');
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _copyReference(String reference) async {
    await Clipboard.setData(ClipboardData(text: reference));
    if (!mounted) return;
    _showSnack('Copied "$reference"');
  }

  Future<void> _approve() async {
    final payment = widget.payment;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve payment?'),
        content: Text(
          'Confirm that ${_money.format(payment.submittedAmount)} from '
          '${payment.payerName} has actually arrived. This will '
          '${payment.paymentType == ManualPaymentType.activation ? 'activate the school for the first time' : 'renew the school subscription'} '
          'and is recorded as an immutable audit event.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success(dialogContext),
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // Duplicate-action guard: bail if another request already started.
    if (_isWorking) return;

    setState(() => _isWorking = true);
    try {
      await _payments.approve(payment.id);
      if (!mounted) return;
      _showSnack(
        payment.paymentType == ManualPaymentType.activation
            ? 'Payment verified. ${payment.schoolName} is now active.'
            : 'Payment verified. ${payment.schoolName}\'s subscription has been renewed.',
      );
      widget.onMutated();
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _reject() async {
    final payment = widget.payment;
    final controller = TextEditingController(text: _noteController.text.trim());
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Reject payment proof'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This decision is final and recorded as an immutable audit '
                'event. Give a clear reason the school can act on.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),
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
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.length >= 3) Navigator.pop(dialogContext, value);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger(dialogContext),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    if (_isWorking) return;

    setState(() => _isWorking = true);
    try {
      await _payments.reject(payment.id, reason);
      if (!mounted) return;
      _showSnack('Payment rejected. The school can submit corrected proof.');
      widget.onMutated();
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
}
