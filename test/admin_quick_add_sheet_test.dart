import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_quick_add_sheet.dart';

void main() {
  testWidgets('shows every admin quick-add action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdminQuickAddSheet.show(context),
              child: const Text('Open quick add'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open quick add'));
    await tester.pumpAndSettle();

    for (final label in const [
      'Add Staff',
      'Add Student',
      'Add Parent',
      'Create Announcement',
      'Create Appointment',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
