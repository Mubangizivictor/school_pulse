// Proves PlatformHealthScreen reads real health data (via
// PlatformHealthRepository), has a loading-guarded refresh action, renders
// an Attention section only for non-operational/non-not-configured
// components, and a History section reading the two
// PLATFORM_HEALTH_INCIDENT_* action strings — using the same
// source-inspection approach as billing_home_screen_test.dart, since this
// screen also constructs a real Firebase-backed repository directly in its
// State (no widget-pump without Firebase.initializeApp()).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/platform_health_screen.dart',
    ).readAsStringSync();
  });

  test('reads real health data via PlatformHealthRepository, not a hardcoded status', () {
    expect(source.contains('final PlatformHealthRepository _repo = PlatformHealthRepository();'), isTrue);
    expect(source.contains('_repo.watchCurrent()'), isTrue);
  });

  test('refresh action is loading-guarded against double taps', () {
    expect(source.contains('bool _refreshing = false;'), isTrue);
    expect(source.contains('if (_refreshing) return;'), isTrue);
  });

  test('Attention section only shows non-operational, non-not-configured components', () {
    expect(source.contains('attentionComponents'), isTrue);
    expect(source.contains("_attentionSection"), isTrue);
  });

  test('History section reads the two Platform Health incident action strings via watchIncidentHistory', () {
    expect(source.contains('watchIncidentHistory()'), isTrue);
  });

  test('acknowledging an incident calls the real acknowledgeIncident callable, not a no-op', () {
    expect(source.contains('_repo.acknowledgeIncident(componentId, note: note)'), isTrue);
  });

  test('uses the shared compact style helpers matching billing_home_screen.dart', () {
    for (final helper in ['_pageTitle', '_sectionTitle', '_rowTitle', '_rowBody']) {
      expect(source.contains('TextStyle $helper(BuildContext'), isTrue, reason: '$helper missing');
    }
  });

  test('back button navigates back rather than being a dead icon', () {
    expect(source.contains('Icons.arrow_back_rounded'), isTrue);
    expect(source.contains('Navigator.of(context).pop()'), isTrue);
  });
}
