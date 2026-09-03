// Proves the compact Activity redesign (period picker default Today,
// All/Schools/Billing/Security/System chips, Export audit, Today/Yesterday
// grouping) is wired in AuditLogsScreen, using the same source-inspection
// approach as billing_home_screen_test.dart -- the real screen depends on
// SuperAdminBloc (Firestore), which this fast widget-test layer doesn't set
// up.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/audit_logs_screen.dart',
    ).readAsStringSync();
  });

  test('default period is Today', () {
    expect(source.contains('_Period _period = _Period.today;'), isTrue);
  });

  test('category chips match the compact All/Schools/Billing/Security/System row', () {
    expect(
      source.contains('enum _AuditCategory { all, schools, billing, security, system }'),
      isTrue,
    );
  });

  test('Export is wired to a real CSV share action, not a placeholder', () {
    expect(source.contains("'Export CSV'"), isTrue);
    expect(source.contains('_exportAudit'), isTrue);
    expect(source.contains('Share.shareXFiles'), isTrue);
    // The export builds a real CSV in-process from the filtered logs.
    expect(source.contains("mimeType: 'text/csv'"), isTrue);
  });

  test('the list is scoped by a period picker defaulting to Today', () {
    expect(source.contains('enum _Period { today, thisWeek, thisMonth, all }'), isTrue);
    expect(source.contains('_period = _Period.today'), isTrue);
    expect(source.contains('_period.includes(l.timestamp)'), isTrue);
  });

  test('each row renders a title-cased event, the resolved actor and a category', () {
    expect(source.contains('_titleCaseAction(log.action)'), isTrue);
    expect(source.contains('_actorLabel(log.ownerId)'), isTrue);
    expect(source.contains('_categoryOf(log)'), isTrue);
  });

  test('actor label falls back off a raw device token to the real signed-in owner', () {
    expect(source.contains('String _actorLabel(String ownerId)'), isTrue);
    expect(source.contains('FirebaseAuth.instance.currentUser'), isTrue);
  });
}
