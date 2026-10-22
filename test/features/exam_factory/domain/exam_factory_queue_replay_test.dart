import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/exam_factory/data/datasources/exam_factory_queue_data_source.dart';
import 'package:school_pulse/features/exam_factory/domain/entities/exam_factory_entities.dart';
import 'package:school_pulse/features/exam_factory/domain/repositories/exam_factory_repository.dart';
import 'package:school_pulse/features/exam_factory/domain/services/exam_factory_queue_replay.dart';

class _RecordingRepository implements ExamFactoryRepository {
  final List<String> calls = [];
  final Map<String, dynamic> lastArgs = {};

  @override
  Future<void> saveQuestionDraft(
    ExamQuestion question, {
    String? operationId,
  }) async {
    calls.add('saveQuestionDraft');
    lastArgs['question'] = question;
    lastArgs['operationId'] = operationId;
  }

  @override
  Future<void> submitQuestion(
    String institutionId,
    String questionId, {
    String? academicYearId,
    String? operationId,
  }) async {
    calls.add('submitQuestion');
    lastArgs['questionId'] = questionId;
    lastArgs['operationId'] = operationId;
  }

  @override
  Future<void> moderateQuestion(
    String institutionId,
    String questionId,
    ExamQuestionStatus decision, {
    String? comment,
    String? operationId,
  }) async {
    calls.add('moderateQuestion');
    lastArgs['decision'] = decision;
    lastArgs['comment'] = comment;
  }

  @override
  Future<void> recordAttendance(
    String institutionId, {
    required String sittingId,
    required String studentId,
    String? studentName,
    required ExamAttendanceStatus status,
    String? note,
    String? operationId,
  }) async {
    calls.add('recordAttendance');
    lastArgs['status'] = status;
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
    calls.add('reportIncident');
    lastArgs['incidentId'] = incidentId;
    lastArgs['type'] = type;
    return incidentId ?? 'generated';
  }

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
  }) async {
    calls.add('saveMarkEntry');
    lastArgs['score'] = score;
    lastArgs['isAbsent'] = isAbsent;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ExamFactoryQueueReplay', () {
    late _RecordingRepository repository;
    late ExamFactoryQueueReplay replay;

    setUp(() {
      repository = _RecordingRepository();
      replay = ExamFactoryQueueReplay(repository: repository);
    });

    ExamFactoryQueueItem item(
      ExamFactoryQueueActionType type,
      Map<String, dynamic> payload,
    ) => ExamFactoryQueueItem(
      idempotencyKey: 'key-1',
      institutionId: 'school-1',
      actorId: 'teacher-1',
      createdAt: DateTime(2026, 1, 1),
      actionType: type,
      payloadJson: jsonEncode({'operationId': 'key-1', ...payload}),
    );

    test('replays a queued question draft', () async {
      await replay.replay(
        item(ExamFactoryQueueActionType.saveQuestionDraft, {
          'questionId': 'q1',
          'seriesId': 's1',
          'classId': 'p6',
          'subjectId': 'maths',
          'topic': 'Fractions',
          'type': 'shortAnswer',
          'text': 'Simplify 3/4 + 1/8',
          'marks': 5,
          'difficulty': 'medium',
        }),
      );
      expect(repository.calls, ['saveQuestionDraft']);
      final question = repository.lastArgs['question'] as ExamQuestion;
      expect(question.id, 'q1');
      expect(question.marks, 5);
      expect(repository.lastArgs['operationId'], 'key-1');
    });

    test('replays a queued attendance record', () async {
      await replay.replay(
        item(ExamFactoryQueueActionType.recordAttendance, {
          'sittingId': 'sitting-1',
          'studentId': 'student-1',
          'status': 'absent',
        }),
      );
      expect(repository.calls, ['recordAttendance']);
      expect(repository.lastArgs['status'], ExamAttendanceStatus.absent);
    });

    test(
      'replays a queued incident report with its client-generated id',
      () async {
        await replay.replay(
          item(ExamFactoryQueueActionType.reportIncident, {
            'incidentId': 'incident-123',
            'sittingId': 'sitting-1',
            'type': 'lateArrival',
            'description': 'Candidate arrived 10 minutes late.',
            'studentIds': <String>[],
          }),
        );
        expect(repository.calls, ['reportIncident']);
        expect(repository.lastArgs['incidentId'], 'incident-123');
        expect(repository.lastArgs['type'], ExamIncidentType.lateArrival);
      },
    );

    test('replays a queued mark entry, including absent', () async {
      await replay.replay(
        item(ExamFactoryQueueActionType.saveMarkEntry, {
          'paperId': 'paper-1',
          'studentId': 'student-1',
          'isAbsent': true,
        }),
      );
      expect(repository.calls, ['saveMarkEntry']);
      expect(repository.lastArgs['isAbsent'], isTrue);
      expect(repository.lastArgs['score'], isNull);
    });
  });
}
