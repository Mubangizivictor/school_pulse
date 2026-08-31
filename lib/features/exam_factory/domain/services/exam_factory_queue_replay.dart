import 'dart:convert';

import 'package:school_pulse/features/exam_factory/data/datasources/exam_factory_queue_data_source.dart';
import 'package:school_pulse/features/exam_factory/domain/entities/exam_factory_entities.dart';
import 'package:school_pulse/features/exam_factory/domain/repositories/exam_factory_repository.dart';

/// Deserializes one queued [ExamFactoryQueueItem] and re-dispatches it to
/// the matching [ExamFactoryRepository] method with its original
/// `operationId`, so the target Cloud Function's own idempotency guard (the
/// same `operationId`/deterministic-doc-id checks the online path already
/// relies on) makes a retried replay a no-op rather than a duplicate.
///
/// This is the only place that needs to know the payload shape for each
/// [ExamFactoryQueueActionType] - the cubit only serializes and enqueues;
/// this deserializes and calls back into the same repository the cubit
/// would have called directly if it had been online.
class ExamFactoryQueueReplay {
  final ExamFactoryRepository repository;

  const ExamFactoryQueueReplay({required this.repository});

  Future<void> replay(ExamFactoryQueueItem item) async {
    final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
    final operationId = payload['operationId'] as String?;

    switch (item.actionType) {
      case ExamFactoryQueueActionType.saveQuestionDraft:
        await repository.saveQuestionDraft(
          ExamQuestion(
            id: payload['questionId'] as String,
            seriesId: payload['seriesId'] as String,
            institutionId: item.institutionId,
            classId: payload['classId'] as String,
            subjectId: payload['subjectId'] as String,
            topic: payload['topic'] as String? ?? '',
            creatorId: item.actorId,
            text: payload['text'] as String? ?? '',
            marks: (payload['marks'] as num?)?.toInt() ?? 0,
            version: 1,
            type: ExamQuestionType.values.firstWhere(
              (t) => t.name == payload['type'],
              orElse: () => ExamQuestionType.shortAnswer,
            ),
            status: ExamQuestionStatus.draft,
            difficulty: ExamQuestionDifficulty.values.firstWhere(
              (d) => d.name == payload['difficulty'],
              orElse: () => ExamQuestionDifficulty.medium,
            ),
            suggestedAnswer: payload['suggestedAnswer'] as String? ?? '',
            markingGuide: payload['markingGuide'] as String? ?? '',
            teacherNotes: payload['teacherNotes'] as String? ?? '',
          ),
          operationId: operationId,
        );
        return;

      case ExamFactoryQueueActionType.submitQuestion:
        await repository.submitQuestion(
          item.institutionId,
          payload['questionId'] as String,
          academicYearId: payload['academicYearId'] as String?,
          operationId: operationId,
        );
        return;

      case ExamFactoryQueueActionType.moderateQuestion:
        await repository.moderateQuestion(
          item.institutionId,
          payload['questionId'] as String,
          ExamQuestionStatus.values.firstWhere(
            (s) => s.name == payload['decision'],
            orElse: () => ExamQuestionStatus.changesRequested,
          ),
          comment: payload['comment'] as String?,
          operationId: operationId,
        );
        return;

      case ExamFactoryQueueActionType.recordAttendance:
        await repository.recordAttendance(
          item.institutionId,
          sittingId: payload['sittingId'] as String,
          studentId: payload['studentId'] as String,
          studentName: payload['studentName'] as String?,
          status: ExamAttendanceStatus.values.firstWhere(
            (s) => s.name == payload['status'],
            orElse: () => ExamAttendanceStatus.present,
          ),
          note: payload['note'] as String?,
          operationId: operationId,
        );
        return;

      case ExamFactoryQueueActionType.reportIncident:
        await repository.reportIncident(
          item.institutionId,
          incidentId: payload['incidentId'] as String?,
          sittingId: payload['sittingId'] as String,
          type: ExamIncidentType.values.firstWhere(
            (t) => t.name == payload['type'],
            orElse: () => ExamIncidentType.other,
          ),
          description: payload['description'] as String? ?? '',
          studentIds:
              (payload['studentIds'] as List?)?.cast<String>() ?? const [],
        );
        return;

      case ExamFactoryQueueActionType.saveMarkEntry:
        await repository.saveMarkEntry(
          item.institutionId,
          paperId: payload['paperId'] as String,
          studentId: payload['studentId'] as String,
          studentName: payload['studentName'] as String?,
          score: (payload['score'] as num?)?.toDouble(),
          isAbsent: payload['isAbsent'] as bool? ?? false,
          remark: payload['remark'] as String?,
          operationId: operationId,
        );
        return;
    }
  }
}
