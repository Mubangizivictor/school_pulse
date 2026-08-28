import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/parent_offline/domain/parent_offline_cache_service.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

/// Parent/Student read access to canonical report cards.
///
/// Firestore rules enforce the actual gate (linked-student + academically
/// finalized + `financialAccessStatus == 'released'`); this data source only
/// queries the right documents, maps them, and participates in offline
/// caching. The client is never trusted for access - a rule change here
/// without a matching Firestore-rules change would be meaningless.
///
/// Offline behaviour (spec): the on-device cache only ever holds reports the
/// parent was authorised to read at fetch time (the query itself can only
/// return `released` reports). So a withheld report can never be surfaced
/// from stale cache, and on the next successful online fetch the cache key
/// is overwritten with the shrunken list - a since-revoked report drops out.
class ParentReportCardRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final ParentOfflineCacheService? offlineCache;

  ParentReportCardRemoteDataSource({
    required this.firestore,
    required this.functions,
    this.offlineCache,
  });

  static String _cacheKey(String studentId) => 'report_cards::$studentId';

  Future<List<CanonicalReportCard>> getReleasedReportCards({
    required String schoolId,
    required String studentId,
    String? parentId,
  }) async {
    final online = await (offlineCache?.isOnline ?? Future.value(true));
    if (!online && offlineCache != null && parentId != null) {
      final cached = await offlineCache!.read(
        tenantId: schoolId,
        parentId: parentId,
        learnerId: studentId,
        cacheKey: _cacheKey(studentId),
      );
      if (cached != null) {
        final list = (jsonDecode(cached.payloadJson) as List)
            .whereType<Map>()
            .map(
              (m) =>
                  _fromMap(m['id'] as String? ?? '', m.cast<String, dynamic>()),
            )
            .toList();
        return list;
      }
      return const [];
    }

    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('reportCards')
        .where('studentId', isEqualTo: studentId)
        .get();
    final rawDocs = snapshot.docs
        .where(
          (d) => (d.data()['financialAccessStatus'] as String?) == 'released',
        )
        .toList();
    final cards = rawDocs.map((d) => _fromMap(d.id, d.data())).toList();
    cards.sort((a, b) => b.academicYearId.compareTo(a.academicYearId));

    // Refresh the offline cache with exactly what the parent may see now.
    if (offlineCache != null && parentId != null) {
      final payload = jsonEncode([
        for (final d in rawDocs) {'id': d.id, ...d.data()},
      ]);
      await offlineCache!.save(
        tenantId: schoolId,
        parentId: parentId,
        learnerId: studentId,
        cacheKey: _cacheKey(studentId),
        payloadJson: payload,
      );
    }
    return cards;
  }

  /// The school's configured parent-facing restriction message. Parents may
  /// read `configs/reportReleasePolicy`. Falls back to the default respectful
  /// copy if unset or unreadable.
  Future<String> getRestrictionMessage(String schoolId) async {
    try {
      final doc = await firestore
          .doc('schools/$schoolId/configs/reportReleasePolicy')
          .get();
      final fc = (doc.data()?['financialClearance'] as Map?)
          ?.cast<String, dynamic>();
      final msg = fc?['restrictionMessage'] as String?;
      if (msg != null && msg.trim().isNotEmpty) return msg.trim();
    } catch (_) {
      // fall through to default
    }
    return FinancialClearancePolicy.defaultRestrictionMessage;
  }

  Future<String> getOfficialPdfDownloadUrl(String reportCardId) async {
    final callable = functions.httpsCallable('getReportCardPdfDownloadUrl');
    final result = await callable.call(<String, dynamic>{
      'reportCardId': reportCardId,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['url'] as String;
  }

  /// Best-effort: tells the backend a parent/student opened (or downloaded)
  /// a report so it can write the immutable parent-access audit event and
  /// lock any covering exception. Never throws into the UI.
  Future<void> recordParentView(
    String reportCardId, {
    bool isDownload = false,
  }) async {
    try {
      await functions.httpsCallable('recordReportCardParentView').call(
        <String, dynamic>{
          'reportCardId': reportCardId,
          'kind': isDownload ? 'download' : 'view',
        },
      );
    } catch (_) {
      // audit is best-effort; a failure must not affect the parent's view
    }
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
