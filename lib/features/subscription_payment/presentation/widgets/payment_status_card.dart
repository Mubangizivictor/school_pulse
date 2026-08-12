import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';

import '../../domain/entities/payment_attempt.dart';
import '../bloc/subscription_payment_cubit.dart';

/// Renders the live status of an in-flight MTN payment attempt using only
/// existing design-system primitives (AppCard/StatusBadge/SchoolPulseLoader),
/// matching the copy specified for each state.
class PaymentStatusCard extends StatelessWidget {
  const PaymentStatusCard({
    super.key,
    required this.status,
    required this.paymentAttempt,
  });

  final SubscriptionPaymentStatus status;
  final PaymentAttempt? paymentAttempt;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return switch (status) {
      SubscriptionPaymentStatus.initiating => _buildWaiting(
        context,
        title: 'Sending payment request…',
        body: 'Please wait while we contact MTN Mobile Money.',
      ),
      SubscriptionPaymentStatus.awaitingApproval => _buildWaiting(
        context,
        title: 'Payment request sent',
        body:
            'Approve the MTN Mobile Money request on your phone.\n\n'
            'Do not close this screen while we confirm your payment.',
      ),
      SubscriptionPaymentStatus.checking => _buildWaiting(
        context,
        title: 'Payment still processing',
        body: 'We have not yet received final confirmation from MTN.',
      ),
      SubscriptionPaymentStatus.timedOut => _buildWaiting(
        context,
        title: 'Payment still processing',
        body:
            'We have not yet received final confirmation from MTN. '
            'You can check back later - this screen will keep showing the latest status.',
      ),
      SubscriptionPaymentStatus.succeeded => _buildResult(
        context,
        semantic: semantic,
        success: true,
        title: 'Payment Successful',
        body: 'Your School Pulse subscription has been activated.',
      ),
      SubscriptionPaymentStatus.failed => _buildResult(
        context,
        semantic: semantic,
        success: false,
        title: 'Payment Failed',
        body: 'No subscription change was made.',
      ),
      SubscriptionPaymentStatus.idle => const SizedBox.shrink(),
    };
  }

  Widget _buildWaiting(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SchoolPulseLoader(size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(
    BuildContext context, {
    required SemanticColors semantic,
    required bool success,
    required String title,
    required String body,
  }) {
    final color = success ? semantic.success : semantic.error;
    final attempt = paymentAttempt;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: success ? 'Successful' : 'Failed',
                color: color,
                icon: success
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (attempt != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _detailRow(
              'Amount',
              CurrencyFormatter.ugx(attempt.realPlanPriceUgx.toDouble()),
            ),
            _detailRow('Plan', attempt.planName),
            _detailRow('Payment reference', attempt.id),
            _detailRow(
              'Date/time',
              DateFormat(
                'MMM dd, yyyy • hh:mm a',
              ).format(attempt.settledAt ?? attempt.createdAt),
            ),
            if (success && attempt.subscriptionExpiry != null)
              _detailRow(
                'Next renewal date',
                DateFormat('MMM dd, yyyy').format(attempt.subscriptionExpiry!),
              ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 2, child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
