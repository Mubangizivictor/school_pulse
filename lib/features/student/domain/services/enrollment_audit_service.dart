import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Thin client for the `recordEnrollmentAuditEvent` callable
/// (functions/enrollment_audit.js). Deliberately fire-and-forget/best-
/// effort from every call site: an audit-log write failing must never
/// block or roll back the underlying admission/enrollment action it is
/// describing - the action itself already succeeded (or was already
/// permission-checked) by the time this is called.
///
/// Mirrors the server's trust model on this side too: this service never
/// accepts or sends a client-chosen actor id or timestamp - only
/// `schoolId`/`studentId`/`applicationId`/`action`/`reason`/`metadata` ever
/// leave the client; `context.auth` and `serverTimestamp()` on the
/// function side are the only source of truth for who/when.
class EnrollmentAuditService {
  final FirebaseFunctions functions;

  EnrollmentAuditService(this.functions);

  Future<void> record({
    required String schoolId,
    required String action,
    String? studentId,
    String? applicationId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final callable = functions.httpsCallable('recordEnrollmentAuditEvent');
      await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'action': action,
        if (studentId != null) 'studentId': studentId,
        if (applicationId != null) 'applicationId': applicationId,
        if (reason != null) 'reason': reason,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (e, st) {
      // Best-effort: never let an audit-trail failure surface as a user-
      // facing error for the action it's describing.
      debugPrint('EnrollmentAuditService.record failed for $action: $e\n$st');
    }
  }

  /// Records that a student's School ID or QR credential was previewed or
  /// printed - the one Identity tab credential action with no natural Cloud
  /// Function to hook into, since viewing/printing a PDF is a pure
  /// client-side render with no server state change alongside it. [kind] is
  /// 'school_id' or 'qr'.
  Future<void> recordIdentityPreview({
    required String schoolId,
    required String studentId,
    required String kind,
  }) {
    return record(
      schoolId: schoolId,
      action: 'identity_school_id_previewed',
      studentId: studentId,
      metadata: {'kind': kind},
    );
  }
}
