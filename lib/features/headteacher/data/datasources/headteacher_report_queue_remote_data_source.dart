import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

/// Reads/acts on the canonical schools/{schoolId}/reportCards collection
/// for the Headteacher's approval queue. Every mutating action goes through
/// the trusted Cloud Functions in functions/index.js.
class HeadteacherReportQueueRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  HeadteacherReportQueueRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

  CollectionReference<Map<String, dynamic>> _reportCards(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('reportCards');

  Future<List<CanonicalReportCard>> getReportCardsByStatus({
    required String schoolId,
    required List<AcademicWorkflowStatus> statuses,
  }) async {
    final query = _reportCards(schoolId).where(
      'academicStatus',
      whereIn: statuses.map((s) => s.name).toList(),
    );
    final snapshot = await query.get();
    return snapshot.docs.map((d) => _fromMap(d.id, d.data())).toList();
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

  CanonicalReportCard _fromMap(String id, Map<String, dynamic> data) {
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
