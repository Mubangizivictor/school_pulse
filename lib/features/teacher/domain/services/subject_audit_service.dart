import '../entities/active_responsibility_context.dart';

/// Records what a teacher did, under which responsibility, to what.
///
/// Auditing is not optional decoration here: marks and attendance are records
/// a student can be held to years later, so every change carries who made it,
/// what it was before, and why. The service stamps the academic coordinates
/// from the active context automatically, which is what stops a caller from
/// logging an action against a scope it was not performed in.
abstract class SubjectAuditService {
  /// Writes one audit row. Never throws: an audit write that fails must not
  /// roll back the teacher's work, so failures are queued for replay and the
  /// action itself is allowed to stand.
  Future<void> record({
    required ActiveResponsibilityContext context,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    String? reason,
    String? offlineOperationId,
  });

  /// Pushes any audit rows that were recorded while offline.
  Future<void> flushPending();
}
