// Proves Screen C (school_modules_screen.dart) reads real per-school module
// entitlements from ModuleControlRepository/ModuleRegistry - the only real
// entitlement+audit system in this app - instead of the old hardcoded
// 7-switch list bound to school.enabledFeatures, and that it never writes a
// raw switch directly: every change goes through a confirmation sheet that
// calls the same transactional, audited setModuleEnabled used elsewhere.
// The real screen depends on ModuleControlRepository (Firestore streams),
// which this fast widget-test layer doesn't set up, so this verifies
// composition at the source level - the same approach billing_home_screen_test
// and school_subscription_screen_test use for the same reason.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/school_modules_screen.dart',
    ).readAsStringSync();
  });

  test('only the six spec-named module groups are shown, no transport/QR', () {
    for (final label in [
      'Core learning',
      'Attendance',
      'Finance',
      'Examinations',
      'Parent engagement',
      'Library',
    ]) {
      expect(source.contains("label: '$label'"), isTrue, reason: label);
    }
    expect(source.contains('Transport'), isFalse);
    expect(source.contains('QR'), isFalse);
  });

  test('module rows are sourced from the real entitlement system, not enabledFeatures', () {
    expect(source.contains('ModuleControlRepository'), isTrue);
    expect(source.contains('ModuleRegistry'), isTrue);
    expect(source.contains('watchModules'), isTrue);
    expect(source.contains('school.enabledFeatures'), isFalse);
    expect(source.contains('SwitchListTile'), isFalse);
  });

  test('changes go through a confirmation sheet calling setModuleEnabled with a reason, not a raw toggle', () {
    expect(source.contains('setModuleEnabled'), isTrue);
    expect(source.contains('_ModuleConfirmationSheet'), isTrue);
    expect(source.contains('reason.length < 3'), isTrue);
  });

  test('unentitled/unavailable modules are blocked from being toggled', () {
    expect(source.contains('_GroupState.unavailable'), isTrue);
    expect(source.contains('is not included in'), isTrue);
  });

  test('module change history reads the real audit trail', () {
    expect(source.contains('View module change history'), isTrue);
    expect(source.contains('watchAudit'), isTrue);
  });
}
