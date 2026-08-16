import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus {
  draft,
  trial,
  pendingActivation,
  active,
  renewalDue,
  gracePeriod,
  paymentPending,
  restricted,
  suspended,
  cancelled,
  expired,
  archived,
  none,
}

enum UsageStatus {
  normal,
  approachingLimit,
  softLimitReached,
  hardLimitReached,
  unlimited,
  unavailable,
  needsRecalculation,
}

class Subscription {
  final String id;
  final String planId;
  final String plan;
  final SubscriptionStatus status;
  final DateTime? renewalDate;
  final int amountUgx;
  final String currency;
  final String billingCycle;
  final bool autoRenewalEnabled;
  final DateTime? startDate;
  final DateTime? graceEndsAt;
  final DateTime? cancelledAt;
  final String renewalMode;
  final String paymentStatus;
  final String supportLevel;
  final List<String> modules;
  final List<String> addOns;

  const Subscription({
    this.id = 'current',
    this.planId = '',
    required this.plan,
    required this.status,
    required this.renewalDate,
    required this.amountUgx,
    this.currency = 'UGX',
    this.billingCycle = '',
    this.autoRenewalEnabled = false,
    this.startDate,
    this.graceEndsAt,
    this.cancelledAt,
    this.renewalMode = '',
    this.paymentStatus = '',
    this.supportLevel = '',
    this.modules = const [],
    this.addOns = const [],
  });

  int? get daysRemaining => renewalDate?.difference(DateTime.now()).inDays;

  factory Subscription.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return const Subscription(
        plan: 'No Plan',
        status: SubscriptionStatus.none,
        renewalDate: null,
        amountUgx: 0,
      );
    }
    return Subscription(
      plan:
          data['planNameSnapshot']?.toString() ??
          data['plan']?.toString() ??
          'Basic',
      id: data['subscriptionId']?.toString() ?? 'current',
      planId: data['planId']?.toString() ?? '',
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == _statusName(data['status']),
        orElse: () => SubscriptionStatus.none,
      ),
      renewalDate: _date(data['renewalDate']),
      amountUgx:
          ((data['basePriceSnapshot'] ??
                      data['amountUgx'] ??
                      data['amount'] ??
                      0)
                  as num)
              .round(),
      currency: data['currency']?.toString() ?? 'UGX',
      billingCycle: data['billingCycle']?.toString() ?? '',
      autoRenewalEnabled: data['autoRenewalEnabled'] == true,
      startDate: _date(data['startDate']),
      graceEndsAt: _date(data['graceEndsAt']),
      cancelledAt: _date(data['cancelledAt']),
      renewalMode: data['renewalMode']?.toString() ?? '',
      paymentStatus: data['paymentStatus']?.toString() ?? '',
      supportLevel: data['supportLevel']?.toString() ?? '',
      modules: _strings(data['includedModules'] ?? data['entitlements']),
      addOns: _strings(data['activeAddOns']),
    );
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return value is String ? DateTime.tryParse(value) : null;
  }

  static String _statusName(Object? value) =>
      value?.toString().replaceAllMapped(
        RegExp(r'[_ -](.)'),
        (m) => (m[1] ?? '').toUpperCase(),
      ) ??
      'none';
  static List<String> _strings(Object? value) =>
      value is Iterable ? value.map((e) => e.toString()).toList() : const [];
}

class UsageMetric {
  const UsageMetric({
    required this.key,
    required this.currentValue,
    this.limitValue,
    this.unit = '',
    this.status = UsageStatus.unavailable,
    this.softLimit,
    this.hardLimit,
    this.currentPeriodEnd,
  });
  final String key;
  final double currentValue;
  final double? limitValue;
  final String unit;
  final UsageStatus status;
  final double? softLimit;
  final double? hardLimit;
  final DateTime? currentPeriodEnd;
  bool get isUnlimited =>
      status == UsageStatus.unlimited || limitValue == null || limitValue! <= 0;
  double get fraction =>
      isUnlimited ? 0 : (currentValue / limitValue!).clamp(0, 1);
  factory UsageMetric.fromFirestore(String key, Map<String, dynamic> data) =>
      UsageMetric(
        key: data['usageMetricKey']?.toString() ?? key,
        currentValue: (data['currentValue'] as num?)?.toDouble() ?? 0,
        limitValue: (data['limitValue'] as num?)?.toDouble(),
        unit: data['unit']?.toString() ?? '',
        softLimit: (data['softLimit'] as num?)?.toDouble(),
        hardLimit: (data['hardLimit'] as num?)?.toDouble(),
        currentPeriodEnd: Subscription._date(data['currentPeriodEnd']),
        status: UsageStatus.values.firstWhere(
          (v) => v.name == data['status']?.toString(),
          orElse: () => UsageStatus.normal,
        ),
      );
}
