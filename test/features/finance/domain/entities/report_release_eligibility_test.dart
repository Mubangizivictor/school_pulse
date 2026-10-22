import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';

void main() {
  group('ReportReleaseUiStatus', () {
    test('maps every server id, defaulting unknown to withheldForFees', () {
      expect(
        ReportReleaseUiStatus.fromId('automaticallyAvailable'),
        ReportReleaseUiStatus.automaticallyAvailable,
      );
      expect(
        ReportReleaseUiStatus.fromId('pendingApproval'),
        ReportReleaseUiStatus.pendingApproval,
      );
      expect(
        ReportReleaseUiStatus.fromId('exceptionExpired'),
        ReportReleaseUiStatus.exceptionExpired,
      );
      expect(
        ReportReleaseUiStatus.fromId('nonsense'),
        ReportReleaseUiStatus.withheldForFees,
      );
    });

    test('every status has a distinct human label', () {
      final labels = ReportReleaseUiStatus.values.map((s) => s.label).toSet();
      expect(labels.length, ReportReleaseUiStatus.values.length);
    });
  });

  group('ClearanceResult.summary', () {
    test('minimum-percentage shows percent paid + policy verdict', () {
      const cleared = ClearanceResult(
        cleared: true,
        mode: 'minimumPercentage',
        balanceUgx: 40000,
        percentPaid: 62,
      );
      expect(cleared.summary, contains('62% paid'));
      expect(cleared.summary, contains('meets policy'));

      const notCleared = ClearanceResult(
        cleared: false,
        mode: 'minimumPercentage',
        balanceUgx: 60000,
        percentPaid: 40,
      );
      expect(notCleared.summary, contains('below policy'));
    });

    test('full-balance and selected-categories have their own phrasing', () {
      expect(
        const ClearanceResult(
          cleared: false,
          mode: 'fullBalance',
          balanceUgx: 100,
        ).summary,
        'Balance outstanding',
      );
      expect(
        const ClearanceResult(
          cleared: true,
          mode: 'selectedCategories',
          balanceUgx: 0,
        ).summary,
        'Selected fees cleared',
      );
    });
  });

  group('ReportReleaseEligibilityRow.fromMap', () {
    test('parses period, status, balance and a nested exception', () {
      final row = ReportReleaseEligibilityRow.fromMap({
        'reportCardId': 'rc1',
        'studentId': 'stu1',
        'studentName': 'Aisha N',
        'classId': 'p7',
        'streamId': 'east',
        'academicYearId': '2026',
        'termId': 't2',
        'financialAccessStatus': 'released',
        'financialAccessSource': 'exception',
        'uiStatus': 'exceptionActive',
        'balanceUgx': 250000,
        'clearance': {
          'cleared': false,
          'mode': 'fullBalance',
          'balanceUgx': 250000,
        },
        'exception': {
          'id': 'exc1',
          'status': 'active',
          'reasonCode': 'paymentPlan',
          'outstandingBalanceUgxAtRelease': 250000,
          'expiresAt': 1893456000000,
          'auditTrail': [
            {
              'action': 'grant',
              'actorName': 'Bursar Jane',
              'at': 1700000000000,
            },
          ],
        },
      });

      expect(row.periodLabel, 'Term t2 · 2026');
      expect(row.uiStatus, ReportReleaseUiStatus.exceptionActive);
      expect(row.isBursarOverride, isFalse);
      expect(row.exception, isNotNull);
      expect(row.exception!.reasonCode, ExceptionReasonCode.paymentPlan);
      expect(row.exception!.expiresAt, isNotNull);
      expect(row.exception!.auditTrail.single.action, 'grant');
      // redaction: no raw uid ever present on the parsed model
      expect(row.exception!.auditTrail.single.actorName, 'Bursar Jane');
    });

    test('a bursar direct override is flagged', () {
      final row = ReportReleaseEligibilityRow.fromMap({
        'reportCardId': 'rc1',
        'studentId': 'stu1',
        'studentName': 'X',
        'classId': 'p7',
        'academicYearId': '2026',
        'termId': 't2',
        'financialAccessStatus': 'released',
        'financialAccessSource': 'bursar',
        'uiStatus': 'exceptionActive',
        'balanceUgx': 0,
        'clearance': {'cleared': false, 'mode': 'fullBalance', 'balanceUgx': 0},
      });
      expect(row.isBursarOverride, isTrue);
    });
  });

  group('FinancialClearancePolicy', () {
    test('round-trips through toMap/fromMap', () {
      const p = FinancialClearancePolicy(
        mode: ClearanceMode.selectedCategories,
        feeCategoryIds: ['tuition', 'boarding'],
        minimumPercentagePaid: 75,
        compulsoryOnly: false,
        restrictionMessage: 'See the bursar.',
        secondApproverRequired: true,
        secondApproverArrearsThresholdUgx: 500000,
        secondApproverRoles: ['headTeacher'],
        defaultExpiryDays: 30,
      );
      final back = FinancialClearancePolicy.fromMap(p.toMap());
      expect(back, p);
    });

    test('defaults an absent map to fullBalance + default message', () {
      final p = FinancialClearancePolicy.fromMap(const {});
      expect(p.mode, ClearanceMode.fullBalance);
      expect(p.compulsoryOnly, isTrue);
      expect(
        p.restrictionMessage,
        FinancialClearancePolicy.defaultRestrictionMessage,
      );
    });
  });
}
