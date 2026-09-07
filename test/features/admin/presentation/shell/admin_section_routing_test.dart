import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_section.dart';

/// Admin console deep-link routing, mirroring
/// test/features/finance/presentation/shell/bursar_section_routing_test.dart
/// for the equivalent AdminShell/AdminSection pattern.
void main() {
  group('AdminSection.fromLocation', () {
    test('bare /staff/admin resolves to home', () {
      expect(AdminSection.fromLocation('/staff/admin'), AdminSection.home);
    });

    test('resolves the students section and its nested/related paths', () {
      expect(
        AdminSection.fromLocation('/staff/admin/students'),
        AdminSection.students,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/students/abc123'),
        AdminSection.students,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/students/abc123/documents'),
        AdminSection.students,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/admissions'),
        AdminSection.students,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/student-id-card'),
        AdminSection.students,
      );
    });

    test('resolves staff/parents/attendance/fees/approvals/appointments', () {
      expect(
        AdminSection.fromLocation('/staff/admin/users'),
        AdminSection.staff,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/users/uid1'),
        AdminSection.staff,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/parents'),
        AdminSection.parents,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/staff-attendance'),
        AdminSection.attendance,
      );
      expect(AdminSection.fromLocation('/staff/admin/fees'), AdminSection.fees);
      expect(
        AdminSection.fromLocation('/staff/admin/approvals'),
        AdminSection.approvals,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/approvals/policies'),
        AdminSection.approvals,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/appointments'),
        AdminSection.appointments,
      );
    });

    test('every unmatched admin destination falls back to More', () {
      for (final path in [
        '/staff/admin/school-setup',
        '/staff/admin/data-management',
        '/staff/admin/institution-health',
        '/staff/admin/structure',
        '/staff/admin/structure/academic/levels',
        '/staff/admin/config',
        '/staff/admin/integrations',
        '/staff/admin/batch-id-cards',
        '/staff/admin/audit-log',
        '/staff/admin/support',
        '/staff/admin/communication-center',
        '/staff/admin/security',
        '/staff/admin/broadcast-history',
        '/staff/admin/subscription',
        '/staff/admin/does-not-exist',
      ]) {
        expect(
          AdminSection.fromLocation(path),
          AdminSection.more,
          reason: '$path should fall back to More',
        );
      }
    });

    test('the dedicated /staff/admin/more path resolves to More', () {
      // The desktop sidebar's More item and the mobile More tab both drive
      // this exact URL - lock it explicitly rather than relying on the
      // catch-all above.
      expect(AdminSection.fromLocation('/staff/admin/more'), AdminSection.more);
    });
  });

  group('AdminSection.routeSegment', () {
    test(
      'diverges from slug exactly where the router path differs (staff, attendance)',
      () {
        expect(AdminSection.staff.routeSegment, 'users');
        expect(AdminSection.attendance.routeSegment, 'staff-attendance');
      },
    );

    test('every routeSegment round-trips through fromLocation', () {
      for (final s in [
        AdminSection.students,
        AdminSection.staff,
        AdminSection.parents,
        AdminSection.attendance,
        AdminSection.fees,
        AdminSection.approvals,
        AdminSection.appointments,
      ]) {
        expect(
          AdminSection.fromLocation('/staff/admin/${s.routeSegment}'),
          s,
          reason:
              '/staff/admin/${s.routeSegment} (built from ${s.name}.routeSegment) '
              'must resolve back to ${s.name} - this is the exact bug where the '
              'sidebar built a URL from .slug instead and 404'
              'd on Staff/Attendance',
        );
      }
    });

    test('every other section keeps routeSegment == slug', () {
      for (final s in AdminSection.values) {
        if (s == AdminSection.staff || s == AdminSection.attendance) continue;
        expect(s.routeSegment, s.slug, reason: '$s should not diverge');
      }
    });
  });

  group('AdminSection mobile-tab mapping', () {
    test('exactly the five bottom-nav sections carry a mobileTab', () {
      final withTab = AdminSection.values
          .where((s) => s.mobileTab != null)
          .toList();
      expect(
        withTab,
        containsAll(<AdminSection>[
          AdminSection.home,
          AdminSection.students,
          AdminSection.parents,
          AdminSection.attendance,
          AdminSection.more,
        ]),
      );
      expect(withTab.length, 5);
    });

    test('mobileTab indices are unique and match Home/Students/Parents/'
        'Attendance/More order', () {
      expect(AdminSection.home.mobileTab, 0);
      expect(AdminSection.students.mobileTab, 1);
      expect(AdminSection.parents.mobileTab, 2);
      expect(AdminSection.attendance.mobileTab, 3);
      expect(AdminSection.more.mobileTab, 4);
      final tabs = AdminSection.values
          .map((s) => s.mobileTab)
          .whereType<int>()
          .toList();
      expect(tabs.toSet().length, tabs.length, reason: 'no duplicate index');
      expect(tabs.every((t) => t >= 0 && t < 5), isTrue);
      expect(AdminSection.moreTabIndex, 4);
    });

    test('non-tabbed sections fall back to More', () {
      for (final s in [
        AdminSection.staff,
        AdminSection.fees,
        AdminSection.approvals,
        AdminSection.appointments,
      ]) {
        expect(s.mobileTab, isNull, reason: '$s must fall back to More');
      }
    });

    test('Parents resolves from its directory, link, and detail URLs', () {
      expect(
        AdminSection.fromLocation('/staff/admin/parents'),
        AdminSection.parents,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/parents/link'),
        AdminSection.parents,
      );
      expect(
        AdminSection.fromLocation('/staff/admin/parents/abc123'),
        AdminSection.parents,
      );
    });
  });

  group('router.dart wiring', () {
    late String source;

    setUpAll(() {
      source = File('lib/app/router.dart').readAsStringSync();
    });

    test(
      'every in-shell section has a matching AdminShell(section: ...) call',
      () {
        for (final s in [
          AdminSection.home,
          AdminSection.students,
          AdminSection.staff,
          AdminSection.parents,
          AdminSection.attendance,
          AdminSection.fees,
          AdminSection.approvals,
          AdminSection.appointments,
        ]) {
          final enumRef = 'AdminSection.${s.name}';
          expect(
            source.contains('AdminShell(section: $enumRef)'),
            isTrue,
            reason: 'router must build AdminShell(section: $enumRef) somewhere',
          );
        }
      },
    );

    test('the fees route is gated to schoolAdmin/headTeacher/director', () {
      final feesBlockStart = source.indexOf("path: 'fees'");
      expect(feesBlockStart, greaterThan(-1));
      final feesBlockEnd = source.indexOf('),', feesBlockStart + 400);
      final block = source.substring(feesBlockStart, feesBlockEnd);
      expect(block.contains('UserRole.schoolAdmin'), isTrue);
      expect(block.contains('UserRole.headTeacher'), isTrue);
      expect(block.contains('UserRole.director'), isTrue);
    });

    test('there is a deep-linkable /staff/admin/more route building the '
        'More section, gated to the admin console roles', () {
      // Anchor to the admin subtree: the `more` route sits just after the
      // attendance route inside the `/staff/admin` GoRoute's `routes:` list.
      final anchor = source.indexOf(
        "AdminShell(section: AdminSection.attendance)",
      );
      expect(anchor, greaterThan(-1));
      final start = source.indexOf("path: 'more'", anchor);
      expect(
        start,
        greaterThan(-1),
        reason:
            "the sidebar's More item drives context.go('/staff/admin/more') - "
            'that path must be a registered GoRoute, or it 404s on refresh',
      );
      final block = source.substring(start, start + 600);
      expect(
        block.contains('AdminShell(section: AdminSection.more)'),
        isTrue,
        reason: 'the more route must build the canonical AdminShell',
      );
      expect(
        block.contains('adminConsoleRoles'),
        isTrue,
        reason: 'the more route must carry the admin-console role guard',
      );
    });
  });

  group('shell_screen.dart wiring', () {
    test('/staff/admin/more is in the adminShellPaths allowlist so StaffShell '
        'hands it to AdminShell bare', () {
      final source = File(
        'lib/features/shared/shell_screen.dart',
      ).readAsStringSync();
      final start = source.indexOf('const adminShellPaths');
      expect(start, greaterThan(-1));
      final block = source.substring(start, source.indexOf('};', start));
      expect(block.contains("'/staff/admin/more'"), isTrue);
    });
  });

  group('responsive shell wiring (source-level)', () {
    late String shell;
    late String webShell;

    setUpAll(() {
      shell = File(
        'lib/features/admin/presentation/shell/admin_shell.dart',
      ).readAsStringSync();
      webShell = File(
        'lib/features/admin/presentation/shell/admin_web_shell.dart',
      ).readAsStringSync();
    });

    test('AdminShell branches on all three ResponsiveLayout values', () {
      expect(shell.contains('ResponsiveLayout.mobile'), isTrue);
      expect(shell.contains('ResponsiveLayout.tablet'), isTrue);
      expect(shell.contains('ResponsiveLayout.desktop'), isTrue);
    });

    test(
      'tablet renders the console (AdminWebShell), not the bottom-nav shell',
      () {
        final tabletCase = shell.substring(
          shell.indexOf('ResponsiveLayout.tablet'),
          shell.indexOf('ResponsiveLayout.mobile'),
        );
        expect(tabletCase.contains('AdminWebShell'), isTrue);
        expect(tabletCase.contains('compact: true'), isTrue);
        expect(tabletCase.contains('_AdminMobileShell'), isFalse);
      },
    );

    test('Fees is embedded (AdminFeesScreen), never a bursar route hop', () {
      expect(shell.contains("context.go('/staff/bursar')"), isFalse);
      expect(webShell.contains("context.go('/staff/bursar')"), isFalse);
      expect(shell.contains('AdminFeesScreen'), isTrue);
      expect(webShell.contains('AdminFeesScreen'), isTrue);
    });

    test(
      'the desktop sidebar builds its nav URL from routeSegment, not slug',
      () {
        // Regression guard: `/staff/admin/${s.slug}` 404s for Staff (real
        // route is /staff/admin/users) and Attendance (real route is
        // /staff/admin/staff-attendance) - the sidebar must use
        // `s.routeSegment` instead.
        expect(webShell.contains(r'${s.slug}'), isFalse);
        expect(webShell.contains(r'${s.routeSegment}'), isTrue);
      },
    );

    test('every in-shell section appears in the desktop sidebar nav', () {
      final navBlock = webShell.substring(
        webShell.indexOf('const _mainNav'),
        webShell.indexOf('class _AdminWebShellState'),
      );
      for (final s in [
        AdminSection.home,
        AdminSection.students,
        AdminSection.staff,
        AdminSection.parents,
        AdminSection.attendance,
        AdminSection.fees,
        AdminSection.approvals,
        AdminSection.appointments,
      ]) {
        expect(
          navBlock.contains('AdminSection.${s.name}'),
          isTrue,
          reason: '${s.name} must appear in the sidebar nav',
        );
      }
    });
  });
}
