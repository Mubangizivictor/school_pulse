import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/reports/domain/reporting.dart';

void main() {
  group('ReportRegistry', () {
    test('has unique report keys', () {
      final keys = ReportRegistry.definitions.map((report) => report.reportKey);
      expect(keys.toSet().length, keys.length);
    });

    test('defines source module, version, and output for every report', () {
      for (final report in ReportRegistry.definitions) {
        expect(report.moduleKey, isNotEmpty);
        expect(report.version, greaterThan(0));
        expect(report.supportedFormats, isNotEmpty);
      }
    });
  });

  group('ReportAccessResolver', () {
    const resolver = ReportAccessResolver();
    final finance = ReportRegistry.byKey('finance.collections')!;

    test('hides disabled-module reports', () {
      final decision = resolver.resolve(
        report: finance,
        enabledModules: const {'students'},
        permissions: const {
          Permission.reportsView,
          Permission.reportsViewSensitive,
        },
        mfaEnabled: true,
      );
      expect(decision.canView, isFalse);
    });

    test('requires a sensitive-report grant', () {
      final decision = resolver.resolve(
        report: finance,
        enabledModules: const {'finance'},
        permissions: const {Permission.reportsView},
        mfaEnabled: true,
      );
      expect(decision.canView, isFalse);
    });

    test('separates view from export and flags missing MFA', () {
      final decision = resolver.resolve(
        report: finance,
        enabledModules: const {'finance'},
        permissions: const {
          Permission.reportsView,
          Permission.reportsViewSensitive,
        },
        mfaEnabled: false,
      );
      expect(decision.canView, isTrue);
      expect(decision.canExport, isFalse);
      expect(decision.requiresMfa, isTrue);
    });
  });

  test('CSV export escapes commas, quotes and line breaks', () {
    expect(
      reportCsv(
        headers: const ['Name', 'Note'],
        rows: const [
          ['A, B', 'He said "yes"'],
          ['C', 'one\ntwo'],
        ],
      ),
      'Name,Note\r\n"A, B","He said ""yes"""\r\nC,"one\ntwo"',
    );
  });
}
