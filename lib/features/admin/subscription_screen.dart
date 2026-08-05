import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/data/models/payment_transaction.dart';
import 'package:school_pulse/features/admin/data/models/subscription.dart';
import 'package:school_pulse/features/admin/data/repositories/subscription_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _repository = di.sl<SubscriptionRepository>();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(title: const Text('Subscription & Billing')),
      body: StreamBuilder<Subscription>(
        stream: _repository.watchSubscription(),
        builder: (context, subSnapshot) {
          if (subSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final subscription =
              subSnapshot.data ??
              const Subscription(
                plan: 'No Plan',
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
      SubscriptionStatus.gracePeriod => ('Grace Period', semantic.warning),
      SubscriptionStatus.expired => ('Expired', semantic.error),
      SubscriptionStatus.none => (
        'No Active Plan',
        Theme.of(context).colorScheme.outline,
      ),
    };

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sub.plan,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              StatusBadge(label: label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sub.renewalDate != null
                ? 'Renews on ${DateFormat('MMM dd, yyyy').format(sub.renewalDate!)}'
                : 'No upcoming renewal on file',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${CurrencyFormatter.ugx(sub.amountUgx.toDouble())} / month',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Renew Now',
            icon: Icons.phone_android,
            onPressed: () => _showRenewDialog(context, sub),
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
              child: CircularProgressIndicator(),
            ),
          );
        }
        final transactions = snapshot.data ?? const [];
        if (transactions.isEmpty) {
          return const AppCard(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No payments recorded yet.')),
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
              final t = transactions[index];
              final (label, color) = switch (t.status) {
                PaymentStatus.success => ('Success', semantic.success),
                PaymentStatus.failed => ('Failed', semantic.error),
                PaymentStatus.pending => ('Pending', semantic.warning),
              };
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(Icons.phone_android, color: color, size: 18),
                ),
                title: Text('${t.provider.toUpperCase()} • ${t.phoneNumber}'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(t.createdAt),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      CurrencyFormatter.ugx(t.amountUgx.toDouble()),
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

  void _showRenewDialog(BuildContext context, Subscription sub) {
    final phoneController = TextEditingController();
    String provider = 'mtn';
    bool isSubmitting = false;
    String? error;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Renew Subscription'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You will be charged ${CurrencyFormatter.ugx(sub.amountUgx.toDouble())} for the ${sub.plan}.',
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'mtn', label: Text('MTN MoMo')),
                  ButtonSegment(value: 'airtel', label: Text('Airtel Money')),
                ],
                selected: {provider},
                onSelectionChanged: (val) =>
                    setDialogState(() => provider = val.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Money Number',
                  hintText: '07xx xxx xxx',
                  errorText: error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll get a prompt on this phone to approve the payment.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final phone = phoneController.text.trim();
                      if (phone.isEmpty) {
                        setDialogState(() => error = 'Enter a phone number');
                        return;
                      }
                      setDialogState(() {
                        isSubmitting = true;
                        error = null;
                      });
                      try {
                        await _repository.initiateMobileMoneyCharge(
                          provider: provider,
                          phoneNumber: phone,
                          amountUgx: sub.amountUgx,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Payment request sent — approve it on your phone.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSubmitting = false;
                          error = 'Could not start payment: ${e.toString()}';
                        });
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Request Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
