import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

/// Parent/Student read access to canonical report cards. Firestore rules
/// enforce the actual gate (linked-student + academically finalized +
/// Bursar-released); this data source's job is only to query the right
/// documents and map them, never to decide who may see what - a rule
/// change here without a matching Firestore-rules change would be
/// meaningless anyway, since the client is never trusted for this.
class ParentReportCardRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  ParentReportCardRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

  /// Every report card for this student that Firestore rules actually let
  /// the caller read - i.e. every finalized + released report linked to
  /// them. An unreleased/unfinalized report for the same student simply
  /// never appears in this list; Firestore rules deny the read entirely
  /// rather than returning it with fields stripped, so there is no risk of
  /// a partially-visible restricted report.
  Future<List<CanonicalReportCard>> getReleasedReportCards({
    required String schoolId,
    required String studentId,
  }) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('reportCards')
        .where('studentId', isEqualTo: studentId)
        .get();
    final cards = snapshot.docs.map((d) => _fromMap(d.id, d.data())).toList();
    cards.sort((a, b) => b.academicYearId.compareTo(a.academicYearId));
    return cards;
  }

  Future<String> getOfficialPdfDownloadUrl(String reportCardId) async {
    final callable = functions.httpsCallable('getReportCardPdfDownloadUrl');
    final result = await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['url'] as String;
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
      version: (data['version'] as num?)?.toInt() ?? 1,
      isFinalized: data['isFinalized'] as bool? ?? false,
      financialAccessStatus: FinancialAccessStatus.fromId(
        data['financialAccessStatus'] as String?,
      ),
      pdfUrl: data['pdfUrl'] as String?,
    );
  }
}
