import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// A single custom portal-domain request, read from `portal_domain_requests`
/// (owner-readable per firestore.rules). All state transitions - verify,
/// recheck, activate, reject - go through owner-only callables in
/// `public_functions/portal_domains.js`; the client never writes this
/// collection.
class CustomDomainRequest {
  const CustomDomainRequest({
    required this.hostname,
    required this.schoolId,
    required this.status,
    required this.cnameTarget,
    this.lastError,
    this.checkedAt,
    this.requestedAt,
    this.rejectionReason,
  });

  final String hostname;
  final String schoolId;

  /// One of: pending, verified, active, verification_failed, rejected.
  final String status;
  final String cnameTarget;
  final String? lastError;
  final DateTime? checkedAt;
  final DateTime? requestedAt;
  final String? rejectionReason;

  bool get isActive => status == 'active';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
  bool get isFailed => status == 'verification_failed';
  bool get isPending => status == 'pending';

  /// Activation is only offered once a recheck has moved the request to
  /// `verified` (or it is already active).
  bool get canActivate => isVerified;

  factory CustomDomainRequest.fromDoc(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime? date(Object? v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v?.toString() ?? '');
    }

    return CustomDomainRequest(
      hostname: (data['hostname'] ?? id).toString(),
      schoolId: (data['schoolId'] ?? '').toString(),
      status: (data['status'] ?? 'pending').toString(),
      cnameTarget: (data['cnameTarget'] ?? '').toString(),
      lastError: data['lastError']?.toString(),
      checkedAt: date(data['checkedAt']),
      requestedAt: date(data['requestedAt']),
      rejectionReason: data['rejectionReason']?.toString(),
    );
  }
}

class CustomDomainService {
  CustomDomainService({FirebaseFirestore? firestore, FirebaseFunctions? functions})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<CustomDomainRequest>> watchRequests() {
    return _firestore
        .collection('portal_domain_requests')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomDomainRequest.fromDoc(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  /// Re-runs the CNAME check without activating - moves a failed/pending
  /// request to `verified` or `verification_failed`.
  Future<void> recheck(String hostname) async {
    await _functions
        .httpsCallable('recheckCustomPortalDomain')
        .call({'hostname': hostname});
  }

  /// Verifies DNS and activates the domain in one call. Only meaningful once
  /// [CustomDomainRequest.canActivate] is true.
  Future<void> activate(String hostname) async {
    await _functions
        .httpsCallable('verifyAndActivateCustomPortalDomain')
        .call({'hostname': hostname});
  }

  Future<void> reject(String hostname, String reason) async {
    await _functions
        .httpsCallable('rejectCustomPortalDomain')
        .call({'hostname': hostname, 'reason': reason.trim()});
  }
}
