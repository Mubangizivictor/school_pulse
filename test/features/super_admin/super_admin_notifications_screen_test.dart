// Proves SuperAdminNotificationsScreen streams the real owner notification
// feed via the injectable OwnerNotificationService, falls back to a cached
// offline snapshot with a pending-changes banner rather than a blank
// screen, requires confirmation before delete/clear-all, honestly surfaces
// that "mark unread" is unavailable rather than faking it, and never leaks
// a raw exception into the SnackBar/error state. The real screen depends on
// OwnerNotificationService (Firestore-backed, injectable for tests), which
// this fast widget-test layer doesn't set up beyond source inspection, so
// this verifies composition at the source level - the same approach used
// by billing_home_screen_test.dart. (There is already a companion
// test/features/super_admin/owner_notification_screens_test.dart covering
// other aspects - this file focuses on offline fallback and confirmation
// flows not covered there.)
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_notifications_screen.dart',
    ).readAsStringSync();
  });

  test(
    'the service is injectable for tests but defaults to the production OwnerNotificationService',
    () {
      expect(
        source.contains('final OwnerNotificationService? service;'),
        isTrue,
      );
      expect(
        source.contains('widget.service ?? OwnerNotificationService()'),
        isTrue,
      );
    },
  );

  test(
    'falls back to a cached offline snapshot rather than a blank screen when the stream has no data',
    () {
      expect(source.contains('_notifications.cachedNotifications()'), isTrue);
      expect(
        source.contains('final items = live ?? _cachedFallback ?? const [];'),
        isTrue,
      );
      expect(
        source.contains('class _OfflineBanner extends StatelessWidget'),
        isTrue,
      );
    },
  );

  test(
    'pending offline changes are surfaced and synced on entry, not silently dropped',
    () {
      expect(
        source.contains(
          '_notifications.syncPending().then((_) => _refreshPending());',
        ),
        isTrue,
      );
      expect(source.contains('_notifications.pendingActionCount()'), isTrue);
    },
  );

  test('mark unread is honestly unavailable rather than a fake local toggle', () {
    expect(
      source.contains('Marking unread is not available for owner alerts.'),
      isTrue,
    );
    expect(
      source.contains(
        '// No "mark unread" callable exists; surface honestly rather than fake it.',
      ),
      isTrue,
    );
  });

  test(
    'delete and clear-all both require a destructive confirmation dialog first',
    () {
      expect(source.contains("title: 'Delete this notification?'"), isTrue);
      expect(source.contains("title: 'Clear all notifications?'"), isTrue);
      expect(source.contains('if (ok != true) return;'), isTrue);
    },
  );

  test(
    'clear-all and delete clarify the underlying record is untouched, only the owner feed entry',
    () {
      expect(source.contains('Underlying records are untouched.'), isTrue);
    },
  );

  test(
    'signed-out state (_ownerId == null) shows an explicit sign-in prompt, not a crash',
    () {
      expect(source.contains('if (_ownerId == null) {'), isTrue);
      expect(
        source.contains("Text('Sign in to manage notifications')"),
        isTrue,
      );
    },
  );

  test(
    'errors never leak a raw exception string to the SnackBar or error state',
    () {
      // Regression: _friendlyError must fall back to the shared
      // friendlyErrorMessage() helper, not a raw error.toString().
      expect(source.contains('return friendlyErrorMessage(error);'), isTrue);
      expect(
        source.contains(
          "import 'package:school_pulse/core/error/friendly_error_message.dart';",
        ),
        isTrue,
      );
      expect(source.contains("v.replaceFirst(RegExp(r'^Exception:"), isFalse);
    },
  );
}
