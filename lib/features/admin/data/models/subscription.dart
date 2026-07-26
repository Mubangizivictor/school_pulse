import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus { active, expired, gracePeriod, none }

class Subscription {
  final String plan;
  final SubscriptionStatus status;
  final DateTime? renewalDate;
  final int amountUgx;

  const Subscription({
    required this.plan,
    required this.status,
    required this.renewalDate,
    required this.amountUgx,
  });

  factory Subscription.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return const Subscription(plan: 'No Plan', status: SubscriptionStatus.none, renewalDate: null, amountUgx: 0);
    }
    return Subscription(
      plan: data['plan'] ?? 'Basic',
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'none'),
        orElse: () => SubscriptionStatus.none,
      ),
      renewalDate: (data['renewalDate'] as Timestamp?)?.toDate(),
      amountUgx: (data['amountUgx'] ?? 0) as int,
    );
  }
}
