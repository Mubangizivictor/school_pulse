import '../entities/exam_factory_entities.dart';

/// Server-backed implementations must apply tenant and role checks; callers
/// must never infer access from a route or from hidden controls.
abstract class ExamFactoryRepository {
  Stream<List<ExamSeries>> watchSeries(String institutionId);
  Stream<ExamSeries?> watchSeriesById(String institutionId, String seriesId);
  Stream<List<ExamQuestion>> watchQuestions(
    String institutionId, {
    String? seriesId,
    String? classId,
    String? subjectId,
    String? creatorId,
    ExamQuestionStatus? status,
  });
  Stream<ExamQuestion?> watchQuestion(String institutionId, String questionId);
  Stream<List<ExamPaper>> watchPapers(String institutionId, {String? seriesId});
  Stream<ExamPaper?> watchPaper(String institutionId, String paperId);

  Future<String> saveExamSeries(ExamSeries series, {String? operationId});

  Future<void> saveQuestionDraft(ExamQuestion question, {String? operationId});
  Future<void> submitQuestion(
    String institutionId,
    String questionId, {
    String? academicYearId,
    String? operationId,
  });
  Future<void> moderateQuestion(
    String institutionId,
    String questionId,
    ExamQuestionStatus decision, {
    String? comment,
    String? operationId,
  });
  Future<void> savePaper(ExamPaper paper, {String? operationId});
  Future<void> requestPaperApproval(
    String institutionId,
    String paperId, {
    String? operationId,
  });
  Future<void> approvePaper(
    String institutionId,
    String paperId, {
    String? comment,
    String? operationId,
  });
  Future<void> lockPaper(
    String institutionId,
    String paperId, {
    String? operationId,
  });

  Stream<List<ExamPrintJob>> watchPrintJobs(
    String institutionId, {
    String? paperId,
  });

  Future<Map<String, String>> generatePaperFiles(
    String institutionId,
    String paperId, {
    String? watermark,
  });

  Future<String> getPaperDownloadUrl(
    String institutionId,
    String paperId,
    String fileType, {
    String? operationId,
  });

  Future<String> recordPrintJob(
    String institutionId,
    String paperId, {
    required int copies,
    int extraCopies,
    String? printer,
    String paperSize,
    bool duplex,
    bool includeQuestionPaper,
    bool includeMarkingGuide,
    String? watermark,
    bool isReprint,
    String? reprintReason,
  });

  Future<void> completePrintJob(String institutionId, String jobId);

  // Exam operations
  /// Reads schools/{institutionId}/spaces - the same room/venue records
  /// Structure's Rooms & Venues screen manages - as (id, name, capacity)
  /// pairs, so scheduling never duplicates room data.
  Stream<List<(String id, String name, int capacity)>> watchVenues(
    String institutionId,
  );

  Stream<List<ExamSitting>> watchSittings(
    String institutionId, {
    String? seriesId,
  });
  Stream<ExamSitting?> watchSitting(String institutionId, String sittingId);
  Future<String> saveSitting(
    String institutionId, {
    String? sittingId,
    required String paperId,
    required String venueId,
    String? venueName,
    required DateTime startTime,
    int? durationMinutes,
  });

  Stream<List<ExamInvigilatorAssignment>> watchInvigilators(
    String institutionId, {
    String? sittingId,
  });
  Future<String> assignInvigilator(
    String institutionId, {
    required String sittingId,
    required String staffId,
    String? staffName,
    required InvigilatorRole role,
  });
  Future<void> removeInvigilator(String institutionId, String assignmentId);

  Stream<List<ExamAttendanceRecord>> watchAttendance(
    String institutionId, {
    required String sittingId,
  });
  Future<void> recordAttendance(
    String institutionId, {
    required String sittingId,
    required String studentId,
    String? studentName,
    required ExamAttendanceStatus status,
    String? note,
    String? operationId,
  });

  Stream<List<ExamIncident>> watchIncidents(
    String institutionId, {
    String? sittingId,
  });
  Future<String> reportIncident(
    String institutionId, {
    String? incidentId,
    required String sittingId,
    required ExamIncidentType type,
    required String description,
    List<String> studentIds,
  });
  Future<void> resolveIncident(
    String institutionId,
    String incidentId, {
    required String resolution,
  });

  // Marking and results
  Stream<List<ExamMarkEntry>> watchMarkEntries(
    String institutionId, {
    required String paperId,
  });
  Future<void> saveMarkEntry(
    String institutionId, {
    required String paperId,
    required String studentId,
    String? studentName,
    double? score,
    bool isAbsent,
    String? remark,
    String? operationId,
  });
  Future<int> submitMarks(
    String institutionId,
    String paperId, {
    String? operationId,
  });
  Future<Map<String, int>> approveResults(
    String institutionId,
    String paperId, {
    String? operationId,
  });

  Stream<List<ExamAuditEntry>> watchAuditTrail(
    String institutionId, {
    String? paperId,
    String? questionId,
  });

  Stream<List<ExamSeatAssignment>> watchSeating(
    String institutionId, {
    required String sittingId,
  });
  Future<String> assignSeat(
    String institutionId, {
    required String sittingId,
    required String studentId,
    String? studentName,
    required String seatNumber,
  });
  Future<void> removeSeat(String institutionId, String seatId);

  Stream<List<ExamScriptRecord>> watchScripts(
    String institutionId, {
    required String sittingId,
  });
  Future<void> recordScript(
    String institutionId, {
    required String sittingId,
    required String studentId,
    String? studentName,
    required ScriptStatus status,
    String? note,
    String? operationId,
  });
}
