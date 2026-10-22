import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// A school's request to change its platform subdomain (`<slug>.ROOT`),
/// read from `portal_subdomain_change_requests` (owner-readable per
/// firestore.rules). Approval/rejection go through owner-only callables in
/// `public_functions/portal_domains.js`; the client never writes this
/// collection. Distinct from [CustomDomainRequest]: this is the platform
/// subdomain itself, not a school-owned external vanity domain.
class PortalSubdomainChangeRequest {
  const PortalSubdomainChangeRequest({
    required this.schoolId,
    required this.currentSlug,
    required this.requestedSlug,
    required this.status,
    this.requestedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String schoolId;
  final String? currentSlug;
  final String requestedSlug;

  /// One of: pending, approved, rejected.
  final String status;
  final DateTime? requestedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory PortalSubdomainChangeRequest.fromDoc(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime? date(Object? v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v?.toString() ?? '');
    }

    return PortalSubdomainChangeRequest(
      schoolId: (data['schoolId'] ?? id).toString(),
      currentSlug: data['currentSlug']?.toString(),
      requestedSlug: (data['requestedSlug'] ?? '').toString(),
      status: (data['status'] ?? 'pending').toString(),
      requestedAt: date(data['requestedAt']),
      reviewedAt: date(data['reviewedAt']),
      rejectionReason: data['rejectionReason']?.toString(),
    );
  }
}

class PortalSubdomainChangeService {
  PortalSubdomainChangeService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Super Admin: watch every subdomain-change request across all schools.
  Stream<List<PortalSubdomainChangeRequest>> watchRequests() {
    return _firestore
        .collection('portal_subdomain_change_requests')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    PortalSubdomainChangeRequest.fromDoc(doc.id, doc.data()),
              )
              .toList(growable: false),
        );
  }

  /// School Admin: watch this school's own pending/latest request, if any.
  Stream<PortalSubdomainChangeRequest?> watchForSchool(String schoolId) {
    return _firestore
        .doc('portal_subdomain_change_requests/$schoolId')
        .snapshots()
        .map(
          (doc) => doc.exists
              ? PortalSubdomainChangeRequest.fromDoc(doc.id, doc.data()!)
              : null,
        );
  }

  /// School Admin: check whether a slug is free before submitting.
  Future<bool> checkAvailability(String slug) async {
    final result = await _functions
        .httpsCallable('checkPortalSlug')
        .call({'slug': slug.trim().toLowerCase()});
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['available'] == true;
  }

  /// School Admin: submit a request to change this school's subdomain.
  Future<void> requestChange(String slug) async {
    await _functions
        .httpsCallable('requestPortalSubdomainChange')
        .call({'slug': slug.trim().toLowerCase()});
  }

  Future<void> approve(String schoolId) async {
    await _functions
        .httpsCallable('approvePortalSubdomainChange')
        .call({'schoolId': schoolId});
  }

  Future<void> reject(String schoolId, String reason) async {
    await _functions
        .httpsCallable('rejectPortalSubdomainChange')
        .call({'schoolId': schoolId, 'reason': reason.trim()});
  }
}
