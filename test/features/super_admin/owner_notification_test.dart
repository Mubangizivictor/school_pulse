import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

void main() {
  group('OwnerNotification.fromJson delivery status', () {
    test('maps a sent push delivery to a friendly status', () {
      final notification = OwnerNotification.fromJson({
        'id': 'n1',
        'delivery': {
          'push': {'status': 'sent', 'successCount': 2, 'failureCount': 0},
        },
      });

      expect(notification.pushStatus, 'delivered');
    });

    test('maps a failed push delivery to a friendly status', () {
      final notification = OwnerNotification.fromJson({
        'id': 'n2',
        'delivery': {
          'push': {
            'status': 'failed',
            'errors': ['messaging/third-party-auth-error'],
          },
        },
      });

      expect(notification.pushStatus, 'delivery issue');
    });

    test('never exposes raw messaging/SMTP error codes as status', () {
      final notification = OwnerNotification.fromJson({
        'id': 'n3',
        'delivery': {
          'push': {
            'status': 'failed',
            'errors': [
              'messaging/registration-token-not-registered',
              'messaging/sender-id-mismatch',
            ],
          },
          'email': {'status': 'failed', 'error': '535 5.7.8 Gmail auth'},
        },
      });

      expect(notification.pushStatus, isNot(contains('messaging/')));
      expect(notification.emailStatus, isNot(contains('535')));
      expect(notification.pushStatus, 'delivery issue');
      expect(notification.emailStatus, 'delivery issue');
    });

    test('does not crash when delivery is missing entirely', () {
      final notification = OwnerNotification.fromJson({'id': 'n4'});

      expect(notification.pushStatus, isNull);
      expect(notification.emailStatus, isNull);
      expect(notification.inAppStatus, isNull);
    });

    test('maps in-app/push/email sent status consistently', () {
      final notification = OwnerNotification.fromJson({
        'id': 'n5',
        'type': 'payment_pending',
        'status': 'unread',
        'title': 'Payment verification required',
        'delivery': {
          'inApp': {'status': 'sent'},
          'push': {'status': 'sent'},
          'email': {'status': 'sent'},
        },
      });

      expect(notification.inAppStatus, 'delivered');
      expect(notification.pushStatus, 'delivered');
      expect(notification.emailStatus, 'delivered');
    });

    test('passes through an unrecognized status verbatim', () {
      final notification = OwnerNotification.fromJson({
        'id': 'n6',
        'delivery': {
          'email': {'status': 'pending'},
        },
      });

      expect(notification.emailStatus, 'pending');
    });
  });
}
