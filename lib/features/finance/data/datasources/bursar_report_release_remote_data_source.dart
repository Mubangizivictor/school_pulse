import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

/// The Bursar's report-release data access.
///
/// Reads eligibility (server-computed, never a client "cleared" flag) via the
/// `getReportCardReleaseEligibility` Cloud Function, and drives every state
/// change through a trusted callable:
///   * structured exceptions: grant / approve / revoke / renew
///   * the legacy flat override: `setReportCardFinancialAccess`
/// Firestore rules deny every client write to a `reportCards` document or a
/// `reportCardReleaseExceptions` document, so the callables are the only path.
class BursarReportReleaseRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  BursarReportReleaseRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

  // ---------------------------------------------------------------------------
  // Filter facets — distinct year / term / class / stream across the school's
  // finalized report cards (staff read is allowed by the Firestore rules).
  // ---------------------------------------------------------------------------

  Future<ReportPeriodFacets> getReportPeriods({
    required String schoolId,
  }) async {
    final snap = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('reportCards')
        .where('isFinalized', isEqualTo: true)
        .get();
    final years = <String>{};
    final terms = <String>{};
    final classes = <String>{};
    final streams = <String>{};
    for (final d in snap.docs) {
      final m = d.data();
      final y = m['academicYearId'] as String?;
      final t = m['termId'] as String?;
      final c = m['classId'] as String?;
      final s = m['streamId'] as String?;
      if (y != null && y.isNotEmpty) years.add(y);
      if (t != null && t.isNotEmpty) terms.add(t);
      if (c != null && c.isNotEmpty) classes.add(c);
      if (s != null && s.isNotEmpty) streams.add(s);
    }
    return ReportPeriodFacets(
      years: years.toList()..sort((a, b) => b.compareTo(a)),
      terms: terms.toList()..sort(),
      classes: classes.toList()..sort(),
      streams: streams.toList()..sort(),
    );
  }

  // ---------------------------------------------------------------------------
  // Eligibility list
  // ---------------------------------------------------------------------------

  Future<ReportReleaseEligibilityResult> getEligibility({
    required String academicYearId,
    required String termId,
    String? classId,
  }) async {
    final callable = functions.httpsCallable('getReportCardReleaseEligibility');
    final res = await callable.call(<String, dynamic>{
      'academicYearId': academicYearId,
      'termId': termId,
      if (classId != null && classId.isNotEmpty) 'classId': classId,
    });
    final data = Map<String, dynamic>.from(res.data as Map);
    final rows = ((data['rows'] as List?) ?? const [])
        .whereType<Map>()
        .map(
          (m) => ReportReleaseEligibilityRow.fromMap(m.cast<String, dynamic>()),
        )
        .toList();
    final policy = FinancialClearancePolicy.fromMap(
      (data['policy'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    return ReportReleaseEligibilityResult(rows: rows, policy: policy);
  }

  Future<ReportCardHistory> getExceptionHistory(String reportCardId) async {
    final callable = functions.httpsCallable('getReportCardExceptionHistory');
    final res = await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
    });
    final data = Map<String, dynamic>.from(res.data as Map);
    return ReportCardHistory(
      reportAudit: ((data['reportAudit'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => ReportAuditEntry.fromMap(m.cast<String, dynamic>()))
          .toList(),
      exceptions: ((data['exceptions'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => ReportReleaseException.fromMap(m.cast<String, dynamic>()))
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Exception lifecycle
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> grantException({
    required String studentId,
    required String academicYearId,
    required String termId,
    required String reasonCode,
    String? reasonNote,
    DateTime? expiresAt,
    required String clientRequestId,
  }) => _call('grantReportCardReleaseException', {
    'studentId': studentId,
    'academicYearId': academicYearId,
    'termId': termId,
    'reasonCode': reasonCode,
    if (reasonNote != null && reasonNote.isNotEmpty) 'reasonNote': reasonNote,
    if (expiresAt != null) 'expiresAt': expiresAt.millisecondsSinceEpoch,
    'clientRequestId': clientRequestId,
  });

  Future<Map<String, dynamic>> approveException({
    required String exceptionId,
    String? note,
  }) => _call('approveReportCardReleaseException', {
    'exceptionId': exceptionId,
    if (note != null && note.isNotEmpty) 'note': note,
  });

  Future<Map<String, dynamic>> revokeException({
    required String exceptionId,
    required String reason,
  }) => _call('revokeReportCardReleaseException', {
    'exceptionId': exceptionId,
    'reason': reason,
  });

  Future<Map<String, dynamic>> renewException({
    required String exceptionId,
    required DateTime newExpiresAt,
    String? reasonNote,
    required String clientRequestId,
  }) => _call('renewReportCardReleaseException', {
    'exceptionId': exceptionId,
    'newExpiresAt': newExpiresAt.millisecondsSinceEpoch,
    if (reasonNote != null && reasonNote.isNotEmpty) 'reasonNote': reasonNote,
    'clientRequestId': clientRequestId,
  });

  // ---------------------------------------------------------------------------
  // Legacy flat Bursar override (fully audited server-side)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> setFinancialAccess({
    required List<String> reportCardIds,
    required String action, // release | hold | revoke
    required String reason,
  }) => _call('setReportCardFinancialAccess', {
    'reportCardIds': reportCardIds,
    'action': action,
    'reason': reason,
  });

  /// Still used by the "Direct override" bulk bar - reads finalized reports
  /// straight from Firestore (staff read is allowed by the rules).
  Future<List<CanonicalReportCard>> getFinalizedReportCards({
    required String schoolId,
    String? classId,
    String? academicYearId,
    String? termId,
  }) async {
    Query<Map<String, dynamic>> query = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('reportCards')
        .where('isFinalized', isEqualTo: true);
    if (classId != null && classId.isNotEmpty) {
      query = query.where('classId', isEqualTo: classId);
    }
    if (academicYearId != null && academicYearId.isNotEmpty) {
      query = query.where('academicYearId', isEqualTo: academicYearId);
    }
    if (termId != null && termId.isNotEmpty) {
      query = query.where('termId', isEqualTo: termId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) => _cardFromMap(d.id, d.data())).toList();
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> payload,
  ) async {
    final res = await functions.httpsCallable(name).call(payload);
    return Map<String, dynamic>.from(res.data as Map);
  }

  CanonicalReportCard _cardFromMap(String id, Map<String, dynamic> data) {
    return CanonicalReportCard(
      reportCardId: id,
      schoolId: data['schoolId'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      average: (data['average'] as num?)?.toDouble(),
      overallGrade: data['overallGrade'] as String?,
      version: (data['version'] as num?)?.toInt() ?? 1,
      sourceHash: data['sourceHash'] as String? ?? '',
      isFinalized: data['isFinalized'] as bool? ?? false,
      academicStatus: AcademicWorkflowStatus.fromId(
        data['academicStatus'] as String?,
      ),
      financialAccessStatus: FinancialAccessStatus.fromId(
        data['financialAccessStatus'] as String?,
      ),
    );
  }
}

class ReportPeriodFacets {
  final List<String> years;
  final List<String> terms;
  final List<String> classes;
  final List<String> streams;
  const ReportPeriodFacets({
    required this.years,
    required this.terms,
    required this.classes,
    required this.streams,
  });
  bool get isEmpty => years.isEmpty && terms.isEmpty;
}

class ReportReleaseEligibilityResult {
  final List<ReportReleaseEligibilityRow> rows;
  final FinancialClearancePolicy policy;
  const ReportReleaseEligibilityResult({
    required this.rows,
    required this.policy,
  });
}

class ReportAuditEntry {
  final String action;
  final String actorName;
  final String? reason;
  final String? source;
  final int? reportVersion;
  final DateTime? at;
  const ReportAuditEntry({
    required this.action,
    required this.actorName,
    this.reason,
    this.source,
    this.reportVersion,
    this.at,
  });
  factory ReportAuditEntry.fromMap(Map<String, dynamic> m) => ReportAuditEntry(
    action: m['action'] as String? ?? '',
    actorName: m['actorName'] as String? ?? 'System',
    reason: m['reason'] as String?,
    source: m['source'] as String?,
    reportVersion: (m['reportVersion'] as num?)?.toInt(),
    at: m['at'] is num
        ? DateTime.fromMillisecondsSinceEpoch((m['at'] as num).toInt())
        : null,
  );
}

class ReportCardHistory {
  final List<ReportAuditEntry> reportAudit;
  final List<ReportReleaseException> exceptions;
  const ReportCardHistory({
    required this.reportAudit,
    required this.exceptions,
  });
}
