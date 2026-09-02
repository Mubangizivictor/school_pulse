import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/super_admin/data/mappers/owner_notification_preferences_mapper.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_preferences.dart';

void main() {
  group('fromCallable', () {
    test('parses the canonical callable shape', () {
      final prefs = OwnerNotificationPreferencesMapper.fromCallable({
        'pushEnabled': false,
        'emailEnabled': true,
        'categories': {
          'billing': false,
          'schoolApplications': true,
          'payments': true,
          'platformActivity': false,
        },
        'quietHours': {
          'enabled': true,
          'start': '21:30',
          'end': '06:15',
        },
        'frequency': 'daily_digest',
        'capabilities': {'dailyDigestDeliveryImplemented': true},
      }, 'owner-1');

      expect(prefs.ownerId, 'owner-1');
      expect(prefs.pushEnabled, isFalse);
      expect(prefs.billingAlerts, isFalse);
      expect(prefs.platformActivityAlerts, isFalse);
      expect(prefs.quietHoursEnabled, isTrue);
      expect(prefs.quietHoursStart, const TimeOfDay(hour: 21, minute: 30));
      expect(prefs.quietHoursEnd, const TimeOfDay(hour: 6, minute: 15));
      expect(prefs.frequency, OwnerNotificationFrequency.dailyDigest);
      expect(prefs.dailyDigestDelivered, isTrue);
    });

    test('falls back to defaults on an empty / malformed map', () {
      final prefs =
          OwnerNotificationPreferencesMapper.fromCallable({}, 'owner-2');
      expect(prefs.pushEnabled, isTrue);
      expect(prefs.emailEnabled, isTrue);
      expect(prefs.frequency, OwnerNotificationFrequency.realtime);
      expect(prefs.quietHoursEnabled, isFalse);
      expect(prefs.dailyDigestDelivered, isFalse);
    });

    test('an unknown frequency degrades to realtime', () {
      final prefs = OwnerNotificationPreferencesMapper.fromCallable(
        {'frequency': 'hourly'},
        'owner-3',
      );
      expect(prefs.frequency, OwnerNotificationFrequency.realtime);
    });
  });

  group('toCallablePayload', () {
    test('round-trips through fromCallable', () {
      const original = OwnerNotificationPreferences(
        ownerId: 'owner-9',
        pushEnabled: false,
        emailEnabled: true,
        billingAlerts: false,
        schoolApplicationAlerts: true,
        paymentAlerts: false,
        platformActivityAlerts: true,
        quietHoursEnabled: true,
        quietHoursStart: TimeOfDay(hour: 22, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
        frequency: OwnerNotificationFrequency.dailyDigest,
      );

      final payload =
          OwnerNotificationPreferencesMapper.toCallablePayload(original);
      final back = OwnerNotificationPreferencesMapper.fromCallable(
        Map<String, dynamic>.from(payload),
        'owner-9',
      );

      expect(back.pushEnabled, original.pushEnabled);
      expect(back.billingAlerts, original.billingAlerts);
      expect(back.paymentAlerts, original.paymentAlerts);
      expect(back.quietHoursEnabled, isTrue);
      expect(back.quietHoursStart, original.quietHoursStart);
      expect(back.frequency, OwnerNotificationFrequency.dailyDigest);
    });

    test('payload has no in-app channel and only the two wire frequencies', () {
      final payload = OwnerNotificationPreferencesMapper.toCallablePayload(
        OwnerNotificationPreferences.defaults('o'),
      );
      expect(payload.containsKey('inAppEnabled'), isFalse);
      expect(payload['frequency'], 'realtime');
      expect(
        (payload['categories'] as Map).keys.toSet(),
        {'billing', 'schoolApplications', 'payments', 'platformActivity'},
      );
    });
  });
}
