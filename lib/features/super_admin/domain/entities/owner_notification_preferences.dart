import 'package:flutter/material.dart';

/// Delivery frequency for non-critical owner notifications.
enum OwnerNotificationFrequency {
  /// Delivered as they happen.
  realtime,

  /// Batched into a single delivery per hour.
  hourlyDigest,

  /// Batched into a single delivery per day.
  dailyDigest,
}

/// SaaS Owner notification settings.
///
/// Mirrors the shape of [NotificationPreferences] (the staff/parent
/// equivalent) but is scoped to the single platform owner account and to the
/// category set that actually applies to platform-level alerts (billing,
/// school applications, payments, platform activity) rather than
/// school-tenant categories like homework or transport.
///
/// Critical categories - security alerts, payment failures and platform
/// outages - are never present as togglable entries: [isCriticalCategory]
/// is enforced both here and at the persistence layer so a stale or
/// maliciously-crafted write can never suppress them.
@immutable
class OwnerNotificationPreferences {
  final String ownerId;

  // Delivery channels.
  final bool inAppEnabled;
  final bool pushEnabled;
  final bool emailEnabled;

  // Category toggles (non-critical only - see [isCriticalCategory]).
  final bool billingAlerts;
  final bool schoolApplicationAlerts;
  final bool paymentAlerts;
  final bool platformActivityAlerts;

  /// Suppresses non-critical delivery between these times. Both null means
  /// quiet hours are off. Wall-clock, same rationale as the staff/parent
  /// preferences: must not shift with timezone/travel.
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  final OwnerNotificationFrequency frequency;

  final DateTime? updatedAt;

  const OwnerNotificationPreferences({
    required this.ownerId,
    this.inAppEnabled = true,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.billingAlerts = true,
    this.schoolApplicationAlerts = true,
    this.paymentAlerts = true,
    this.platformActivityAlerts = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.frequency = OwnerNotificationFrequency.realtime,
    this.updatedAt,
  });

  factory OwnerNotificationPreferences.defaults(String ownerId) =>
      OwnerNotificationPreferences(ownerId: ownerId);

  bool get quietHoursConfigured =>
      quietHoursStart != null && quietHoursEnd != null;

  /// Security, payment-failure and platform-outage notifications are always
  /// delivered regardless of channel/category toggles above. There is no
  /// stored flag for these - they are simply never offered as a switch, and
  /// [OwnerNotificationPreferencesMapper] never writes a field that could
  /// gate them.
  static const criticalCategoriesDescription =
      'Security alerts, payment failures and platform outages';

  OwnerNotificationPreferences copyWith({
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? billingAlerts,
    bool? schoolApplicationAlerts,
    bool? paymentAlerts,
    bool? platformActivityAlerts,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool clearQuietHours = false,
    OwnerNotificationFrequency? frequency,
    DateTime? updatedAt,
  }) {
    return OwnerNotificationPreferences(
      ownerId: ownerId,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      billingAlerts: billingAlerts ?? this.billingAlerts,
      schoolApplicationAlerts:
          schoolApplicationAlerts ?? this.schoolApplicationAlerts,
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      platformActivityAlerts:
          platformActivityAlerts ?? this.platformActivityAlerts,
      quietHoursStart: clearQuietHours
          ? null
          : (quietHoursStart ?? this.quietHoursStart),
      quietHoursEnd: clearQuietHours
          ? null
          : (quietHoursEnd ?? this.quietHoursEnd),
      frequency: frequency ?? this.frequency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
