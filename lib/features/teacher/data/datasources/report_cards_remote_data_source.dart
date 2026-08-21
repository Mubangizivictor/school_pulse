import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/canonical_report_card.dart';

/// The single shared reader/actor for canonical
/// `schools/{schoolId}/reportCards/{reportCardId}` documents.
///
/// Every role that ever needs to read or act on a report card - Class
/// Teacher, Dean, Headteacher, Bursar, Parent, Student - goes through this
/// one mapping and one set of Cloud Function callables, so there is exactly
/// one place that knows the document's on-the-wire shape. Do not add a
/// second copy of `_fromMap`/`_decisionFromMap`; extend this class instead.
class ReportCardsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  ReportCardsRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

  CollectionReference<Map<String, dynamic>> reportCards(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('reportCards');

  Future<CanonicalReportCard?> getReportCard({
    required String schoolId,
    required String reportCardId,
  }) async {
    final doc = await reportCards(schoolId).doc(reportCardId).get();
    if (!doc.exists) return null;
    return fromMap(doc.id, doc.data()!);
  }

  Future<CanonicalReportCard?> getReportCardForStudent({
    required String schoolId,
    required String studentId,
    required String academicYearId,
    required String termId,
  }) async {
    final snapshot = await reportCards(schoolId)
        .where('studentId', isEqualTo: studentId)
        .where('academicYearId', isEqualTo: academicYearId)
        .where('termId', isEqualTo: termId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Future<List<CanonicalReportCard>> getReportCardsByStatus({
    required String schoolId,
    required List<AcademicWorkflowStatus> statuses,
    String? classId,
    String? academicYearId,
    String? termId,
  }) async {
    Query<Map<String, dynamic>> query = reportCards(
      schoolId,
    ).where('academicStatus', whereIn: statuses.map((s) => s.name).toList());
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
    return snapshot.docs.map((d) => fromMap(d.id, d.data())).toList();
  }

  Future<Map<String, dynamic>> submitToDean(List<String> reportCardIds) async {
    final callable = functions.httpsCallable('submitReportCardsToDean');
    final result = await callable.call(<String, dynamic>{
      'reportCardIds': reportCardIds,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> returnByDean({
    required String reportCardId,
    required String reason,
  }) async {
    final callable = functions.httpsCallable('returnReportCardByDean');
    await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
      'reason': reason,
    });
  }

  Future<void> signAsDean({
    required String reportCardId,
    required int expectedVersion,
    required String expectedSourceHash,
  }) async {
    final callable = functions.httpsCallable('signReportCardAsDean');
    await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
      'expectedVersion': expectedVersion,
      'expectedSourceHash': expectedSourceHash,
    });
  }

  Future<Map<String, dynamic>> submitToHeadteacher(
    List<String> reportCardIds,
  ) async {
    final callable = functions.httpsCallable('submitReportCardsToHeadteacher');
    final result = await callable.call(<String, dynamic>{
      'reportCardIds': reportCardIds,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> returnByHeadteacher({
    required String reportCardId,
    required String reason,
    required bool academicContentChanged,
  }) async {
    final callable = functions.httpsCallable('returnReportCardByHeadteacher');
    await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
      'reason': reason,
      'academicContentChanged': academicContentChanged,
    });
  }

  Future<void> signAsHeadteacher({
    required String reportCardId,
    required int expectedVersion,
    required String expectedSourceHash,
  }) async {
    final callable = functions.httpsCallable('signReportCardAsHeadteacher');
    await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
      'expectedVersion': expectedVersion,
      'expectedSourceHash': expectedSourceHash,
    });
  }

  /// Requests the official PDF for a finalized report. Returns the download
  /// URL once rendered; the Cloud Function itself refuses to render an
  /// unsigned/non-finalized report, and never regenerates over an existing
  /// official PDF for a version already rendered.
  Future<Map<String, dynamic>> requestOfficialPdf({
    required String reportCardId,
  }) async {
    final callable = functions.httpsCallable('generateReportCardPdf');
    final result = await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  /// Bursar-only: releases, holds or revokes financial access for one or
  /// more finalized report cards, each requiring a reason.
  Future<Map<String, dynamic>> setFinancialAccess({
    required List<String> reportCardIds,
    required String action, // 'release' | 'hold' | 'revoke'
    required String reason,
  }) async {
    final callable = functions.httpsCallable('setReportCardFinancialAccess');
    final result = await callable.call(<String, dynamic>{
      'reportCardIds': reportCardIds,
      'action': action,
      'reason': reason,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  CanonicalReportCard fromMap(String id, Map<String, dynamic> data) {
    return CanonicalReportCard(
      reportCardId: id,
      schoolId: data['schoolId'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      subjectResults: ((data['subjectResults'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubjectResultSnapshot.fromMap)
          .toList(),
      totalScore: (data['totalScore'] as num?)?.toDouble(),
      average: (data['average'] as num?)?.toDouble(),
      overallGrade: data['overallGrade'] as String?,
      overallGradeLabel: data['overallGradeLabel'] as String?,
      isOverallPassing: data['isOverallPassing'] as bool?,
      aggregatePoints: (data['aggregatePoints'] as num?)?.toDouble(),
      position: (data['position'] as num?)?.toInt(),
      isRanked: data['isRanked'] as bool? ?? false,
      attendanceVerified: data['attendanceVerified'] as bool? ?? false,
      overallConductCode: data['overallConductCode'] as String?,
      classTeacherComment: data['classTeacherComment'] as String?,
      recommendations:
          (data['recommendations'] as List?)?.whereType<String>().toList() ??
          const [],
      academicStatus: AcademicWorkflowStatus.fromId(
        data['academicStatus'] as String?,
      ),
      currentApprovalStage: data['currentApprovalStage'] as String? ?? '',
      version: (data['version'] as num?)?.toInt() ?? 1,
      sourceHash: data['sourceHash'] as String? ?? '',
      isFinalized: data['isFinalized'] as bool? ?? false,
      deanDecision: _decisionFromMap(data['deanDecision']),
      headteacherDecision: _decisionFromMap(data['headteacherDecision']),
      academicallyFinalizedAt: _toDate(data['academicallyFinalizedAt']),
      academicallyFinalizedBy: data['academicallyFinalizedBy'] as String?,
      supersedesReportCardId: data['supersedesReportCardId'] as String?,
      supersededByReportCardId: data['supersededByReportCardId'] as String?,
      approvalHistory: ((data['approvalHistory'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => ApprovalHistoryEntry(
              action: e['action'] as String? ?? '',
              actorUid: e['actorUid'] as String? ?? '',
              actorRole: e['actorRole'] as String? ?? '',
              actorDisplayName: e['actorDisplayName'] as String? ?? '',
              reason: e['reason'] as String?,
              reportVersion: (e['reportVersion'] as num?)?.toInt() ?? 1,
              sourceHashReviewed: e['sourceHashReviewed'] as String? ?? '',
              timestamp: _timestampFromHistory(e['timestamp']),
            ),
          )
          .toList(),
      financialAccessStatus: FinancialAccessStatus.fromId(
        data['financialAccessStatus'] as String?,
      ),
      pdfUrl: data['pdfUrl'] as String?,
      pdfGeneratedAt: _toDate(data['pdfGeneratedAt']),
      verificationCode: data['verificationCode'] as String?,
    );
  }

  StageDecision? _decisionFromMap(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    return StageDecision(
      decision: map['decision'] as String? ?? '',
      actorUid: map['actorUid'] as String? ?? '',
      actorDisplayName: map['actorDisplayName'] as String? ?? '',
      reason: map['reason'] as String?,
      reportVersion: (map['reportVersion'] as num?)?.toInt() ?? 1,
      decidedAt: _toDate(map['decidedAt']),
    );
  }

  DateTime? _toDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  DateTime? _timestampFromHistory(Object? value) {
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
