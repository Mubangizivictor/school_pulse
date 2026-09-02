import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/super_admin/data/mappers/owner_notification_preferences_mapper.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_preferences.dart';

void main() {
  group('fromCallable', () {
    test('parses the redesigned callable shape (5 categories + in-app)', () {
      final prefs = OwnerNotificationPreferencesMapper.fromCallable({
        'inAppEnabled': false,
        'pushEnabled': false,
        'emailEnabled': true,
        'categories': {
          'payments': true,
          'platformHealth': false,
          'schools': true,
          'security': false,
          'weeklyDigest': true,
        },
        'quietHours': {'enabled': true, 'start': '21:30', 'end': '06:15'},
        'frequency': 'daily_digest',
        'capabilities': {'dailyDigestDeliveryImplemented': true},
      }, 'owner-1');

      expect(prefs.ownerId, 'owner-1');
      expect(prefs.inAppEnabled, isFalse);
      expect(prefs.pushEnabled, isFalse);
      expect(prefs.paymentAlerts, isTrue);
      expect(prefs.platformHealthAlerts, isFalse);
      expect(prefs.schoolAlerts, isTrue);
      expect(prefs.securityAlerts, isFalse);
      expect(prefs.weeklyDigestEnabled, isTrue);
      expect(prefs.quietHoursStart, const TimeOfDay(hour: 21, minute: 30));
      expect(prefs.frequency, OwnerNotificationFrequency.dailyDigest);
      expect(prefs.dailyDigestDelivered, isTrue);
    });

    test('still reads the legacy category keys', () {
      final prefs = OwnerNotificationPreferencesMapper.fromCallable({
        'categories': {
          'billing': false,
          'schoolApplications': false,
          'platformActivity': false,
        },
      }, 'owner-legacy');
      expect(prefs.paymentAlerts, isFalse);
      expect(prefs.schoolAlerts, isFalse);
      expect(prefs.platformHealthAlerts, isFalse);
    });

    test('falls back to defaults on an empty / malformed map', () {
      final prefs =
          OwnerNotificationPreferencesMapper.fromCallable({}, 'owner-2');
      expect(prefs.inAppEnabled, isTrue);
      expect(prefs.pushEnabled, isTrue);
      expect(prefs.securityAlerts, isTrue);
      expect(prefs.frequency, OwnerNotificationFrequency.realtime);
      expect(prefs.quietHoursEnabled, isFalse);
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
        inAppEnabled: false,
        pushEnabled: false,
        emailEnabled: true,
        paymentAlerts: false,
        platformHealthAlerts: true,
        schoolAlerts: true,
        securityAlerts: false,
        weeklyDigestEnabled: false,
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

      expect(back.inAppEnabled, original.inAppEnabled);
      expect(back.pushEnabled, original.pushEnabled);
      expect(back.paymentAlerts, original.paymentAlerts);
      expect(back.platformHealthAlerts, original.platformHealthAlerts);
      expect(back.securityAlerts, original.securityAlerts);
      expect(back.weeklyDigestEnabled, original.weeklyDigestEnabled);
      expect(back.quietHoursStart, original.quietHoursStart);
      expect(back.frequency, OwnerNotificationFrequency.dailyDigest);
    });

    test('payload carries the in-app channel and the 5 owner categories', () {
      final payload = OwnerNotificationPreferencesMapper.toCallablePayload(
        OwnerNotificationPreferences.defaults('o'),
      );
      expect(payload.containsKey('inAppEnabled'), isTrue);
      expect(payload['frequency'], 'realtime');
      final keys = (payload['categories'] as Map).keys.toSet();
      expect(
        keys.containsAll(
          {'payments', 'platformHealth', 'schools', 'security', 'weeklyDigest'},
        ),
        isTrue,
      );
    });
  });
}
