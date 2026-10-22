import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/exam_factory/domain/entities/exam_factory_entities.dart';

void main() {
  group('ExamPaper', () {
    ExamPaper paper({required int total}) => ExamPaper(
      id: 'paper-1',
      seriesId: 'series-1',
      institutionId: 'school-1',
      classId: 'p6',
      subjectId: 'maths',
      title: 'P6 Mathematics',
      targetMarks: 100,
      totalMarks: total,
      version: 1,
      status: ExamPaperStatus.draft,
    );

    test('validates total marks before an approval request', () {
      expect(paper(total: 100).isMarksValid, isTrue);
      expect(paper(total: 95).isMarksValid, isFalse);
    });
  });

  test('approved questions are distinguishable from editable drafts', () {
    expect(ExamQuestionStatus.draft, isNot(ExamQuestionStatus.approved));
    expect(
      ExamQuestionStatus.changesRequested,
      isNot(ExamQuestionStatus.usedInPaper),
    );
  });

  group('ExamQuestion.isEditable', () {
    ExamQuestion question(ExamQuestionStatus status) => ExamQuestion(
      id: 'q1',
      seriesId: 'series-1',
      institutionId: 'school-1',
      classId: 'p6',
      subjectId: 'maths',
      topic: 'Fractions',
      creatorId: 'teacher-1',
      text: 'Simplify 3/4 + 1/8',
      marks: 5,
      version: 1,
      type: ExamQuestionType.shortAnswer,
      status: status,
    );

    test('draft and changesRequested are editable', () {
      expect(question(ExamQuestionStatus.draft).isEditable, isTrue);
      expect(question(ExamQuestionStatus.changesRequested).isEditable, isTrue);
    });

    test('submitted, approved and usedInPaper are not editable', () {
      expect(question(ExamQuestionStatus.submitted).isEditable, isFalse);
      expect(question(ExamQuestionStatus.approved).isEditable, isFalse);
      expect(question(ExamQuestionStatus.usedInPaper).isEditable, isFalse);
    });
  });

  group('ExamPaper.isLocked', () {
    ExamPaper paper(ExamPaperStatus status) => ExamPaper(
      id: 'paper-1',
      seriesId: 'series-1',
      institutionId: 'school-1',
      classId: 'p6',
      subjectId: 'maths',
      title: 'P6 Mathematics',
      targetMarks: 100,
      totalMarks: 100,
      version: 1,
      status: status,
    );

    test('locked, printReady, printed and administered are locked', () {
      expect(paper(ExamPaperStatus.locked).isLocked, isTrue);
      expect(paper(ExamPaperStatus.printReady).isLocked, isTrue);
      expect(paper(ExamPaperStatus.printed).isLocked, isTrue);
      expect(paper(ExamPaperStatus.administered).isLocked, isTrue);
    });

    test('draft and approved are not locked', () {
      expect(paper(ExamPaperStatus.draft).isLocked, isFalse);
      expect(paper(ExamPaperStatus.approved).isLocked, isFalse);
    });
  });

  group('ExamPaper.filesGenerated', () {
    ExamPaper paper({
      String questionPaperPath = '',
      String markingGuidePath = '',
      int generatedFilesVersion = 0,
      int version = 1,
    }) => ExamPaper(
      id: 'paper-1',
      seriesId: 'series-1',
      institutionId: 'school-1',
      classId: 'p6',
      subjectId: 'maths',
      title: 'P6 Mathematics',
      targetMarks: 100,
      totalMarks: 100,
      version: version,
      status: ExamPaperStatus.locked,
      questionPaperPath: questionPaperPath,
      markingGuidePath: markingGuidePath,
      generatedFilesVersion: generatedFilesVersion,
    );

    test('false when files were never generated', () {
      expect(paper().filesGenerated, isFalse);
    });

    test('false when generated files are stale for a newer version', () {
      expect(
        paper(
          questionPaperPath: 'a.pdf',
          markingGuidePath: 'b.pdf',
          generatedFilesVersion: 1,
          version: 2,
        ).filesGenerated,
        isFalse,
      );
    });

    test('true when both files exist for the current version', () {
      expect(
        paper(
          questionPaperPath: 'a.pdf',
          markingGuidePath: 'b.pdf',
          generatedFilesVersion: 1,
          version: 1,
        ).filesGenerated,
        isTrue,
      );
    });
  });

  group('ExamSitting.endTime', () {
    test('adds the duration to the start time', () {
      final sitting = ExamSitting(
        id: 'sitting-1',
        institutionId: 'school-1',
        seriesId: 'series-1',
        paperId: 'paper-1',
        venueId: 'venue-1',
        startTime: DateTime(2026, 9, 1, 9, 0),
        durationMinutes: 90,
      );
      expect(sitting.endTime, DateTime(2026, 9, 1, 10, 30));
    });
  });
}
