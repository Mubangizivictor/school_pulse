import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

/// The Bursar's report-release data access: reads finalized report cards
/// and calls the trusted setReportCardFinancialAccess Cloud Function for
/// every state change. Never writes financialAccessStatus (or anything
/// else on a reportCards document) directly - Firestore rules deny that
/// client write path entirely, matching the requirement that the Bursar
/// controls access only, never marks/grades/comments/signatures.
class BursarReportReleaseRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  BursarReportReleaseRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

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
    return snapshot.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

  Future<Map<String, dynamic>> setFinancialAccess({
    required List<String> reportCardIds,
    required String action,
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
