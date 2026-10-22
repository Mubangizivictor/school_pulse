import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/finance/data/datasources/bursar_report_release_remote_data_source.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';
import 'package:school_pulse/features/finance/presentation/screens/report_release/report_release_audit_sheet.dart';

ReportReleaseException _exc() => const ReportReleaseException(
  id: 'exc1',
  status: 'revoked',
  reasonCode: ExceptionReasonCode.paymentPlan,
  reasonNote: 'Three-instalment plan',
  outstandingBalanceUgxAtRelease: 300000,
  auditTrail: [
    ExceptionAuditEntry(action: 'grant', actorName: 'Bursar Jane'),
    ExceptionAuditEntry(
      action: 'revoke',
      actorName: 'Director Musa',
      note: 'Plan defaulted',
    ),
  ],
);

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final label = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('audit sheet renders report + exception history ($label)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: brightness == Brightness.dark
              ? AppTheme.dark()
              : AppTheme.light(),
          home: Scaffold(
            body: ReportReleaseAuditSheet(
              studentName: 'Aisha Namwano',
              history: ReportCardHistory(
                reportAudit: const [
                  ReportAuditEntry(
                    action: 'financial_access.released',
                    actorName: 'System',
                    reason: 'Release exception (paymentPlan).',
                  ),
                ],
                exceptions: [_exc()],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Aisha Namwano'), findsOneWidget);
      expect(find.text('Report access log'), findsOneWidget);
      expect(find.text('Release exceptions'), findsOneWidget);
      expect(find.textContaining('released'), findsWidgets);
      expect(find.textContaining('Payment plan · revoked'), findsOneWidget);
      // exception audit trail lines
      expect(find.textContaining('grant — Bursar Jane'), findsOneWidget);
      expect(
        find.textContaining('revoke — Director Musa (Plan defaulted)'),
        findsOneWidget,
      );
    });
  }

  testWidgets('empty history shows the muted placeholders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ReportReleaseAuditSheet(
            studentName: 'X',
            history: ReportCardHistory(reportAudit: [], exceptions: []),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No access-log entries yet.'), findsOneWidget);
    expect(find.text('No release exceptions for this period.'), findsOneWidget);
  });
}
