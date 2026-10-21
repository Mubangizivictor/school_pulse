// Proves SupportTicketConversationScreen streams ticket metadata and
// messages live (watchTicket/watchMessages, both snapshots() streams, so
// a future admin reply appears without manual refresh), auto-scrolls to
// the newest message, shows an explicit empty state before any reply
// arrives, deliberately omits attachments (an unreviewed file-upload
// surface, per the screen's own documented reasoning), and (a second
// raw-error-leak bug found and fixed while writing this test) never
// interpolates a raw caught exception into the send-failure SnackBar. The
// real screen depends on SupportTicketService (Firestore-backed), which
// this fast widget-test layer doesn't set up, so this verifies composition
// at the source level - the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/support_ticket_conversation_screen.dart',
    ).readAsStringSync();
  });

  test(
    'ticket metadata and messages are both live streams, not one-shot fetches',
    () {
      expect(source.contains('_service.watchTicket(widget.ticketId)'), isTrue);
      expect(
        source.contains('_service.watchMessages(widget.ticketId)'),
        isTrue,
      );
      expect(source.contains('StreamBuilder<SupportTicket?>'), isTrue);
      expect(
        source.contains('StreamBuilder<List<SupportTicketMessage>>'),
        isTrue,
      );
    },
  );

  test('the message list auto-scrolls to the newest message on update', () {
    expect(
      source.contains(
        '_scrollController.jumpTo(\n                      _scrollController.position.maxScrollExtent,',
      ),
      isTrue,
    );
  });

  test(
    'an explicit empty state is shown before any reply arrives, not a blank list',
    () {
      expect(
        source.contains('No replies yet. Support will respond here as soon as'),
        isTrue,
      );
    },
  );

  test(
    'loading and stream-error states for messages are handled explicitly',
    () {
      expect(source.contains('ConnectionState.waiting'), isTrue);
      expect(source.contains("'Could not load messages.'"), isTrue);
    },
  );

  test(
    'attachments are deliberately omitted - an unreviewed file-upload surface, not built insecurely',
    () {
      expect(source.contains('putData'), isFalse);
      expect(source.contains('FirebaseStorage'), isFalse);
      expect(
        source.contains('Attachments are intentionally not implemented'),
        isTrue,
      );
    },
  );

  test(
    'sending goes through the real SupportTicketService, and the input clears only after success',
    () {
      expect(
        source.contains(
          '_service.sendMessage(ticketId: widget.ticketId, text: text)',
        ),
        isTrue,
      );
      expect(source.contains('_messageController.clear();'), isTrue);
    },
  );

  test(
    'a bubble shows You for the owner and the real sender name/Support fallback otherwise',
    () {
      expect(source.contains("isOwner\n                  ? 'You'"), isTrue);
      expect(
        source.contains(
          "message.senderName.isNotEmpty\n                        ? message.senderName\n                        : 'Support'",
        ),
        isTrue,
      );
    },
  );

  test(
    'errors never interpolate a raw caught exception into the send-failure SnackBar',
    () {
      // Regression: this screen originally did
      // `Text('Could not send message: \$e')` which rendered a raw Dart/
      // Firebase exception string directly to the owner. Fixed to use the
      // shared friendlyErrorMessage() helper.
      expect(source.contains(r"'Could not send message: $e'"), isFalse);
      expect(
        source.contains('friendlyErrorMessage(\n                e,'),
        isTrue,
      );
      expect(
        source.contains(
          "import 'package:school_pulse/core/error/friendly_error_message.dart';",
        ),
        isTrue,
      );
    },
  );
}
