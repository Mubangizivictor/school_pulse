import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/payment_transaction.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  SubscriptionRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const Subscription _empty = Subscription(
    plan: 'School Pulse Plan',
    status: SubscriptionStatus.none,
    renewalDate: null,
    amountUgx: 0,
  );

  /// Canonical subscription is tenant-scoped. Legacy school fields are only a
  /// read-only fallback while older tenants are migrated by the platform.
  Stream<Subscription> watchSubscription() async* {
    final schoolId = await _currentSchoolId();
    if (schoolId == null) {
      yield _empty;
      return;
    }

    await for (final current
        in _firestore
            .collection('institutions')
            .doc(schoolId)
            .collection('subscription')
            .doc('current')
            .snapshots()) {
      if (current.exists && current.data() != null) {
        yield Subscription.fromFirestore(current.data());
        continue;
      }
      final schoolDoc = await _firestore
          .collection('schools')
          .doc(schoolId)
          .get();
      final school = schoolDoc.data();
      if (school == null) {
        yield _empty;
        continue;
      }

      final planId = school['subscriptionPlanId']?.toString() ?? '';
      Map<String, dynamic>? plan;
      if (planId.isNotEmpty) {
        final planDoc = await _firestore
            .collection('subscription_plans')
            .doc(planId)
            .get();
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
        planId: planId,
        plan:
            plan?['name']?.toString() ??
            school['subscriptionPlanId']?.toString() ??
            'School Pulse Plan',
        status: status,
        renewalDate: expiry,
        amountUgx: (plan?['price'] as num?)?.round() ?? 0,
        currency: plan?['currency']?.toString() ?? 'UGX',
        billingCycle: plan?['billingCycle']?.toString() ?? '',
        modules: (plan?['includedFeatures'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
    }
  }

  Stream<List<UsageMetric>> watchUsage() async* {
    final schoolId = await _currentSchoolId();
    if (schoolId == null) {
      yield const [];
      return;
    }
    yield* _firestore
        .collection('institutions')
        .doc(schoolId)
        .collection('usage_metrics')
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => UsageMetric.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> watchDocuments(String collection) async* {
    final schoolId = await _currentSchoolId();
    if (schoolId == null) {
      yield const [];
      return;
    }
    yield* _firestore
        .collection('institutions')
        .doc(schoolId)
        .collection(collection)
        .snapshots()
        .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> watchAvailablePlans() => _firestore
      .collection('subscription_plans')
      .where('isPublic', isEqualTo: true)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());

  Stream<List<Map<String, dynamic>>> watchAvailableAddOns() => _firestore
      .collection('subscription_addons')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());

  Future<void> requestChange({
    required String type,
    String? planId,
    String? addOnId,
    String note = '',
  }) async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).httpsCallable('requestSubscriptionChange');
    await callable.call({
      'type': type,
      ...?(planId == null ? null : {'planId': planId}),
      ...?(addOnId == null ? null : {'addOnId': addOnId}),
      'note': note,
    });
  }

  Future<void> requestUsageRefresh() async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).httpsCallable('requestSubscriptionUsageRefresh');
    await callable.call();
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

    await for (final snapshot
        in _firestore
            .collection('payment_transactions')
            .where('schoolId', isEqualTo: schoolId)
            .snapshots()) {
      final transactions = snapshot.docs
          .map(PaymentTransaction.fromFirestore)
          .toList();
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
