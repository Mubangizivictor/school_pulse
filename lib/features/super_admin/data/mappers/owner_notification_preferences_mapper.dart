import 'package:flutter/material.dart';

import '../../domain/entities/owner_notification_preferences.dart';

/// Serialisation between [OwnerNotificationPreferences] and the payload
/// shape of the owner-preferences callables in
/// `public_functions/owner_notification_preferences.js`.
///
/// The callable is the single source of truth for storage
/// (`platform_owner_settings/{ownerId}`, Admin-SDK-only). The client never
/// reads or writes that document directly, so there is no Firestore
/// serialisation here any more - only callable payload <-> entity.
class OwnerNotificationPreferencesMapper {
  const OwnerNotificationPreferencesMapper._();

  /// Builds an [OwnerNotificationPreferences] from the
  /// `notificationPreferences` map returned by `getOwnerNotificationPreferences`
  /// / `updateOwnerNotificationPreferences`.
  static OwnerNotificationPreferences fromCallable(
    Map<String, dynamic> data,
    String ownerId,
  ) {
    final categories = data['categories'] is Map
        ? Map<String, dynamic>.from(data['categories'] as Map)
        : const <String, dynamic>{};
    final quiet = data['quietHours'] is Map
        ? Map<String, dynamic>.from(data['quietHours'] as Map)
        : const <String, dynamic>{};

    return OwnerNotificationPreferences(
      ownerId: ownerId,
      pushEnabled: data['pushEnabled'] as bool? ?? true,
      emailEnabled: data['emailEnabled'] as bool? ?? true,
      billingAlerts: categories['billing'] as bool? ?? true,
      schoolApplicationAlerts:
          categories['schoolApplications'] as bool? ?? true,
      paymentAlerts: categories['payments'] as bool? ?? true,
      platformActivityAlerts:
          categories['platformActivity'] as bool? ?? true,
      quietHoursEnabled: quiet['enabled'] as bool? ?? false,
      quietHoursStart:
          _timeFrom(quiet['start']) ?? const TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd:
          _timeFrom(quiet['end']) ?? const TimeOfDay(hour: 7, minute: 0),
      frequency: OwnerNotificationFrequency.fromWire(
        data['frequency'] as String?,
      ),
      dailyDigestDelivered: _digestDelivered(data),
    );
  }

  /// The map the client sends as `notificationPreferences` to
  /// `updateOwnerNotificationPreferences`. The callable sanitises every
  /// field server-side; this just mirrors the accepted shape.
  static Map<String, dynamic> toCallablePayload(
    OwnerNotificationPreferences p,
  ) {
    return {
      'pushEnabled': p.pushEnabled,
      'emailEnabled': p.emailEnabled,
      'categories': {
        'billing': p.billingAlerts,
        'schoolApplications': p.schoolApplicationAlerts,
        'payments': p.paymentAlerts,
        'platformActivity': p.platformActivityAlerts,
      },
      'quietHours': {
        'enabled': p.quietHoursEnabled,
        'start': _timeToString(p.quietHoursStart),
        'end': _timeToString(p.quietHoursEnd),
      },
      'frequency': p.frequency.wire,
    };
  }

  static bool _digestDelivered(Map<String, dynamic> data) {
    // The get callable nests this under `capabilities`; the update callable
    // does not return it, so default to the entity's existing value there.
    final caps = data['capabilities'];
    if (caps is Map && caps['dailyDigestDeliveryImplemented'] is bool) {
      return caps['dailyDigestDeliveryImplemented'] as bool;
    }
    return false;
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
}
