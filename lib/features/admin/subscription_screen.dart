import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/data/models/payment_transaction.dart';
import 'package:school_pulse/features/admin/data/models/subscription.dart';
import 'package:school_pulse/features/admin/data/repositories/subscription_repository.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/subscription_payment/presentation/screens/mtn_momo_payment_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static final Uri _paymentPortal = Uri.parse(
    'https://schoolpulse.victorbee.com/payment',
  );

  final _repository = di.sl<SubscriptionRepository>();
  bool _openingPortal = false;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: const AdminAppBar(title: 'Subscription & Billing'),
      body: StreamBuilder<Subscription>(
        stream: _repository.watchSubscription(),
        builder: (context, subSnapshot) {
          if (subSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }
          final subscription =
              subSnapshot.data ??
              const Subscription(
                plan: 'School Pulse Plan',
                status: SubscriptionStatus.none,
                renewalDate: null,
                amountUgx: 0,
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(context, semantic, subscription),
                const SizedBox(height: 18),
                _buildManualPaymentCard(context),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Payment History'),
                const SizedBox(height: 12),
                _buildTransactionHistory(context, semantic),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    SemanticColors semantic,
    Subscription sub,
  ) {
    final (label, color) = switch (sub.status) {
      SubscriptionStatus.active => ('Active', semantic.success),
      SubscriptionStatus.gracePeriod => ('Payment Due', semantic.warning),
      SubscriptionStatus.expired => ('Renewal Required', semantic.error),
      SubscriptionStatus.none => (
        'Subscription',
        Theme.of(context).colorScheme.outline,
      ),
    };

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sub.plan,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              StatusBadge(label: label, color: color),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            sub.renewalDate != null
                ? 'Current paid period ends ${DateFormat('MMM dd, yyyy').format(sub.renewalDate!)}'
                : 'Open the payment portal for the current subscription amount and due date.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (sub.amountUgx > 0) ...[
            const SizedBox(height: 5),
            Text(
              CurrencyFormatter.ugx(sub.amountUgx.toDouble()),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: _openingPortal
                  ? 'Opening Payment Portal…'
                  : 'Pay / Renew Subscription',
              icon: Icons.open_in_new_rounded,
              onPressed: _openingPortal ? null : _openPaymentPortal,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              label: 'Pay with MTN Mobile Money',
              icon: Icons.phone_android_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MtnMomoPaymentScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualPaymentCard(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Manual payment verification',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'School Pulse accepts subscription payment by MTN Mobile Money or Centenary Bank transfer. The payment portal shows the current plan price and official payment details.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          const _PaymentMethodLine(
            icon: Icons.phone_android_rounded,
            title: 'MTN Mobile Money',
            subtitle: 'Pay manually, then upload the transaction proof.',
          ),
          const SizedBox(height: 10),
          const _PaymentMethodLine(
            icon: Icons.account_balance_rounded,
            title: 'Centenary Bank',
            subtitle:
                'Transfer or deposit, then upload the receipt or confirmation.',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Payment proof does not activate School Pulse automatically. The SaaS Owner must verify that the money was received and approve the payment.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(
    BuildContext context,
    SemanticColors semantic,
  ) {
    return StreamBuilder<List<PaymentTransaction>>(
      stream: _repository.watchRecentTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: SchoolPulseLoader(),
            ),
          );
        }
        final transactions = snapshot.data ?? const [];
        if (transactions.isEmpty) {
          return const AppCard(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('No verified subscription payments yet.'),
            ),
          );
        }
        return AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final (label, color) = switch (transaction.status) {
                PaymentStatus.success => ('Verified', semantic.success),
                PaymentStatus.failed => ('Rejected', semantic.error),
                PaymentStatus.pending => ('Pending', semantic.warning),
              };
              final isBank = transaction.provider == 'manual_bank';
              final isManualMtn = transaction.provider == 'manual_mtn';
              final providerLabel = isBank
                  ? 'Centenary Bank'
                  : isManualMtn
                  ? 'MTN Mobile Money'
                  : transaction.provider.replaceAll('_', ' ').toUpperCase();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(
                    isBank
                        ? Icons.account_balance_rounded
                        : Icons.phone_android_rounded,
                    color: color,
                    size: 18,
                  ),
                ),
                title: Text(providerLabel),
                subtitle: Text(
                  [
                    DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(transaction.createdAt),
                    if ((transaction.reference ?? '').isNotEmpty)
                      'Ref: ${transaction.reference}',
                  ].join('  •  '),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      CurrencyFormatter.ugx(transaction.amountUgx.toDouble()),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    StatusBadge(label: label, color: color),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openPaymentPortal() async {
    setState(() => _openingPortal = true);
    try {
      final opened = await launchUrl(
        _paymentPortal,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the payment portal. Visit schoolpulse.victorbee.com/payment.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingPortal = false);
    }
  }
}

class _PaymentMethodLine extends StatelessWidget {
  const _PaymentMethodLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
