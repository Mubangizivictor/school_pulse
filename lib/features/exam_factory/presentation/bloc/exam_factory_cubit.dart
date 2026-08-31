import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/network/network_info.dart';
import '../../data/datasources/exam_factory_queue_data_source.dart';
import '../../domain/entities/exam_factory_entities.dart';
import '../../domain/repositories/exam_factory_repository.dart';
import '../../domain/services/exam_factory_offline_queue_service.dart';

/// Thin state holder around [ExamFactoryRepository]. Screens read live
/// Firestore streams directly from the repository via StreamBuilder; this
/// cubit only tracks the selected exam series and forwards mutations so
/// widgets never call the repository or Cloud Functions directly.
class ExamFactoryState {
  final String? selectedSeriesId;
  final bool isBusy;
  final String? error;

  /// True only for the tick right after a mutation was queued offline
  /// rather than sent - screens use this to show a "saved, will sync"
  /// message instead of the normal success confirmation.
  final bool queuedOffline;

  const ExamFactoryState({
    this.selectedSeriesId,
    this.isBusy = false,
    this.error,
    this.queuedOffline = false,
  });

  ExamFactoryState copyWith({
    String? selectedSeriesId,
    bool? isBusy,
    String? error,
    bool clearError = false,
    bool queuedOffline = false,
  }) => ExamFactoryState(
    selectedSeriesId: selectedSeriesId ?? this.selectedSeriesId,
    isBusy: isBusy ?? this.isBusy,
    error: clearError ? null : (error ?? this.error),
    queuedOffline: queuedOffline,
  );
}

class ExamFactoryCubit extends Cubit<ExamFactoryState> {
  final ExamFactoryRepository repository;
  final String institutionId;
  final String currentUserId;

  /// Both optional so existing call sites (and tests) that construct this
  /// cubit without offline support keep working; offline queueing is simply
  /// skipped and every mutation goes straight online, same as before this
  /// was added.
  final NetworkInfo? networkInfo;
  final ExamFactoryOfflineQueueService? offlineQueue;
  static const _uuid = Uuid();

  ExamFactoryCubit({
    required this.repository,
    required this.institutionId,
    required this.currentUserId,
    this.networkInfo,
    this.offlineQueue,
  }) : super(const ExamFactoryState());

  void selectSeries(String? seriesId) =>
      emit(state.copyWith(selectedSeriesId: seriesId));

  Stream<List<ExamSeries>> watchSeries() =>
      repository.watchSeries(institutionId);

  Stream<List<ExamQuestion>> watchQuestions({
    String? seriesId,
    String? classId,
    String? subjectId,
    String? creatorId,
    ExamQuestionStatus? status,
  }) => repository.watchQuestions(
    institutionId,
    seriesId: seriesId,
    classId: classId,
    subjectId: subjectId,
    creatorId: creatorId,
    status: status,
  );

  Stream<ExamQuestion?> watchQuestion(String questionId) =>
      repository.watchQuestion(institutionId, questionId);

  Stream<List<ExamPaper>> watchPapers({String? seriesId}) =>
      repository.watchPapers(institutionId, seriesId: seriesId);

  Stream<ExamPaper?> watchPaper(String paperId) =>
      repository.watchPaper(institutionId, paperId);

  Future<T> _guarded<T>(Future<T> Function() action) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final result = await action();
      emit(state.copyWith(isBusy: false));
      return result;
    } catch (e) {
      emit(state.copyWith(isBusy: false, error: _friendly(e)));
      rethrow;
    }
  }

  /// Runs [action] online, unless the device is offline and offline support
  /// is wired up (both [networkInfo] and [offlineQueue] non-null) - in that
  /// case the action is durably queued via [queueType]/[payload] instead,
  /// using [operationId] as the queue item's idempotency key so replay can
  /// never double-submit. Only ever called for the spec's safe-to-queue
  /// actions (question drafts, moderation comments, mark entry, attendance,
  /// incidents) - paper approval/locking/printing always call [_guarded]
  /// directly and require an online session.
  Future<void> _guardedOffline({
    required ExamFactoryQueueActionType queueType,
    required Map<String, dynamic> payload,
    required String operationId,
    required Future<void> Function() action,
  }) async {
    final queue = offlineQueue;
    final network = networkInfo;
    if (queue == null || network == null || await network.isConnected) {
      await _guarded(action);
      return;
    }
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      await queue.enqueue(
        institutionId: institutionId,
        actorId: currentUserId,
        actionType: queueType,
        payloadJson: jsonEncode({'operationId': operationId, ...payload}),
      );
      emit(state.copyWith(isBusy: false, queuedOffline: true));
    } catch (e) {
      emit(state.copyWith(isBusy: false, error: _friendly(e)));
      rethrow;
    }
  }

  String _friendly(Object error) {
    final message = error.toString();
    if (message.contains('permission-denied')) {
      return 'You do not have permission to do this.';
    }
    if (message.contains('failed-precondition')) {
      return 'This action is not allowed in the current state.';
    }
    if (message.contains('not-found')) return 'Record not found.';
    if (message.contains('invalid-argument'))
      return 'Please check the entered values.';
    return 'Something went wrong. Please try again.';
  }

  Future<String> saveSeries(ExamSeries series, {String? operationId}) =>
      _guarded(
        () => repository.saveExamSeries(series, operationId: operationId),
      );

  Future<void> saveQuestionDraft(ExamQuestion question, {String? operationId}) {
    final opId = operationId ?? _uuid.v4();
    return _guardedOffline(
      queueType: ExamFactoryQueueActionType.saveQuestionDraft,
      operationId: opId,
      payload: {
        'questionId': question.id,
        'seriesId': question.seriesId,
        'classId': question.classId,
        'subjectId': question.subjectId,
        'topic': question.topic,
        'type': question.type.name,
        'text': question.text,
        'marks': question.marks,
        'difficulty': question.difficulty.name,
        'suggestedAnswer': question.suggestedAnswer,
        'markingGuide': question.markingGuide,
        'teacherNotes': question.teacherNotes,
      },
      action: () => repository.saveQuestionDraft(question, operationId: opId),
    );
  }

  Future<void> submitQuestion(
    String questionId, {
    String? academicYearId,
    String? operationId,
  }) {
    final opId = operationId ?? _uuid.v4();
    return _guardedOffline(
      queueType: ExamFactoryQueueActionType.submitQuestion,
      operationId: opId,
      payload: {
        'questionId': questionId,
        if (academicYearId != null) 'academicYearId': academicYearId,
      },
      action: () => repository.submitQuestion(
        institutionId,
        questionId,
        academicYearId: academicYearId,
        operationId: opId,
      ),
    );
  }

  Future<void> moderateQuestion(
    String questionId,
    ExamQuestionStatus decision, {
    String? comment,
    String? operationId,
  }) {
    final opId = operationId ?? _uuid.v4();
    return _guardedOffline(
      queueType: ExamFactoryQueueActionType.moderateQuestion,
      operationId: opId,
      payload: {
        'questionId': questionId,
        'decision': decision.name,
        if (comment != null) 'comment': comment,
      },
      action: () => repository.moderateQuestion(
        institutionId,
        questionId,
        decision,
        comment: comment,
        operationId: opId,
      ),
    );
  }

  Future<void> savePaper(ExamPaper paper, {String? operationId}) =>
      _guarded(() => repository.savePaper(paper, operationId: operationId));

  Future<void> requestPaperApproval(String paperId, {String? operationId}) =>
      _guarded(
        () => repository.requestPaperApproval(
          institutionId,
          paperId,
          operationId: operationId,
        ),
      );

  Future<void> approvePaper(
    String paperId, {
    String? comment,
    String? operationId,
  }) => _guarded(
    () => repository.approvePaper(
      institutionId,
      paperId,
      comment: comment,
      operationId: operationId,
    ),
  );

  Future<void> lockPaper(String paperId, {String? operationId}) => _guarded(
    () =>
        repository.lockPaper(institutionId, paperId, operationId: operationId),
  );

  Stream<List<ExamPrintJob>> watchPrintJobs({String? paperId}) =>
      repository.watchPrintJobs(institutionId, paperId: paperId);

  Future<Map<String, String>> generatePaperFiles(
    String paperId, {
    String? watermark,
  }) => _guarded(
    () => repository.generatePaperFiles(
      institutionId,
      paperId,
      watermark: watermark,
    ),
  );

  Future<String> getPaperDownloadUrl(
    String paperId,
    String fileType, {
    String? operationId,
  }) => _guarded(
    () => repository.getPaperDownloadUrl(
      institutionId,
      paperId,
      fileType,
      operationId: operationId,
    ),
  );

  Future<String> recordPrintJob(
    String paperId, {
    required int copies,
    int extraCopies = 0,
    String? printer,
    String paperSize = 'A4',
    bool duplex = false,
    bool includeQuestionPaper = true,
    bool includeMarkingGuide = false,
    String? watermark,
    bool isReprint = false,
    String? reprintReason,
  }) => _guarded(
    () => repository.recordPrintJob(
      institutionId,
      paperId,
      copies: copies,
      extraCopies: extraCopies,
      printer: printer,
      paperSize: paperSize,
      duplex: duplex,
      includeQuestionPaper: includeQuestionPaper,
      includeMarkingGuide: includeMarkingGuide,
      watermark: watermark,
      isReprint: isReprint,
      reprintReason: reprintReason,
    ),
  );

  Future<void> completePrintJob(String jobId) =>
      _guarded(() => repository.completePrintJob(institutionId, jobId));

  Stream<List<(String id, String name, int capacity)>> watchVenues() =>
      repository.watchVenues(institutionId);

  Stream<List<ExamSitting>> watchSittings({String? seriesId}) =>
      repository.watchSittings(institutionId, seriesId: seriesId);

  Stream<ExamSitting?> watchSitting(String sittingId) =>
      repository.watchSitting(institutionId, sittingId);

  Future<String> saveSitting({
    String? sittingId,
    required String paperId,
    required String venueId,
    String? venueName,
    required DateTime startTime,
    int? durationMinutes,
  }) => _guarded(
    () => repository.saveSitting(
      institutionId,
      sittingId: sittingId,
      paperId: paperId,
      venueId: venueId,
      venueName: venueName,
      startTime: startTime,
      durationMinutes: durationMinutes,
    ),
  );

  Stream<List<ExamInvigilatorAssignment>> watchInvigilators({
    String? sittingId,
  }) => repository.watchInvigilators(institutionId, sittingId: sittingId);

  Future<String> assignInvigilator({
    required String sittingId,
    required String staffId,
    String? staffName,
    required InvigilatorRole role,
  }) => _guarded(
    () => repository.assignInvigilator(
      institutionId,
      sittingId: sittingId,
      staffId: staffId,
      staffName: staffName,
      role: role,
    ),
  );

  Future<void> removeInvigilator(String assignmentId) =>
      _guarded(() => repository.removeInvigilator(institutionId, assignmentId));

  Stream<List<ExamAttendanceRecord>> watchAttendance({
    required String sittingId,
  }) => repository.watchAttendance(institutionId, sittingId: sittingId);

  Future<void> recordAttendance({
    required String sittingId,
    required String studentId,
    String? studentName,
    required ExamAttendanceStatus status,
    String? note,
    String? operationId,
  }) {
    final opId = operationId ?? '${sittingId}_$studentId';
    return _guardedOffline(
      queueType: ExamFactoryQueueActionType.recordAttendance,
      operationId: opId,
      payload: {
        'sittingId': sittingId,
        'studentId': studentId,
        if (studentName != null) 'studentName': studentName,
        'status': status.name,
        if (note != null) 'note': note,
      },
      action: () => repository.recordAttendance(
        institutionId,
        sittingId: sittingId,
        studentId: studentId,
        studentName: studentName,
        status: status,
        note: note,
        operationId: opId,
      ),
    );
  }

  Stream<List<ExamIncident>> watchIncidents({String? sittingId}) =>
      repository.watchIncidents(institutionId, sittingId: sittingId);

  Future<String> reportIncident({
    required String sittingId,
    required ExamIncidentType type,
    required String description,
    List<String> studentIds = const [],
  }) async {
    final incidentId = _uuid.v4();
    await _guardedOffline(
      queueType: ExamFactoryQueueActionType.reportIncident,
      operationId: incidentId,
      payload: {
        'incidentId': incidentId,
        'sittingId': sittingId,
        'type': type.name,
        'description': description,
        'studentIds': studentIds,
      },
      action: () => repository.reportIncident(
        institutionId,
        incidentId: incidentId,
        sittingId: sittingId,
        type: type,
        description: description,
        studentIds: studentIds,
      ),
    );
    return incidentId;
  }

  Future<void> resolveIncident(
    String incidentId, {
    required String resolution,
  }) => _guarded(
    () => repository.resolveIncident(
      institutionId,
      incidentId,
      resolution: resolution,
    ),
  );

  Stream<List<ExamMarkEntry>> watchMarkEntries({required String paperId}) =>
      repository.watchMarkEntries(institutionId, paperId: paperId);

  Future<void> saveMarkEntry({
    required String paperId,
    required String studentId,
    String? studentName,
    double? score,
    bool isAbsent = false,
    String? remark,
    String? operationId,
  }) {
    final opId = operationId ?? '${paperId}_$studentId';
    return _guardedOffline(
      queueType: ExamFactoryQueueActionType.saveMarkEntry,
      operationId: opId,
      payload: {
        'paperId': paperId,
        'studentId': studentId,
        if (studentName != null) 'studentName': studentName,
        if (score != null) 'score': score,
        'isAbsent': isAbsent,
        if (remark != null) 'remark': remark,
      },
      action: () => repository.saveMarkEntry(
        institutionId,
        paperId: paperId,
        studentId: studentId,
        studentName: studentName,
        score: score,
        isAbsent: isAbsent,
        remark: remark,
        operationId: opId,
      ),
    );
  }

  Future<int> submitMarks(String paperId, {String? operationId}) => _guarded(
    () => repository.submitMarks(
      institutionId,
      paperId,
      operationId: operationId,
    ),
  );

  Future<Map<String, int>> approveResults(
    String paperId, {
    String? operationId,
  }) => _guarded(
    () => repository.approveResults(
      institutionId,
      paperId,
      operationId: operationId,
    ),
  );

  Stream<List<ExamAuditEntry>> watchAuditTrail({
    String? paperId,
    String? questionId,
  }) => repository.watchAuditTrail(
    institutionId,
    paperId: paperId,
    questionId: questionId,
  );

  Stream<List<ExamSeatAssignment>> watchSeating({required String sittingId}) =>
      repository.watchSeating(institutionId, sittingId: sittingId);

  Future<String> assignSeat({
    required String sittingId,
    required String studentId,
    String? studentName,
    required String seatNumber,
  }) => _guarded(
    () => repository.assignSeat(
      institutionId,
      sittingId: sittingId,
      studentId: studentId,
      studentName: studentName,
      seatNumber: seatNumber,
    ),
  );

  Future<void> removeSeat(String seatId) =>
      _guarded(() => repository.removeSeat(institutionId, seatId));

  Stream<List<ExamScriptRecord>> watchScripts({required String sittingId}) =>
      repository.watchScripts(institutionId, sittingId: sittingId);

  Future<void> recordScript({
    required String sittingId,
    required String studentId,
    String? studentName,
    required ScriptStatus status,
    String? note,
    String? operationId,
  }) => _guarded(
    () => repository.recordScript(
      institutionId,
      sittingId: sittingId,
      studentId: studentId,
      studentName: studentName,
      status: status,
      note: note,
      operationId: operationId,
    ),
  );
}
