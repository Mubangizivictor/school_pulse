// ignore_for_file: prefer_initializing_formals

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/entities/exam_factory_entities.dart';
import '../../domain/repositories/exam_factory_repository.dart';

/// Reads tenant-scoped records. Every mutation calls a protected backend
/// action; direct client writes are rejected by Firestore rules.
class ExamFactoryRepositoryImpl implements ExamFactoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  ExamFactoryRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  }) : _firestore = firestore,
       _functions = functions;

  CollectionReference<Map<String, dynamic>> _collection(
    String institutionId,
    String name,
  ) => _firestore.collection('schools').doc(institutionId).collection(name);

  T _enumByName<T extends Enum>(
    Iterable<T> values,
    Object? source,
    T fallback,
  ) => values.cast<T?>().firstWhere(
    (value) => value?.name == source,
    orElse: () => fallback,
  )!;

  DateTime _date(Object? source) => source is Timestamp
      ? source.toDate()
      : DateTime.fromMillisecondsSinceEpoch(0);

  DateTime? _dateOrNull(Object? source) =>
      source is Timestamp ? source.toDate() : null;

  ExamSeries _series(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _seriesFromSnap(doc);

  ExamSeries _seriesFromSnap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ExamSeries(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      name: d['name'] ?? '',
      academicYear: d['academicYear'] ?? '',
      term: d['term'] ?? '',
      type: d['type'] ?? 'midterm',
      startDate: _date(d['startDate']),
      endDate: _date(d['endDate']),
      status: _enumByName(
        ExamSeriesStatus.values,
        d['status'],
        ExamSeriesStatus.draft,
      ),
      classIds: List<String>.from(d['classIds'] ?? const []),
      subjectIds: List<String>.from(d['subjectIds'] ?? const []),
      gradingScaleId: d['gradingScaleId'] ?? '',
      paperTemplateId: d['paperTemplateId'] ?? '',
      questionDeadline: _dateOrNull(d['questionDeadline']),
      moderationDeadline: _dateOrNull(d['moderationDeadline']),
      paperApprovalDeadline: _dateOrNull(d['paperApprovalDeadline']),
      printingDeadline: _dateOrNull(d['printingDeadline']),
      markingDeadline: _dateOrNull(d['markingDeadline']),
      resultPublicationDate: _dateOrNull(d['resultPublicationDate']),
      createdAt: _dateOrNull(d['createdAt']),
      updatedAt: _dateOrNull(d['updatedAt']),
      createdBy: d['createdBy'] ?? '',
    );
  }

  ExamQuestion _question(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _questionFromSnap(doc);

  ExamQuestion _questionFromSnap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ExamQuestion(
      id: doc.id,
      seriesId: d['seriesId'] ?? '',
      institutionId: d['institutionId'] ?? '',
      classId: d['classId'] ?? '',
      subjectId: d['subjectId'] ?? '',
      topic: d['topic'] ?? '',
      creatorId: d['creatorId'] ?? '',
      text: d['text'] ?? '',
      marks: (d['marks'] as num?)?.toInt() ?? 0,
      version: (d['version'] as num?)?.toInt() ?? 1,
      type: _enumByName(
        ExamQuestionType.values,
        d['type'],
        ExamQuestionType.shortAnswer,
      ),
      status: _enumByName(
        ExamQuestionStatus.values,
        d['status'],
        ExamQuestionStatus.draft,
      ),
      difficulty: _enumByName(
        ExamQuestionDifficulty.values,
        d['difficulty'],
        ExamQuestionDifficulty.medium,
      ),
      suggestedAnswer: d['suggestedAnswer'] ?? '',
      markingGuide: d['markingGuide'] ?? '',
      teacherNotes: d['teacherNotes'] ?? '',
      moderationComment: d['moderationComment'] ?? '',
      moderatedBy: d['moderatedBy'] ?? '',
      attachmentUrls: List<String>.from(d['attachmentUrls'] ?? const []),
      createdAt: _dateOrNull(d['createdAt']),
      updatedAt: _dateOrNull(d['updatedAt']),
      submittedAt: _dateOrNull(d['submittedAt']),
      moderatedAt: _dateOrNull(d['moderatedAt']),
    );
  }

  ExamPaper _paper(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _paperFromSnap(doc);

  ExamPaper _paperFromSnap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ExamPaper(
      id: doc.id,
      seriesId: d['seriesId'] ?? '',
      institutionId: d['institutionId'] ?? '',
      classId: d['classId'] ?? '',
      subjectId: d['subjectId'] ?? '',
      title: d['title'] ?? '',
      targetMarks: (d['targetMarks'] as num?)?.toInt() ?? 0,
      totalMarks: (d['totalMarks'] as num?)?.toInt() ?? 0,
      version: (d['version'] as num?)?.toInt() ?? 1,
      durationMinutes: (d['durationMinutes'] as num?)?.toInt() ?? 60,
      status: _enumByName(
        ExamPaperStatus.values,
        d['status'],
        ExamPaperStatus.draft,
      ),
      questionIds: List<String>.from(d['questionIds'] ?? const []),
      createdAt: _dateOrNull(d['createdAt']),
      updatedAt: _dateOrNull(d['updatedAt']),
      lockedAt: _dateOrNull(d['lockedAt']),
      lockedBy: d['lockedBy'] ?? '',
      questionPaperPath: d['questionPaperPath'] ?? '',
      markingGuidePath: d['markingGuidePath'] ?? '',
      generatedFilesVersion: (d['generatedFilesVersion'] as num?)?.toInt() ?? 0,
    );
  }

  ExamPrintJob _printJob(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return ExamPrintJob(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      paperId: d['paperId'] ?? '',
      seriesId: d['seriesId'] ?? '',
      version: (d['version'] as num?)?.toInt() ?? 1,
      copies: (d['copies'] as num?)?.toInt() ?? 0,
      extraCopies: (d['extraCopies'] as num?)?.toInt() ?? 0,
      printer: d['printer'] ?? '',
      paperSize: d['paperSize'] ?? 'A4',
      duplex: d['duplex'] == true,
      includeQuestionPaper: d['includeQuestionPaper'] != false,
      includeMarkingGuide: d['includeMarkingGuide'] == true,
      isReprint: d['isReprint'] == true,
      reprintReason: d['reprintReason'] ?? '',
      status: _enumByName(
        PrintJobStatus.values,
        d['status'],
        PrintJobStatus.started,
      ),
      initiatedBy: d['initiatedBy'] ?? '',
      completedBy: d['completedBy'] ?? '',
      initiatedAt: _dateOrNull(d['initiatedAt']),
      completedAt: _dateOrNull(d['completedAt']),
    );
  }

  @override
  Stream<List<ExamSeries>> watchSeries(String institutionId) =>
      _collection(institutionId, 'exam_factory_series')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((items) => items.docs.map(_series).toList());

  @override
  Stream<ExamSeries?> watchSeriesById(String institutionId, String seriesId) =>
      _collection(institutionId, 'exam_factory_series')
          .doc(seriesId)
          .snapshots()
          .map((doc) => doc.exists ? _seriesFromSnap(doc) : null);

  @override
  Stream<List<ExamQuestion>> watchQuestions(
    String institutionId, {
    String? seriesId,
    String? classId,
    String? subjectId,
    String? creatorId,
    ExamQuestionStatus? status,
  }) {
    Query<Map<String, dynamic>> query = _collection(
      institutionId,
      'exam_factory_questions',
    ).orderBy('updatedAt', descending: true);
    if (seriesId != null) {
      query = query.where('seriesId', isEqualTo: seriesId);
    }
    if (classId != null) {
      query = query.where('classId', isEqualTo: classId);
    }
    if (subjectId != null) {
      query = query.where('subjectId', isEqualTo: subjectId);
    }
    if (creatorId != null) {
      query = query.where('creatorId', isEqualTo: creatorId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((items) => items.docs.map(_question).toList());
  }

  @override
  Stream<ExamQuestion?> watchQuestion(
    String institutionId,
    String questionId,
  ) => _collection(institutionId, 'exam_factory_questions')
      .doc(questionId)
      .snapshots()
      .map((doc) => doc.exists ? _questionFromSnap(doc) : null);

  @override
  Stream<List<ExamPaper>> watchPapers(
    String institutionId, {
    String? seriesId,
  }) {
    Query<Map<String, dynamic>> query = _collection(
      institutionId,
      'exam_factory_papers',
    ).orderBy('updatedAt', descending: true);
    if (seriesId != null) {
      query = query.where('seriesId', isEqualTo: seriesId);
    }
    return query.snapshots().map((items) => items.docs.map(_paper).toList());
  }

  @override
  Stream<ExamPaper?> watchPaper(String institutionId, String paperId) =>
      _collection(institutionId, 'exam_factory_papers')
          .doc(paperId)
          .snapshots()
          .map((doc) => doc.exists ? _paperFromSnap(doc) : null);

  Future<Map<String, dynamic>?> _call(
    String name,
    Map<String, dynamic> payload,
  ) async {
    final result = await _functions.httpsCallable(name).call(payload);
    return (result.data as Map?)?.cast<String, dynamic>();
  }

  String? _iso(DateTime? value) => value?.toUtc().toIso8601String();

  @override
  Future<String> saveExamSeries(
    ExamSeries series, {
    String? operationId,
  }) async {
    final payload = <String, dynamic>{
      'institutionId': series.institutionId,
      'seriesId': series.id,
      'name': series.name,
      'academicYear': series.academicYear,
      'term': series.term,
      'type': series.type,
      'startDate': _iso(series.startDate),
      'endDate': _iso(series.endDate),
      'classIds': series.classIds,
      'subjectIds': series.subjectIds,
      'gradingScaleId': series.gradingScaleId,
      'paperTemplateId': series.paperTemplateId,
      if (series.questionDeadline != null)
        'questionDeadline': _iso(series.questionDeadline),
      if (series.moderationDeadline != null)
        'moderationDeadline': _iso(series.moderationDeadline),
      if (series.paperApprovalDeadline != null)
        'paperApprovalDeadline': _iso(series.paperApprovalDeadline),
      if (series.printingDeadline != null)
        'printingDeadline': _iso(series.printingDeadline),
      if (series.markingDeadline != null)
        'markingDeadline': _iso(series.markingDeadline),
      if (series.resultPublicationDate != null)
        'resultPublicationDate': _iso(series.resultPublicationDate),
      if (operationId != null) 'operationId': operationId,
    };
    final result = await _call('saveExamSeries', payload);
    return (result?['seriesId'] as String?) ?? series.id;
  }

  @override
  Future<void> saveQuestionDraft(
    ExamQuestion question, {
    String? operationId,
  }) => _call('saveExamQuestionDraft', {
    'institutionId': question.institutionId,
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
    'attachmentUrls': question.attachmentUrls,
    if (operationId != null) 'operationId': operationId,
  });

  @override
  Future<void> submitQuestion(
    String institutionId,
    String questionId, {
    String? academicYearId,
    String? operationId,
  }) async {
    final payload = {'institutionId': institutionId, 'questionId': questionId};
    if (academicYearId != null) payload['academicYearId'] = academicYearId;
    if (operationId != null) payload['operationId'] = operationId;
    await _call('submitExamQuestion', payload);
  }

  @override
  Future<void> moderateQuestion(
    String institutionId,
    String questionId,
    ExamQuestionStatus decision, {
    String? comment,
    String? operationId,
  }) async {
    final payload = {
      'institutionId': institutionId,
      'questionId': questionId,
      'decision': decision.name,
    };
    if (comment != null) payload['comment'] = comment;
    if (operationId != null) payload['operationId'] = operationId;
    await _call('moderateExamQuestion', payload);
  }

  @override
  Future<void> savePaper(ExamPaper paper, {String? operationId}) =>
      _call('saveExamPaper', {
        'institutionId': paper.institutionId,
        'paperId': paper.id,
        'seriesId': paper.seriesId,
        'classId': paper.classId,
        'subjectId': paper.subjectId,
        'title': paper.title,
        'targetMarks': paper.targetMarks,
        'totalMarks': paper.totalMarks,
        'durationMinutes': paper.durationMinutes,
        'questionIds': paper.questionIds,
        if (operationId != null) 'operationId': operationId,
      });

  @override
  Future<void> requestPaperApproval(
    String institutionId,
    String paperId, {
    String? operationId,
  }) async {
    final payload = {'institutionId': institutionId, 'paperId': paperId};
    if (operationId != null) payload['operationId'] = operationId;
    await _call('requestExamPaperApproval', payload);
  }

  @override
  Future<void> approvePaper(
    String institutionId,
    String paperId, {
    String? comment,
    String? operationId,
  }) async {
    final payload = {'institutionId': institutionId, 'paperId': paperId};
    if (comment != null) payload['comment'] = comment;
    if (operationId != null) payload['operationId'] = operationId;
    await _call('approveExamPaper', payload);
  }

  @override
  Future<void> lockPaper(
    String institutionId,
    String paperId, {
    String? operationId,
  }) async {
    final payload = {'institutionId': institutionId, 'paperId': paperId};
    if (operationId != null) payload['operationId'] = operationId;
    await _call('lockExamPaper', payload);
  }

  @override
  Stream<List<ExamPrintJob>> watchPrintJobs(
    String institutionId, {
    String? paperId,
  }) {
    Query<Map<String, dynamic>> query = _collection(
      institutionId,
      'exam_factory_print_jobs',
    ).orderBy('initiatedAt', descending: true);
    if (paperId != null) {
      query = query.where('paperId', isEqualTo: paperId);
    }
    return query.snapshots().map((items) => items.docs.map(_printJob).toList());
  }

  @override
  Future<Map<String, String>> generatePaperFiles(
    String institutionId,
    String paperId, {
    String? watermark,
  }) async {
    final payload = {'institutionId': institutionId, 'paperId': paperId};
    if (watermark != null) payload['watermark'] = watermark;
    final result = await _call('generateExamPaperFiles', payload);
    return {
      'questionPaperPath': (result?['questionPaperPath'] as String?) ?? '',
      'markingGuidePath': (result?['markingGuidePath'] as String?) ?? '',
    };
  }

  @override
  Future<String> getPaperDownloadUrl(
    String institutionId,
    String paperId,
    String fileType, {
    String? operationId,
  }) async {
    final payload = {
      'institutionId': institutionId,
      'paperId': paperId,
      'fileType': fileType,
    };
    if (operationId != null) payload['operationId'] = operationId;
    final result = await _call('getExamPaperDownloadUrl', payload);
    return (result?['url'] as String?) ?? '';
  }

  @override
  Future<String> recordPrintJob(
    String institutionId,
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
  }) async {
    final result = await _call('recordExamPrintJob', {
      'institutionId': institutionId,
      'paperId': paperId,
      'copies': copies,
      'extraCopies': extraCopies,
      'printer': printer ?? '',
      'paperSize': paperSize,
      'duplex': duplex,
      'includeQuestionPaper': includeQuestionPaper,
      'includeMarkingGuide': includeMarkingGuide,
      if (watermark != null) 'watermark': watermark,
      'isReprint': isReprint,
      if (reprintReason != null) 'reprintReason': reprintReason,
    });
    return (result?['jobId'] as String?) ?? '';
  }

  @override
  Future<void> completePrintJob(String institutionId, String jobId) => _call(
    'completeExamPrintJob',
    {'institutionId': institutionId, 'jobId': jobId},
  );

  @override
  Stream<List<(String id, String name, int capacity)>> watchVenues(
    String institutionId,
  ) => _firestore
      .collection('schools')
      .doc(institutionId)
      .collection('spaces')
      .orderBy('name')
      .snapshots()
      .map(
        (items) => items.docs
            .map(
              (doc) => (
                doc.id,
                (doc.data()['name'] as String?) ?? '',
                ((doc.data()['capacity'] as num?)?.toInt()) ?? 0,
              ),
            )
            .toList(),
      );

  ExamSitting _sitting(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _sittingFromSnap(doc);

  ExamSitting _sittingFromSnap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ExamSitting(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      seriesId: d['seriesId'] ?? '',
      paperId: d['paperId'] ?? '',
      venueId: d['venueId'] ?? '',
      venueName: d['venueName'] ?? '',
      startTime: _date(d['startTime']),
      durationMinutes: (d['durationMinutes'] as num?)?.toInt() ?? 60,
      createdAt: _dateOrNull(d['createdAt']),
      updatedAt: _dateOrNull(d['updatedAt']),
    );
  }

  ExamInvigilatorAssignment _invigilator(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return ExamInvigilatorAssignment(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      sittingId: d['sittingId'] ?? '',
      staffId: d['staffId'] ?? '',
      staffName: d['staffName'] ?? '',
      role: _enumByName(
        InvigilatorRole.values,
        d['role'],
        InvigilatorRole.assistant,
      ),
      assignedAt: _dateOrNull(d['assignedAt']),
    );
  }

  ExamAttendanceRecord _attendance(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return ExamAttendanceRecord(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      sittingId: d['sittingId'] ?? '',
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      status: _enumByName(
        ExamAttendanceStatus.values,
        d['status'],
        ExamAttendanceStatus.present,
      ),
      recordedBy: d['recordedBy'] ?? '',
      note: d['note'] ?? '',
      recordedAt: _dateOrNull(d['recordedAt']),
    );
  }

  ExamIncident _incident(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return ExamIncident(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      sittingId: d['sittingId'] ?? '',
      type: _enumByName(
        ExamIncidentType.values,
        d['type'],
        ExamIncidentType.other,
      ),
      description: d['description'] ?? '',
      reportedBy: d['reportedBy'] ?? '',
      studentIds: List<String>.from(d['studentIds'] ?? const []),
      status: _enumByName(
        ExamIncidentStatus.values,
        d['status'],
        ExamIncidentStatus.open,
      ),
      resolution: d['resolution'] ?? '',
      reportedAt: _dateOrNull(d['reportedAt']),
      resolvedAt: _dateOrNull(d['resolvedAt']),
    );
  }

  ExamMarkEntry _markEntry(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return ExamMarkEntry(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      paperId: d['paperId'] ?? '',
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      score: (d['score'] as num?)?.toDouble(),
      maximumMark: (d['maximumMark'] as num?)?.toDouble() ?? 0,
      status: _enumByName(
        MarkEntryStatus.values,
        d['status'],
        MarkEntryStatus.draft,
      ),
      isAbsent: d['isAbsent'] == true,
      remark: d['remark'] ?? '',
      enteredAt: _dateOrNull(d['enteredAt']),
      updatedAt: _dateOrNull(d['updatedAt']),
    );
  }

  @override
  Stream<List<ExamSitting>> watchSittings(
    String institutionId, {
    String? seriesId,
  }) {
    Query<Map<String, dynamic>> query = _collection(
      institutionId,
      'exam_factory_sittings',
    ).orderBy('startTime');
    if (seriesId != null) {
      query = query.where('seriesId', isEqualTo: seriesId);
    }
    return query.snapshots().map((items) => items.docs.map(_sitting).toList());
  }

  @override
  Stream<ExamSitting?> watchSitting(String institutionId, String sittingId) =>
      _collection(institutionId, 'exam_factory_sittings')
          .doc(sittingId)
          .snapshots()
          .map((doc) => doc.exists ? _sittingFromSnap(doc) : null);

  @override
  Future<String> saveSitting(
    String institutionId, {
    String? sittingId,
    required String paperId,
    required String venueId,
    String? venueName,
    required DateTime startTime,
    int? durationMinutes,
  }) async {
    final result = await _call('saveExamSitting', {
      'institutionId': institutionId,
      if (sittingId != null) 'sittingId': sittingId,
      'paperId': paperId,
      'venueId': venueId,
      if (venueName != null) 'venueName': venueName,
      'startTime': startTime.toUtc().toIso8601String(),
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
    });
    return (result?['sittingId'] as String?) ?? sittingId ?? '';
  }

  @override
  Stream<List<ExamInvigilatorAssignment>> watchInvigilators(
    String institutionId, {
    String? sittingId,
  }) {
    Query<Map<String, dynamic>> query = _collection(
      institutionId,
      'exam_factory_invigilators',
    ).orderBy('assignedAt', descending: true);
    if (sittingId != null) {
      query = query.where('sittingId', isEqualTo: sittingId);
    }
    return query.snapshots().map(
      (items) => items.docs.map(_invigilator).toList(),
    );
  }

  @override
  Future<String> assignInvigilator(
    String institutionId, {
    required String sittingId,
    required String staffId,
    String? staffName,
    required InvigilatorRole role,
  }) async {
    final result = await _call('assignExamInvigilator', {
      'institutionId': institutionId,
      'sittingId': sittingId,
      'staffId': staffId,
      if (staffName != null) 'staffName': staffName,
      'role': role.name,
    });
    return (result?['assignmentId'] as String?) ?? '';
  }

  @override
  Future<void> removeInvigilator(String institutionId, String assignmentId) =>
      _call('removeExamInvigilator', {
        'institutionId': institutionId,
        'assignmentId': assignmentId,
      });

  @override
  Stream<List<ExamAttendanceRecord>> watchAttendance(
    String institutionId, {
    required String sittingId,
  }) => _collection(institutionId, 'exam_factory_attendance')
      .where('sittingId', isEqualTo: sittingId)
      .orderBy('recordedAt', descending: true)
      .snapshots()
      .map((items) => items.docs.map(_attendance).toList());

  @override
  Future<void> recordAttendance(
    String institutionId, {
    required String sittingId,
    required String studentId,
    String? studentName,
    required ExamAttendanceStatus status,
    String? note,
    String? operationId,
  }) => _call('recordExamAttendance', {
    'institutionId': institutionId,
    'sittingId': sittingId,
    'studentId': studentId,
    if (studentName != null) 'studentName': studentName,
    'status': status.name,
    if (note != null) 'note': note,
    if (operationId != null) 'operationId': operationId,
  });

  @override
  Stream<List<ExamIncident>> watchIncidents(
    String institutionId, {
    String? sittingId,
  }) {
    Query<Map<String, dynamic>> query = _collection(
      institutionId,
      'exam_factory_incidents',
    ).orderBy('reportedAt', descending: true);
    if (sittingId != null) {
      query = query.where('sittingId', isEqualTo: sittingId);
    }
    return query.snapshots().map((items) => items.docs.map(_incident).toList());
  }

  @override
  Future<String> reportIncident(
    String institutionId, {
    String? incidentId,
    required String sittingId,
    required ExamIncidentType type,
    required String description,
    List<String> studentIds = const [],
  }) async {
    final result = await _call('reportExamIncident', {
      'institutionId': institutionId,
      if (incidentId != null) 'incidentId': incidentId,
      'sittingId': sittingId,
      'type': type.name,
      'description': description,
      'studentIds': studentIds,
    });
    return (result?['incidentId'] as String?) ?? incidentId ?? '';
  }

  @override
  Future<void> resolveIncident(
    String institutionId,
    String incidentId, {
    required String resolution,
  }) => _call('resolveExamIncident', {
    'institutionId': institutionId,
    'incidentId': incidentId,
    'resolution': resolution,
  });

  @override
  Stream<List<ExamMarkEntry>> watchMarkEntries(
    String institutionId, {
    required String paperId,
  }) => _collection(institutionId, 'exam_factory_marks')
      .where('paperId', isEqualTo: paperId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((items) => items.docs.map(_markEntry).toList());

  @override
  Future<void> saveMarkEntry(
    String institutionId, {
    required String paperId,
    required String studentId,
    String? studentName,
    double? score,
    bool isAbsent = false,
    String? remark,
    String? operationId,
  }) => _call('saveExamMarkEntry', {
    'institutionId': institutionId,
    'paperId': paperId,
    'studentId': studentId,
    if (studentName != null) 'studentName': studentName,
    if (score != null) 'score': score,
    'isAbsent': isAbsent,
    if (remark != null) 'remark': remark,
    if (operationId != null) 'operationId': operationId,
  });

  @override
  Future<int> submitMarks(
    String institutionId,
    String paperId, {
    String? operationId,
  }) async {
    final result = await _call('submitExamMarks', {
      'institutionId': institutionId,
      'paperId': paperId,
      if (operationId != null) 'operationId': operationId,
    });
    return (result?['submitted'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<Map<String, int>> approveResults(
    String institutionId,
    String paperId, {
    String? operationId,
  }) async {
    final result = await _call('approveExamResults', {
      'institutionId': institutionId,
      'paperId': paperId,
      if (operationId != null) 'operationId': operationId,
    });
    return {
      'approvedCount': (result?['approvedCount'] as num?)?.toInt() ?? 0,
      'totalEntries': (result?['totalEntries'] as num?)?.toInt() ?? 0,
    };
  }

  ExamAuditEntry _auditEntry(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return ExamAuditEntry(
      id: doc.id,
      action: d['action'] ?? '',
      actorId: d['actorId'] ?? '',
      role: d['role'] ?? '',
      at: _dateOrNull(d['at']),
    );
  }

  @override
  Stream<List<ExamAuditEntry>> watchAuditTrail(
    String institutionId, {
    String? paperId,
    String? questionId,
  }) {
    Query<Map<String, dynamic>> query = _collection(
      institutionId,
      'exam_factory_audit',
    ).orderBy('at', descending: true);
    if (paperId != null) {
      query = query.where('paperId', isEqualTo: paperId);
    }
    if (questionId != null) {
      query = query.where('questionId', isEqualTo: questionId);
    }
    return query.snapshots().map(
      (items) => items.docs.map(_auditEntry).toList(),
    );
  }

  ExamSeatAssignment _seat(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return ExamSeatAssignment(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      sittingId: d['sittingId'] ?? '',
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      seatNumber: d['seatNumber'] ?? '',
      assignedAt: _dateOrNull(d['assignedAt']),
    );
  }

  @override
  Stream<List<ExamSeatAssignment>> watchSeating(
    String institutionId, {
    required String sittingId,
  }) => _collection(institutionId, 'exam_factory_seating')
      .where('sittingId', isEqualTo: sittingId)
      .orderBy('seatNumber')
      .snapshots()
      .map((items) => items.docs.map(_seat).toList());

  @override
  Future<String> assignSeat(
    String institutionId, {
    required String sittingId,
    required String studentId,
    String? studentName,
    required String seatNumber,
  }) async {
    final result = await _call('assignExamSeat', {
      'institutionId': institutionId,
      'sittingId': sittingId,
      'studentId': studentId,
      if (studentName != null) 'studentName': studentName,
      'seatNumber': seatNumber,
    });
    return (result?['seatId'] as String?) ?? '';
  }

  @override
  Future<void> removeSeat(String institutionId, String seatId) => _call(
    'removeExamSeat',
    {'institutionId': institutionId, 'seatId': seatId},
  );

  ExamScriptRecord _script(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return ExamScriptRecord(
      id: doc.id,
      institutionId: d['institutionId'] ?? '',
      sittingId: d['sittingId'] ?? '',
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      status: _enumByName(
        ScriptStatus.values,
        d['status'],
        ScriptStatus.distributed,
      ),
      note: d['note'] ?? '',
      recordedAt: _dateOrNull(d['recordedAt']),
    );
  }

  @override
  Stream<List<ExamScriptRecord>> watchScripts(
    String institutionId, {
    required String sittingId,
  }) => _collection(institutionId, 'exam_factory_scripts')
      .where('sittingId', isEqualTo: sittingId)
      .orderBy('recordedAt', descending: true)
      .snapshots()
      .map((items) => items.docs.map(_script).toList());

  @override
  Future<void> recordScript(
    String institutionId, {
    required String sittingId,
    required String studentId,
    String? studentName,
    required ScriptStatus status,
    String? note,
    String? operationId,
  }) => _call('recordExamScript', {
    'institutionId': institutionId,
    'sittingId': sittingId,
    'studentId': studentId,
    if (studentName != null) 'studentName': studentName,
    'status': status.name,
    if (note != null) 'note': note,
    if (operationId != null) 'operationId': operationId,
  });
}
