import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';
import 'package:school_pulse/features/teacher/presentation/screens/report_making/widgets/report_card_body.dart';

void main() {
  Widget wrap(CanonicalReportCard card) => MaterialApp(
    home: Scaffold(body: ReportCardBody(card: card)),
  );

  testWidgets('an unsigned report shows the DRAFT NOT OFFICIAL watermark', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const CanonicalReportCard(
          reportCardId: 'rc1',
          schoolId: 'schoolA',
          studentId: 'studentA',
          studentName: 'Jane Doe',
          academicYearId: '2026',
          termId: 't2',
          classId: 'p7',
          academicStatus: AcademicWorkflowStatus.generated,
          isFinalized: false,
        ),
      ),
    );

    expect(find.text('DRAFT — NOT OFFICIAL'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
  });

  testWidgets(
    'a report submitted to Dean but not yet signed shows AWAITING SIGNATURES',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const CanonicalReportCard(
            reportCardId: 'rc1',
            schoolId: 'schoolA',
            studentId: 'studentA',
            studentName: 'Jane Doe',
            academicYearId: '2026',
            termId: 't2',
            classId: 'p7',
            academicStatus: AcademicWorkflowStatus.submittedToDean,
            isFinalized: false,
          ),
        ),
      );

      expect(find.text('AWAITING SIGNATURES'), findsOneWidget);
    },
  );

  testWidgets('a finalized report shows no watermark at all', (tester) async {
    await tester.pumpWidget(
      wrap(
        const CanonicalReportCard(
          reportCardId: 'rc1',
          schoolId: 'schoolA',
          studentId: 'studentA',
          studentName: 'Jane Doe',
          academicYearId: '2026',
          termId: 't2',
          classId: 'p7',
          academicStatus: AcademicWorkflowStatus.academicallyFinalized,
          isFinalized: true,
        ),
      ),
    );

    expect(find.text('DRAFT — NOT OFFICIAL'), findsNothing);
    expect(find.text('AWAITING SIGNATURES'), findsNothing);
  });

  testWidgets(
    'incomplete subjects surface a visible warning, not a silent gap',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const CanonicalReportCard(
            reportCardId: 'rc1',
            schoolId: 'schoolA',
            studentId: 'studentA',
            studentName: 'Jane Doe',
            academicYearId: '2026',
            termId: 't2',
            classId: 'p7',
            academicStatus: AcademicWorkflowStatus.generated,
            subjectResults: [
              SubjectResultSnapshot(
                subjectId: 'English',
                isComplete: false,
                incompleteReason: 'absent',
              ),
            ],
          ),
        ),
      );

      expect(
        find.textContaining('1 subject(s) are incomplete'),
        findsOneWidget,
      );
    },
  );

  testWidgets('a finalized report shows its financial-access chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const CanonicalReportCard(
          reportCardId: 'rc1',
          schoolId: 'schoolA',
          studentId: 'studentA',
          studentName: 'Jane Doe',
          academicYearId: '2026',
          termId: 't2',
          classId: 'p7',
          academicStatus: AcademicWorkflowStatus.academicallyFinalized,
          isFinalized: true,
          financialAccessStatus: FinancialAccessStatus.held,
        ),
      ),
    );

    expect(find.text('Held by Bursar'), findsOneWidget);
  });

  testWidgets(
    'shows a signed decision by the actual actor name, not a placeholder',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const CanonicalReportCard(
            reportCardId: 'rc1',
            schoolId: 'schoolA',
            studentId: 'studentA',
            studentName: 'Jane Doe',
            academicYearId: '2026',
            termId: 't2',
            classId: 'p7',
            academicStatus: AcademicWorkflowStatus.deanSigned,
            deanDecision: StageDecision(
              decision: 'signed',
              actorUid: 'deanA',
              actorDisplayName: 'Dean Grace',
              reportVersion: 1,
            ),
          ),
        ),
      );

      expect(find.textContaining('Dean Grace'), findsOneWidget);
    },
  );
}
