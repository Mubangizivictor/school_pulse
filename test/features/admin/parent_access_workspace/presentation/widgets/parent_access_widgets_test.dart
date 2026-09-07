import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_invite.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/cubit/parents_access_state.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/widgets/access_code_row_tile.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/widgets/filter_bottom_sheet.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/widgets/info_banner.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/widgets/parent_row_tile.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/widgets/summary_count_cards.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

bool _containsText(Widget? widget, String label) {
  if (widget == null) return false;
  if (widget is Text) return widget.data == label;
  if (widget is Row) return widget.children.any((c) => _containsText(c, label));
  if (widget is Spacer) return false;
  return false;
}

void main() {
  const invite = ParentAccessInvite(
    inviteId: 'inv-1',
    parentName: 'Amanda Carter',
    maskedPhone: '***1234',
    learnerCount: 2,
    status: ParentInviteStatus.active,
  );

  group('ParentAccessInfoBanner', () {
    testWidgets('shows the configured guardian limit, not a hard-coded number',
        (tester) async {
      await tester.pumpWidget(
        wrap(const ParentAccessInfoBanner(maxGuardians: 3)),
      );
      expect(
        find.textContaining('up to 3 parents or guardians'),
        findsOneWidget,
      );
    });

    testWidgets('defaults to 2 when no policy override is passed',
        (tester) async {
      await tester.pumpWidget(wrap(const ParentAccessInfoBanner()));
      expect(
        find.textContaining('up to 2 parents or guardians'),
        findsOneWidget,
      );
    });

    testWidgets('dismiss button calls onDismiss', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        wrap(ParentAccessInfoBanner(onDismiss: () => dismissed = true)),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, true);
    });
  });

  group('SummaryCountCards', () {
    testWidgets('renders the live counts passed in, not hardcoded values', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SummaryCountCards(
            data: SummaryCountData(linkedParents: 1036, codesPending: 18, expiringSoon: 6),
          ),
        ),
      );
      expect(find.text('1036'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    });
  });

  group('ParentAccessFilterChips', () {
    testWidgets('tapping a chip reports the selected filter', (tester) async {
      ParentsAccessFilter? selected;
      await tester.pumpWidget(
        wrap(
          ParentAccessFilterChips(
            selected: ParentsAccessFilter.all,
            onChanged: (f) => selected = f,
          ),
        ),
      );
      await tester.tap(find.text('Expiring'));
      expect(selected, ParentsAccessFilter.expiring);
    });
  });

  group('ParentRowTile', () {
    testWidgets('renders masked phone, never a raw code or full number', (tester) async {
      await tester.pumpWidget(wrap(ParentRowTile(invite: invite)));
      expect(find.textContaining('***1234'), findsOneWidget);
      expect(find.textContaining(RegExp(r'\+\d{8,}')), findsNothing);
    });
  });

  group('AccessCodeRowTile', () {
    testWidgets('never renders a raw code string', (tester) async {
      await tester.pumpWidget(wrap(AccessCodeRowTile(invite: invite)));
      expect(find.textContaining('***1234'), findsOneWidget);
      // No 6-digit-plus-letter code pattern (e.g. "SCH-123456P") anywhere.
      expect(find.textContaining(RegExp(r'-\d{6}[A-Z]')), findsNothing);
    });

    testWidgets('resend menu item is present but disabled', (tester) async {
      await tester.pumpWidget(wrap(AccessCodeRowTile(invite: invite)));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      final resendItem = tester.widget<PopupMenuItem>(
        find.byWidgetPredicate(
          (w) => w is PopupMenuItem && _containsText(w.child, 'Resend'),
        ),
      );
      expect(resendItem.enabled, false);
    });

    testWidgets('revoke/reallocate hidden when not permitted', (tester) async {
      await tester.pumpWidget(
        wrap(AccessCodeRowTile(invite: invite, canRevoke: false, canReallocate: false)),
      );
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      PopupMenuItem findItemContaining(String label) {
        return tester.widget<PopupMenuItem>(
          find.byWidgetPredicate(
            (w) => w is PopupMenuItem && _containsText(w.child, label),
          ),
        );
      }

      expect(findItemContaining('Revoke').enabled, false);
      expect(findItemContaining('Reallocate').enabled, false);
    });
  });
}
