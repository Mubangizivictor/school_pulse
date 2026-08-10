import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/payment_transaction.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  SubscriptionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const Subscription _empty = Subscription(
    plan: 'School Pulse Plan',
    status: SubscriptionStatus.none,
    renewalDate: null,
    amountUgx: 0,
  );

  /// Reads subscription authority from the tenant's `schools/{schoolId}`
  /// record. The former global `subscription/current` document was not safe
  /// for a multi-tenant SaaS and is intentionally no longer used.
  Stream<Subscription> watchSubscription() async* {
    final schoolId = await _currentSchoolId();
    if (schoolId == null) {
      yield _empty;
      return;
    }

    await for (final schoolDoc
        in _firestore.collection('schools').doc(schoolId).snapshots()) {
      final school = schoolDoc.data();
      if (school == null) {
        yield _empty;
        continue;
      }

      final planId = school['subscriptionPlanId']?.toString() ?? '';
      Map<String, dynamic>? plan;
      if (planId.isNotEmpty) {
        final planDoc =
            await _firestore.collection('subscription_plans').doc(planId).get();
        plan = planDoc.data();
      }

      final expiry = _dateFromValue(school['subscriptionExpiry']);
      final metadata = school['metadata'] is Map
          ? Map<String, dynamic>.from(school['metadata'] as Map)
          : const <String, dynamic>{};
      final subscriptionStatus =
          metadata['subscriptionStatus']?.toString() ?? 'active';
      final hasEverActivated = metadata['hasEverActivated'] == true;
      final now = DateTime.now();

      final status = !hasEverActivated
          ? SubscriptionStatus.none
          : (subscriptionStatus == 'payment_review' ||
                  subscriptionStatus == 'payment_due')
              ? SubscriptionStatus.gracePeriod
              : (expiry != null && !expiry.isAfter(now))
                  ? SubscriptionStatus.expired
                  : SubscriptionStatus.active;

      yield Subscription(
        plan: plan?['name']?.toString() ??
            school['subscriptionPlanId']?.toString() ??
            'School Pulse Plan',
        status: status,
        renewalDate: expiry,
        amountUgx: (plan?['price'] as num?)?.round() ?? 0,
      );
    }
  }

  /// Payment history is explicitly tenant-scoped. The earlier repository
  /// watched the platform-wide collection and could mix schools in the same
  /// list, which is not acceptable for a multi-tenant billing screen.
  Stream<List<PaymentTransaction>> watchRecentTransactions() async* {
    final schoolId = await _currentSchoolId();
    if (schoolId == null) {
      yield const [];
      return;
    }

    await for (final snapshot in _firestore
        .collection('payment_transactions')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()) {
      final transactions =
          snapshot.docs.map(PaymentTransaction.fromFirestore).toList();
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield transactions.take(10).toList(growable: false);
    }
  }

  Future<String?> _currentSchoolId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final schoolId = userDoc.data()?['schoolId']?.toString().trim();
    return schoolId == null || schoolId.isEmpty ? null : schoolId;
  }

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.round());
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
