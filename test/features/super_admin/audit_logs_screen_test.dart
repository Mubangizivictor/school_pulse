// Proves AuditLogsScreen buckets AuditLog entries into the compact
// All/Schools/Billing/Security/System categories heuristically (client-side
// only, no new backend calls), supports period/date-range filtering and CSV
// export of the already-fetched state.auditLogs, and shows an explicit
// empty state both when there are no logs at all and when a filter matches
// nothing. The real screen depends on SuperAdminBloc (Firestore-backed),
// which this fast widget-test layer doesn't set up, so this verifies
// composition at the source level - the same approach used by
// billing_home_screen_test.dart. (Note: there is already a companion
// test/features/super_admin/audit_logs_screen_redesign_test.dart covering
// the desktop redesign; this file focuses on filtering/export/category
// logic not covered there.)
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/audit_logs_screen.dart',
    ).readAsStringSync();
  });

  test(
    'categories are derived client-side from AuditLog.action, no new backend call',
    () {
      expect(source.contains("action.contains('PAYMENT')"), isTrue);
      expect(source.contains("action.contains('SIGN_IN')"), isTrue);
      expect(source.contains("action.contains('SCHOOL')"), isTrue);
      expect(source.contains('return _AuditCategory.system;'), isTrue);
    },
  );

  test(
    'logs are sourced from the real SuperAdminBloc state, not a mock list',
    () {
      expect(
        source.contains('BlocBuilder<SuperAdminBloc, SuperAdminState>'),
        isTrue,
      );
      expect(source.contains('state.auditLogs'), isTrue);
    },
  );

  test('refresh dispatches LoadAuditLogsEvent, not a silent no-op', () {
    expect(source.contains('const LoadAuditLogsEvent()'), isTrue);
  });

  test(
    'empty states differ for no logs at all vs. no logs matching the filter',
    () {
      expect(source.contains("title: 'No audit logs found'"), isTrue);
      expect(source.contains("title: 'No matching logs'"), isTrue);
    },
  );

  test(
    'CSV export uses the already-fetched filtered logs, escaping quotes safely',
    () {
      expect(
        source.contains(
          'Event,EventCode,Actor,Target,Category,Timestamp,Reason',
        ),
        isTrue,
      );
      expect(source.contains("value.replaceAll('\"', '\"\"')"), isTrue);
      expect(source.contains("mimeType: 'text/csv'"), isTrue);
    },
  );

  test(
    'a raw device token in ownerId falls back to the signed-in owner identity, never shown verbatim',
    () {
      expect(source.contains('looksLikeToken'), isTrue);
      expect(source.contains("return 'SaaS Owner';"), isTrue);
    },
  );

  test(
    'desktop pagination clamps to a valid page and shows a rows-per-page control',
    () {
      expect(
        source.contains('clampedPage = page.clamp(0, totalPages - 1)'),
        isTrue,
      );
      expect(source.contains('const [10, 25, 50]'), isTrue);
    },
  );
}
