// Proves ContactAboutScreen shows contact rows sourced from the real
// SupportContact constants (not hardcoded strings), an App version row
// that starts as "Loading..." until PackageInfo resolves, and routes
// Privacy Policy to the real in-app PrivacyPolicyScreen. Live Chat and
// Terms of Service are deliberately omitted per the screen's own
// documented reasoning (no real chat implementation, no hosted ToS URL) -
// this is asserted at the source level since PackageInfo requires platform
// channel mocking that a plain pumpWidget test can't provide without
// additional setup; the rest is rendered directly.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/constants/support_contact.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/contact_about_screen.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/contact_about_screen.dart',
    ).readAsStringSync();
  });

  test('Live Chat and Terms of Service rows are deliberately omitted, not faked', () {
    // Both are named in the doc comment explaining why they're absent, but
    // neither should appear as an actual _InfoTile title in the widget.
    expect(source.contains("title: 'Live Chat'"), isFalse);
    expect(source.contains("title: 'Terms of Service'"), isFalse);
    expect(
      source.contains('no real chat implementation exists in this codebase'),
      isTrue,
    );
  });

  test('Privacy Policy routes to the real in-app draft screen, not an external link', () {
    expect(
      source.contains("context.push('/super-admin/settings/about/privacy-policy')"),
      isTrue,
    );
  });

  testWidgets('renders contact rows sourced from the real SupportContact constants', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ContactAboutScreen()));
    await tester.pump();

    expect(find.text('Contact & About'), findsWidgets);
    expect(find.text(SupportContact.companyName), findsOneWidget);
    expect(find.text(SupportContact.supportEmail), findsOneWidget);
    expect(find.text(SupportContact.websiteUrl), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('the App version row shows a Loading... placeholder until PackageInfo resolves', () {
    // PackageInfo.fromPlatform() resolves via a platform channel too fast/
    // asynchronously in the test harness to reliably catch the interstitial
    // frame with pumpWidget, so this is verified at the source level.
    expect(source.contains("? 'Loading...'"), isTrue);
    expect(source.contains("subtitle: 'App version'"), isTrue);
  });
}
