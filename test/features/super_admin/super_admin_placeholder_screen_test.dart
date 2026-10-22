// Proves SuperAdminPlaceholderScreen (the generic "coming in a later
// phase" placeholder for owner console sections without a backing screen
// yet) renders its title, illustration, and message, and defaults the message when
// one isn't provided. This is a trivial, static widget - one smoke-render
// test plus the default-message case is sufficient coverage, per the
// task's own guidance not to over-invest here.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/brand/brand_assets.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_placeholder_screen.dart';

void main() {
  testWidgets('renders title, icon, and a custom message without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SuperAdminPlaceholderScreen(
          title: 'Future Section',
          icon: Icons.rocket_launch_outlined,
          message: 'This section ships in Q4.',
        ),
      ),
    );

    expect(find.text('Future Section'), findsWidgets);
    expect(find.text('This section ships in Q4.'), findsOneWidget);
    // EmptyState draws the brand illustration in place of the icon.
    expect(
      find.byWidgetPredicate(
        (w) => w is BrandStateImage && w.state == BrandState.empty,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'defaults to "Coming in a later phase." when no message is given',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SuperAdminPlaceholderScreen(
            title: 'Another Section',
            icon: Icons.hourglass_empty_outlined,
          ),
        ),
      );

      expect(find.text('Coming in a later phase.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
