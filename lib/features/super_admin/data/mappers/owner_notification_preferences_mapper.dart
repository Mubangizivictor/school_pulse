import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/owner_notification_preferences.dart';

/// Firestore serialisation for [OwnerNotificationPreferences].
///
/// Stored at `super_admin_settings/{ownerId}` under a `notification_preferences`
/// map field, alongside other owner-scoped settings documents (matches the
/// naming convention already used for `super_admin_audit_logs` and
/// `super_admin_notifications`). Quiet hours are stored as `"HH:mm"` strings,
/// same rationale as [NotificationPreferencesMapper]: a wall-clock concept
/// that must not shift with timezone.
class OwnerNotificationPreferencesMapper {
  const OwnerNotificationPreferencesMapper._();

  static const fieldName = 'notification_preferences';

  static OwnerNotificationPreferences fromFirestore(
    Map<String, dynamic>? data,
    String ownerId,
  ) {
    if (data == null) return OwnerNotificationPreferences.defaults(ownerId);
    return OwnerNotificationPreferences(
      ownerId: ownerId,
      inAppEnabled: data['inAppEnabled'] as bool? ?? true,
      pushEnabled: data['pushEnabled'] as bool? ?? true,
      emailEnabled: data['emailEnabled'] as bool? ?? true,
      billingAlerts: data['billingAlerts'] as bool? ?? true,
      schoolApplicationAlerts: data['schoolApplicationAlerts'] as bool? ?? true,
      paymentAlerts: data['paymentAlerts'] as bool? ?? true,
      platformActivityAlerts: data['platformActivityAlerts'] as bool? ?? true,
      quietHoursStart: _timeFrom(data['quietHoursStart']),
      quietHoursEnd: _timeFrom(data['quietHoursEnd']),
      frequency: _frequencyFromName(data['frequency'] as String?),
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toFirestore(OwnerNotificationPreferences p) {
    return {
      'inAppEnabled': p.inAppEnabled,
      'pushEnabled': p.pushEnabled,
      'emailEnabled': p.emailEnabled,
      'billingAlerts': p.billingAlerts,
      'schoolApplicationAlerts': p.schoolApplicationAlerts,
      'paymentAlerts': p.paymentAlerts,
      'platformActivityAlerts': p.platformActivityAlerts,
      // Explicitly deleted rather than omitted so clearing quiet hours
      // actually removes them server-side instead of a merge write
      // preserving the stale value.
      'quietHoursStart': p.quietHoursStart == null
          ? FieldValue.delete()
          : _timeToString(p.quietHoursStart!),
      'quietHoursEnd': p.quietHoursEnd == null
          ? FieldValue.delete()
          : _timeToString(p.quietHoursEnd!),
      'frequency': p.frequency.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static TimeOfDay? _timeFrom(dynamic value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _timeToString(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  static OwnerNotificationFrequency _frequencyFromName(String? name) {
    for (final value in OwnerNotificationFrequency.values) {
      if (value.name == name) return value;
    }
    return OwnerNotificationFrequency.realtime;
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
