import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/finance/presentation/shell/bursar_section.dart';

/// Area 1 — Bursar console deep-link routing.
///
/// Two layers are covered:
///  1. [BursarSection.fromLocation] — the resolver the desktop/tablet shell
///     runs on every build (direct URL load, browser refresh, back/forward,
///     shared links) to pick the active section from the live URL.
///  2. A source-level check that `router.dart` wires all 11
///     `/staff/bursar/<slug>` sub-routes to `BursarShell(section: …)` with
///     the matching section — following this repo's established
///     router-structure test convention (see
///     test/app/router_owner_staff_gate_test.dart).
void main() {
  group('BursarSection.fromLocation', () {
    test('resolves every section slug from its canonical path', () {
      for (final s in BursarSection.values) {
        expect(
          BursarSection.fromLocation('/staff/bursar/${s.slug}'),
          s,
          reason: 'slug "${s.slug}" must resolve to $s',
        );
      }
    });

    test('resolves a nested path under a section to that section', () {
      expect(
        BursarSection.fromLocation('/staff/bursar/suppliers/new'),
        BursarSection.suppliers,
      );
      expect(
        BursarSection.fromLocation('/staff/bursar/petty-cash/replenish'),
        BursarSection.pettyCash,
      );
      expect(
        BursarSection.fromLocation('/staff/bursar/reports/cashbook'),
        BursarSection.reports,
      );
    });

    test('bare /staff/bursar and unknown tails fall back to overview', () {
      expect(
        BursarSection.fromLocation('/staff/bursar'),
        BursarSection.overview,
      );
      expect(
        BursarSection.fromLocation('/staff/bursar/'),
        BursarSection.overview,
      );
      expect(
        BursarSection.fromLocation('/staff/bursar/does-not-exist'),
        BursarSection.overview,
      );
    });

    test('legacy lookup + student statement paths map to Students & fees', () {
      expect(
        BursarSection.fromLocation('/staff/bursar/lookup'),
        BursarSection.students,
      );
      expect(
        BursarSection.fromLocation('/staff/bursar/student/abc123/bills'),
        BursarSection.students,
      );
    });

    test('cash-bank hyphenated slug resolves (not split on the dash)', () {
      expect(
        BursarSection.fromLocation('/staff/bursar/cash-bank'),
        BursarSection.cashBank,
      );
    });
  });

  group('BursarSection mobile-tab mapping', () {
    test('exactly the four bottom-nav sections carry a mobileTab', () {
      final withTab = BursarSection.values
          .where((s) => s.mobileTab != null)
          .toList();
      expect(
        withTab,
        containsAll(<BursarSection>[
          BursarSection.overview,
          BursarSection.students,
          BursarSection.approvals,
          BursarSection.cashBank,
        ]),
      );
      expect(withTab.length, 4);
    });

    test('mobileTab indices are unique and within the 5-tab bar', () {
      final tabs = BursarSection.values
          .map((s) => s.mobileTab)
          .whereType<int>()
          .toList();
      expect(
        tabs.toSet().length,
        tabs.length,
        reason: 'no duplicate tab index',
      );
      expect(tabs.every((t) => t >= 0 && t < 5), isTrue);
      expect(BursarSection.moreTabIndex, 4);
    });

    test('tool sections have no tab (they open on the More stack)', () {
      for (final s in [
        BursarSection.budget,
        BursarSection.expenses,
        BursarSection.suppliers,
        BursarSection.pettyCash,
        BursarSection.payroll,
        BursarSection.reports,
        BursarSection.audit,
      ]) {
        expect(s.mobileTab, isNull, reason: '$s must fall back to More');
      }
    });
  });

  group('router.dart wiring', () {
    late String source;

    setUpAll(() {
      source = File('lib/app/router.dart').readAsStringSync();
    });

    test('every section slug has a GoRoute under /staff/bursar', () {
      for (final s in BursarSection.values) {
        expect(
          source.contains("path: '${s.slug}'"),
          isTrue,
          reason: 'router must declare a sub-route for "${s.slug}"',
        );
      }
    });

    test('every section route builds BursarShell(section: <matching>)', () {
      for (final s in BursarSection.values) {
        final enumRef = 'BursarSection.${s.name}';
        expect(
          source.contains('BursarShell(section: $enumRef)'),
          isTrue,
          reason: 'route for "${s.slug}" must pass section: $enumRef',
        );
      }
    });

    test('no section route still uses the removed initialTab parameter', () {
      // The bare /staff/bursar builder + the student-bills builder are the
      // only BursarShell call sites besides the 11 sections; none may carry
      // the old int tab coupling.
      final bursarBlockStart = source.indexOf("path: '/staff/bursar'");
      final bursarBlockEnd = source.indexOf(
        "path: '/staff/nurse'",
        bursarBlockStart,
      );
      final block = source.substring(bursarBlockStart, bursarBlockEnd);
      expect(block.contains('initialTab'), isFalse);
    });

    test('student statement deep link stays on the Students section', () {
      expect(
        source.contains('section: BursarSection.students,'),
        isTrue,
        reason: 'student/:studentId/bills must render inside Students & fees',
      );
    });
  });

  group('responsive shell wiring (source-level)', () {
    late String shell;
    late String webShell;

    setUpAll(() {
      shell = File(
        'lib/features/finance/presentation/shell/bursar_shell.dart',
      ).readAsStringSync();
      webShell = File(
        'lib/features/finance/presentation/shell/bursar_web_shell.dart',
      ).readAsStringSync();
    });

    test('BursarShell branches on all three ResponsiveLayout values', () {
      expect(shell.contains('ResponsiveLayout.mobile'), isTrue);
      expect(shell.contains('ResponsiveLayout.tablet'), isTrue);
      expect(shell.contains('ResponsiveLayout.desktop'), isTrue);
    });

    test('tablet renders the console (BursarWebShell), not the bottom-nav shell', () {
      // The tablet case must build BursarWebShell (compact), never
      // _BursarMobileShell — every Bursar workflow available on desktop is
      // therefore available on tablet.
      final tabletCase = shell.substring(
        shell.indexOf('ResponsiveLayout.tablet'),
        shell.indexOf('ResponsiveLayout.mobile'),
      );
      expect(tabletCase.contains('BursarWebShell'), isTrue);
      expect(tabletCase.contains('compact: true'), isTrue);
      expect(tabletCase.contains('_BursarMobileShell'), isFalse);
    });

    test('the tablet rail is an intentional labelled rail (200px), not a 76px icon strip', () {
      expect(webShell.contains('? 200.0 : 248.0'), isTrue,
          reason: 'tablet sidebar width should be a real rail, not 76px');
      expect(webShell.contains('76.0'), isFalse,
          reason: 'the tooltip-only 76px icon strip must be gone');
    });

    test('every section is reachable from the tablet/desktop sidebar groups', () {
      // _mainNav + _toolsNav together must cover all 11 sections.
      final navBlock = webShell.substring(
        webShell.indexOf('const _mainNav'),
        webShell.indexOf('class _BursarWebShellState'),
      );
      for (final s in BursarSection.values) {
        expect(
          navBlock.contains('BursarSection.${s.name}'),
          isTrue,
          reason: '${s.name} must appear in a sidebar nav group',
        );
      }
    });
  });
}
