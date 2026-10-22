import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';
import 'package:school_pulse/features/super_admin/data/models/subscription_cycle_model.dart';

/// Non-terminal cycle statuses used to filter "upcoming renewals" queries.
/// Kept close to the query that uses it rather than on the entity, since
/// it's a query concern (what counts as "still needs attention"), not a
/// property of the enum itself.
const List<String> kActiveSubscriptionCycleStatuses = [
  'upcoming',
  'invoiced',
  'paymentPending',
  'gracePeriod',
  'overdue',
];

/// Shared read-only access to the `subscription_cycles` collection.
///
/// Lives under `billing/` (not `super_admin/` or `structure/`) specifically
/// so both the School Admin academic-calendar screen and the Super Admin
/// billing screens can depend on it without either feature depending on the
/// other - `structure` must not import from `super_admin`, and vice versa
/// isn't clean either since this data source is genuinely cross-cutting
/// (super_admin sees all schools, school-admin sees only its own).
///
/// Read-only: `firestore.rules` already declares `write: false` on
/// `subscription_cycles/{id}` - every doc is written by Cloud Functions
/// only (functions/academic_calendar_billing.js,
/// public_functions/subscription_cycle_billing.js). No writes are added
/// here.
class SubscriptionCycleRemoteDataSource {
  SubscriptionCycleRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// All cycles for one school, oldest term first. Used by both the School
  /// Admin calendar screen (scoped to its own school) and the Super Admin
  /// School Details "Term cycle history" section.
  Future<List<SubscriptionCycle>> getSubscriptionCyclesForSchool(
    String schoolId,
  ) async {
    final snapshot = await _firestore
        .collection('subscription_cycles')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('termStart')
        .get();
    return snapshot.docs
        .map((doc) => SubscriptionCycleModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Cross-school "upcoming renewals" feed for the Super Admin Billing home
  /// screen. Limited to 50 - this section is a compact preview, not a full
  /// report; a school-admin never needs this cross-tenant view. The limit
  /// keeps the read bounded regardless of platform size instead of scaling
  /// unbounded with school count, at the cost of only ever showing the
  /// earliest 50 by termStart when there are more than 50 active cycles
  /// platform-wide - acceptable since this is a preview, and the full
  /// Subscriptions Overview / School Details screens remain the source of
  /// truth for a specific school.
  Future<List<SubscriptionCycle>> getAllUpcomingSubscriptionCycles() async {
    final snapshot = await _firestore
        .collection('subscription_cycles')
        .where('cycleStatus', whereIn: kActiveSubscriptionCycleStatuses)
        .orderBy('termStart')
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => SubscriptionCycleModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
