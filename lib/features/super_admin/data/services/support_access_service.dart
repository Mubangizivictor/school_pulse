import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// A single owner-initiated support access session, read from
/// `institutions/{schoolId}/support_access_requests` (owner-readable per
/// firestore.rules once created; the collection otherwise denies client
/// writes entirely). Requesting and deciding a session both go through
/// owner-only callables - the client never writes this collection directly.
class SupportAccessRequest {
  const SupportAccessRequest({
    required this.id,
    required this.schoolId,
    required this.status,
    required this.reason,
    required this.requestedByPlatformUser,
    this.expiresAt,
    this.createdAt,
  });

  final String id;
  final String schoolId;

  /// One of: pending, active, rejected, revoked, expired.
  final String status;
  final String reason;
  final String requestedByPlatformUser;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  bool get isActive =>
      status == 'active' &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  factory SupportAccessRequest.fromDoc(String id, Map<String, dynamic> data) {
    DateTime? date(Object? v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v?.toString() ?? '');
    }

    return SupportAccessRequest(
      id: id,
      schoolId: (data['institutionId'] ?? '').toString(),
      status: (data['status'] ?? 'pending').toString(),
      reason: (data['reason'] ?? '').toString(),
      requestedByPlatformUser: (data['requestedByPlatformUser'] ?? '')
          .toString(),
      expiresAt: date(data['expiresAt']),
      createdAt: date(data['createdAt']),
    );
  }
}

/// Owner-console boundary around support-access sessions. Requesting a
/// session calls `requestSupportAccess` (public_functions/portal_domains.js),
/// which writes the request and its audit entry inside the Admin SDK - this
/// service never writes the collection directly, matching every other
/// school-lifecycle action in this feature.
class SupportAccessService {
  SupportAccessService({FirebaseFirestore? firestore, FirebaseFunctions? functions})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<SupportAccessRequest>> watchRequests(String schoolId) {
    return _firestore
        .collection('institutions/$schoolId/support_access_requests')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportAccessRequest.fromDoc(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Future<void> request({required String schoolId, required String reason}) async {
    await _functions.httpsCallable('requestSupportAccess').call({
      'schoolId': schoolId,
      'reason': reason.trim(),
    });
  }
}
