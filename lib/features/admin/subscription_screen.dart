import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/data/models/subscription.dart';
import 'package:school_pulse/features/admin/data/repositories/subscription_repository.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/subscription_payment/presentation/screens/mtn_momo_payment_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});
  SubscriptionRepository get _repository => di.sl<SubscriptionRepository>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AdminAppBar(title: 'Subscription Center'),
    body: StreamBuilder<Subscription>(
      stream: _repository.watchSubscription(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: SchoolPulseLoader());
        final sub = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summary(context, sub),
            const SizedBox(height: 16),
            _usage(context),
            const SizedBox(height: 16),
            _details(context, sub),
            const SizedBox(height: 16),
            _marketplace(context, sub),
            const SizedBox(height: 16),
            _documents(context),
            const SizedBox(height: 16),
            _history(context),
          ],
        );
      },
    ),
  );

  Widget _summary(BuildContext context, Subscription sub) {
    final theme = Theme.of(context);
    final warning = _isAttention(sub.status);
    final date = sub.renewalDate == null
        ? 'Not available'
        : DateFormat('MMM d, y').format(sub.renewalDate!);
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.plan,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub.billingCycle.isEmpty
                          ? 'Billing cycle unavailable'
                          : '${_label(sub.billingCycle)} billing',
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: _label(sub.status.name),
                color: warning
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 28,
            runSpacing: 12,
            children: [
              _fact('Renewal', date),
              _fact(
                'Amount',
                sub.amountUgx > 0
                    ? '${sub.currency} ${NumberFormat.decimalPattern().format(sub.amountUgx)}'
                    : 'Contact billing',
              ),
              _fact(
                'Auto-renewal',
                sub.autoRenewalEnabled ? 'Enabled' : 'Manual',
              ),
              if (sub.daysRemaining != null)
                _fact(
                  'Time remaining',
                  '${sub.daysRemaining!.clamp(0, 9999)} days',
                ),
            ],
          ),
          if (sub.status == SubscriptionStatus.gracePeriod ||
              sub.status == SubscriptionStatus.suspended ||
              sub.status == SubscriptionStatus.restricted) ...[
            const SizedBox(height: 14),
            Text(
              _restrictionCopy(sub),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PrimaryButton(
                label: 'Pay / Renew',
                icon: Icons.payments_outlined,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MtnMomoPaymentScreen(),
                  ),
                ),
              ),
              SecondaryButton(
                label: 'Compare plans',
                icon: Icons.upgrade_outlined,
                onPressed: () => _choosePlan(context, sub),
              ),
              SecondaryButton(
                label: 'Contact billing',
                icon: Icons.support_agent_outlined,
                onPressed: () => _request(context, 'support'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _usage(BuildContext context) => StreamBuilder<List<UsageMetric>>(
    stream: _repository.watchUsage(),
    builder: (context, s) {
      if (!s.hasData) return const SizedBox.shrink();
      final metrics = s.data!;
      return AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan usage',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              metrics.isEmpty
                  ? 'Usage snapshots are not available yet. Ask billing to refresh the institution usage summary.'
                  : 'Usage is calculated by School Pulse; it cannot be reset here.',
            ),
            ...metrics.map(
              (m) => Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _label(m.key),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          m.isUnlimited
                              ? '${_number(m.currentValue)} ${m.unit} · Unlimited'
                              : '${_number(m.currentValue)} / ${_number(m.limitValue!)} ${m.unit}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: m.fraction,
                      color: _usageColor(context, m),
                    ),
                    if (m.status != UsageStatus.normal && !m.isUnlimited)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _usageMessage(m),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (metrics.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _refreshUsage(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Request usage refresh'),
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _details(BuildContext context, Subscription sub) => AppCard(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plan & entitlements',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        const SizedBox(height: 10),
        if (sub.modules.isEmpty)
          const Text(
            'Plan entitlements have not been published for this institution.',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sub.modules.map((e) => Chip(label: Text(e))).toList(),
          ),
        const SizedBox(height: 14),
        Text('Active add-ons', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        if (sub.addOns.isEmpty)
          const Text('No active add-ons.')
        else
          Wrap(
            spacing: 8,
            children: sub.addOns.map((e) => Chip(label: Text(e))).toList(),
          ),
        const SizedBox(height: 10),
        Text(
          'Entitlements are assigned by School Pulse. Local module settings cannot enable a module that is not entitled.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );

  Widget _marketplace(BuildContext context, Subscription sub) => AppCard(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plans & add-ons',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        const SizedBox(height: 6),
        const Text(
          'Prices, availability and activation are controlled by School Pulse billing.',
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _repository.watchAvailableAddOns(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            if (snapshot.data!.isEmpty) {
              return const Text(
                'No add-ons are currently available for request.',
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: snapshot.data!.map((addOn) {
                final name =
                    addOn['name']?.toString() ?? addOn['id'].toString();
                final active = sub.addOns.any(
                  (value) => value.toLowerCase() == name.toLowerCase(),
                );
                return ActionChip(
                  avatar: Icon(
                    active ? Icons.check_circle : Icons.add_circle_outline,
                    size: 18,
                  ),
                  label: Text(active ? '$name · Active' : name),
                  onPressed: active
                      ? null
                      : () => _confirmAddOn(context, addOn),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );

  Widget _documents(
    BuildContext context,
  ) => StreamBuilder<List<Map<String, dynamic>>>(
    stream: _repository.watchDocuments('saas_invoices'),
    builder: (context, s) => AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoices & receipts',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 8),
          if (!s.hasData)
            const SchoolPulseLoader()
          else if (s.data!.isEmpty)
            const Text('No SaaS invoices are available.')
          else
            ...s.data!
                .take(5)
                .map(
                  (d) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(
                      d['invoiceNumber']?.toString() ?? d['id'].toString(),
                    ),
                    subtitle: Text(_label(d['status']?.toString() ?? 'issued')),
                    trailing: Text(
                      '${d['currency'] ?? ''} ${d['amount'] ?? ''}',
                    ),
                  ),
                ),
          Text(
            'Receipts are issued only after payment confirmation. Download links, where provided by School Pulse, remain read-only.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _repository.watchDocuments('saas_receipts'),
            builder: (context, receipts) {
              if (!receipts.hasData || receipts.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Confirmed receipts',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  ...receipts.data!
                      .take(5)
                      .map(
                        (receipt) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.verified_outlined),
                          title: Text(
                            receipt['receiptNumber']?.toString() ??
                                receipt['id'].toString(),
                          ),
                          subtitle: Text(
                            receipt['paymentMethod']?.toString() ??
                                'Confirmed payment',
                          ),
                          trailing: Text(
                            '${receipt['currency'] ?? ''} ${receipt['amount'] ?? ''}',
                          ),
                        ),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );

  Widget _history(BuildContext context) =>
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.watchDocuments('subscription_history'),
        builder: (context, s) => AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subscription history',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const SizedBox(height: 8),
              if (!s.hasData)
                const SchoolPulseLoader()
              else if (s.data!.isEmpty)
                const Text('No subscription events are available.')
              else
                ...s.data!
                    .take(8)
                    .map(
                      (d) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history),
                        title: Text(
                          _label(
                            d['eventType']?.toString() ??
                                d['action']?.toString() ??
                                'Subscription update',
                          ),
                        ),
                        subtitle: Text(_date(d['createdAt'] ?? d['timestamp'])),
                      ),
                    ),
            ],
          ),
        ),
      );

  Future<void> _request(BuildContext context, String type) async {
    try {
      await _repository.requestChange(type: type);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your request was sent to School Pulse billing.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to send the request. Please try again online.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _refreshUsage(BuildContext context) async {
    try {
      await _repository.requestUsageRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usage refresh requested from School Pulse.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usage refresh could not be requested.'),
          ),
        );
      }
    }
  }

  Future<void> _confirmAddOn(
    BuildContext context,
    Map<String, dynamic> addOn,
  ) async {
    final name = addOn['name']?.toString() ?? addOn['id'].toString();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Request $name?'),
        content: Text(
          '${addOn['description'] ?? 'School Pulse will review availability, price and terms before activation.'}\n\nThis request does not activate the add-on.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Send request'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    try {
      await _repository.requestChange(
        type: 'addon',
        addOnId: addOn['id'].toString(),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add-on request sent to School Pulse billing.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to send the add-on request.')),
        );
      }
    }
  }

  Future<void> _choosePlan(BuildContext context, Subscription current) async {
    try {
      final plans = await _repository.watchAvailablePlans().first;
      if (!context.mounted) return;
      final selected = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text('Available plans'),
                subtitle: Text('Plan changes require School Pulse approval.'),
              ),
              ...plans.map((plan) {
                final isCurrent = plan['id']?.toString() == current.planId;
                return ListTile(
                  title: Text(
                    plan['name']?.toString() ?? plan['id'].toString(),
                  ),
                  subtitle: Text(
                    '${_label(plan['billingCycle']?.toString() ?? '')} · ${plan['currency'] ?? ''} ${plan['price'] ?? 'Contact billing'}',
                  ),
                  trailing: isCurrent
                      ? const Chip(label: Text('Current'))
                      : const Icon(Icons.chevron_right),
                  onTap: isCurrent
                      ? null
                      : () => Navigator.pop(sheetContext, plan),
                );
              }),
            ],
          ),
        ),
      );
      if (selected == null || !context.mounted) return;
      final price = selected['price'];
      final isDowngrade =
          price is num && current.amountUgx > 0 && price < current.amountUgx;
      await _repository.requestChange(
        type: isDowngrade ? 'downgrade' : 'upgrade',
        planId: selected['id'].toString(),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan-change request sent to School Pulse billing.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Plans are unavailable right now. Please try again online.',
            ),
          ),
        );
      }
    }
  }

  static Widget _fact(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
  static bool _isAttention(SubscriptionStatus s) =>
      ![SubscriptionStatus.active, SubscriptionStatus.trial].contains(s);
  static String _restrictionCopy(Subscription s) =>
      s.status == SubscriptionStatus.gracePeriod
      ? 'Your grace period ends ${s.graceEndsAt == null ? 'soon' : DateFormat('MMM d').format(s.graceEndsAt!)}. Renew to avoid restrictions.'
      : 'Some services may be restricted. Your data remains intact; contact billing for help.';
  static String _number(num n) => NumberFormat.compact().format(n);
  static Color? _usageColor(BuildContext context, UsageMetric metric) =>
      switch (metric.status) {
        UsageStatus.hardLimitReached => Theme.of(context).colorScheme.error,
        UsageStatus.softLimitReached ||
        UsageStatus.approachingLimit => Colors.orange,
        _ => null,
      };
  static String _usageMessage(UsageMetric metric) => switch (metric.status) {
    UsageStatus.approachingLimit =>
      'Approaching your plan limit. Consider an upgrade or capacity add-on.',
    UsageStatus.softLimitReached =>
      'Soft limit reached. Service remains available unless School Pulse policy changes.',
    UsageStatus.hardLimitReached =>
      'Hard limit reached. New usage may be blocked; existing data is preserved.',
    UsageStatus.needsRecalculation =>
      'Usage is being recalculated by School Pulse.',
    _ => _label(metric.status.name),
  };
  static String _date(Object? value) => value is DateTime
      ? DateFormat('MMM d, y').format(value)
      : 'Recorded by School Pulse';
  static String _label(String s) => s
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])|[_-]'),
        (m) => m.group(1) != null ? '${m.group(1)} ${m.group(2)}' : ' ',
      )
      .trim()
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
