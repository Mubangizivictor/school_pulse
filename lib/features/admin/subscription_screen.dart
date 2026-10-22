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
                      'Subscription status',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'All School Pulse features are included for this school.',
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
        UsageStatus.approachingLimit => Colors.black,
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
