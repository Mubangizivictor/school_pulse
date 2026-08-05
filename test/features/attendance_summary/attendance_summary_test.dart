import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/attendance_summary/domain/attendance_summary.dart';

void main() {
  group('AttendanceRateCalculator.summarize', () {
    test('computes a simple present/total rate', () {
      final summary = AttendanceRateCalculator.summarize([
        MarkClassification.present,
        MarkClassification.present,
        MarkClassification.unauthorisedAbsent,
        MarkClassification.present,
      ]);

      expect(summary.present, 3);
      expect(summary.unauthorisedAbsent, 1);
      expect(summary.totalMarked, 4);
      expect(summary.ratePercent, closeTo(75.0, 0.001));
    });

    test('rate is null, not 0, when nothing was marked', () {
      final summary = AttendanceRateCalculator.summarize(const []);

      expect(summary.totalMarked, 0);
      expect(summary.ratePercent, isNull);
    });

    test(
      'authorised absences count toward the denominator but not the rate',
      () {
        final summary = AttendanceRateCalculator.summarize([
          MarkClassification.present,
          MarkClassification.authorisedAbsent,
        ]);

        expect(summary.totalMarked, 2);
        expect(summary.ratePercent, closeTo(50.0, 0.001));
      },
    );

    test('a perfect record rates 100', () {
      final summary = AttendanceRateCalculator.summarize([
        MarkClassification.present,
        MarkClassification.present,
      ]);

      expect(summary.ratePercent, 100.0);
    });
  });

  group('AttendanceRateCalculator.summarizeAgainstDaysOpen', () {
    test('matches the days-open-normalized formula', () {
      final summary = AttendanceRateCalculator.summarizeAgainstDaysOpen(
        presentDays: 18,
        daysOpen: 20,
      );

      expect(summary.present, 18);
      expect(summary.unauthorisedAbsent, 2);
      expect(summary.totalMarked, 20);
      expect(summary.ratePercent, 90.0);
    });

    test('rate is null when no days are open', () {
      final summary = AttendanceRateCalculator.summarizeAgainstDaysOpen(
        presentDays: 0,
        daysOpen: 0,
      );

      expect(summary.ratePercent, isNull);
    });
  });

  group('classifyStudentStatus', () {
    test('present and late both count as present', () {
      expect(classifyStudentStatus('present'), MarkClassification.present);
      expect(classifyStudentStatus('late'), MarkClassification.present);
    });

    test('absent counts as unauthorised', () {
      expect(
        classifyStudentStatus('absent'),
        MarkClassification.unauthorisedAbsent,
      );
    });

    test(
      'an unrecognised status falls back to unauthorised, never silently present',
      () {
        expect(
          classifyStudentStatus('whatever'),
          MarkClassification.unauthorisedAbsent,
        );
      },
    );
  });

  group('classifyBoardingStatus', () {
    test('present and late count as present', () {
      expect(classifyBoardingStatus('Present'), MarkClassification.present);
      expect(classifyBoardingStatus('Late'), MarkClassification.present);
    });

    test(
      'leave and sick count as authorised absence, distinct from a bare absent',
      () {
        expect(
          classifyBoardingStatus('Leave'),
          MarkClassification.authorisedAbsent,
        );
        expect(
          classifyBoardingStatus('Sick'),
          MarkClassification.authorisedAbsent,
        );
        expect(
          classifyBoardingStatus('Absent'),
          MarkClassification.unauthorisedAbsent,
        );
      },
    );

    test('an unrecognised status falls back to unauthorised', () {
      expect(
        classifyBoardingStatus('Mystery'),
        MarkClassification.unauthorisedAbsent,
      );
    });
  });
}
