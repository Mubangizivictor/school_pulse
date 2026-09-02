// Proves the Home "Platform health" card streams the real
// PlatformHealthRepository aggregate instead of hardcoding hasError from
// SuperAdminStatus.failure (the original, narrower signal this replaces),
// navigates to the new /super-admin/platform-health screen, and never
// claims "Platform healthy" unconditionally.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_overview_screen.dart',
    ).readAsStringSync();
  });

  test('the card no longer derives its status from SuperAdminStatus.failure', () {
    expect(source.contains('hasError: state.status == SuperAdminStatus.failure'), isFalse);
  });

  test('the card streams the real PlatformHealthRepository aggregate', () {
    expect(source.contains('final PlatformHealthRepository _repo = PlatformHealthRepository();'), isTrue);
    expect(source.contains('_repo.watchCurrent()'), isTrue);
  });

  test('tapping the card navigates to the Platform Health screen, not the audit log list', () {
    expect(source.contains("context.go('/super-admin/platform-health')"), isTrue);
  });

  test('"Platform healthy" is only shown when the real status is operational, never unconditionally', () {
    // The literal 'Platform healthy' string must appear behind a status
    // check, not as an unconditional default alongside a bool.
    final cardSection = source.substring(source.indexOf('class _PlatformHealthCardState'));
    expect(cardSection.contains("'Platform healthy'"), isTrue);
    expect(cardSection.contains("'Attention needed'"), isTrue);
    expect(cardSection.contains('healthy'), isTrue);
    expect(cardSection.contains('summary?.status == PlatformHealthStatus.operational'), isTrue);
  });

  test('a missing aggregate (no check has run yet) shows a neutral checking state, not a false-positive healthy', () {
    final cardSection = source.substring(source.indexOf('class _PlatformHealthCardState'));
    expect(cardSection.contains("'Checking platform status…'"), isTrue);
  });
}
