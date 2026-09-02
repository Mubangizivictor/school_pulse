import 'package:flutter/material.dart';

/// Delivery frequency for non-critical owner notifications.
///
/// Only the two values the backend callable
/// (`public_functions/owner_notification_preferences.js`) accepts:
/// `realtime` and `daily_digest`. Daily-digest delivery is stored for
/// forward compatibility; the server still delivers realtime until a digest
/// worker is implemented (surfaced to the UI via [dailyDigestDelivered]).
enum OwnerNotificationFrequency {
  realtime,
  dailyDigest;

  /// Wire value used by the callable payload/response.
  String get wire =>
      this == OwnerNotificationFrequency.dailyDigest ? 'daily_digest' : 'realtime';

  static OwnerNotificationFrequency fromWire(String? value) {
    return value == 'daily_digest'
        ? OwnerNotificationFrequency.dailyDigest
        : OwnerNotificationFrequency.realtime;
  }
}

/// SaaS Owner notification settings.
///
/// Shape is the canonical one owned by the backend callable: two delivery
/// channels (push, email), four category toggles, wall-clock quiet hours,
/// and a two-value frequency. There is deliberately no in-app channel
/// toggle - the owner feed is the durable source of truth and is never
/// suppressed - and no per-category "critical" switch: security alerts,
/// payment failures and platform outages are simply never offered here, so
/// nothing this model persists can gate them.
@immutable
class OwnerNotificationPreferences {
  final String ownerId;

  // Delivery channels.
  final bool pushEnabled;
  final bool emailEnabled;

  // Category toggles (non-critical only).
  final bool billingAlerts;
  final bool schoolApplicationAlerts;
  final bool paymentAlerts;
  final bool platformActivityAlerts;

  /// Suppresses non-critical delivery between these times when
  /// [quietHoursEnabled]. Wall-clock (must not shift with timezone/travel).
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  final OwnerNotificationFrequency frequency;

  /// True when the backend reports a digest worker actually runs. Until
  /// then the UI shows "delivered in real time for now" next to the
  /// daily-digest option rather than implying batching already happens.
  final bool dailyDigestDelivered;

  const OwnerNotificationPreferences({
    required this.ownerId,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.billingAlerts = true,
    this.schoolApplicationAlerts = true,
    this.paymentAlerts = true,
    this.platformActivityAlerts = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
    this.frequency = OwnerNotificationFrequency.realtime,
    this.dailyDigestDelivered = false,
  });

  factory OwnerNotificationPreferences.defaults(String ownerId) =>
      OwnerNotificationPreferences(ownerId: ownerId);

  static const criticalCategoriesDescription =
      'Security alerts, payment failures and platform outages';

  OwnerNotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? billingAlerts,
    bool? schoolApplicationAlerts,
    bool? paymentAlerts,
    bool? platformActivityAlerts,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    OwnerNotificationFrequency? frequency,
    bool? dailyDigestDelivered,
  }) {
    return OwnerNotificationPreferences(
      ownerId: ownerId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      billingAlerts: billingAlerts ?? this.billingAlerts,
      schoolApplicationAlerts:
          schoolApplicationAlerts ?? this.schoolApplicationAlerts,
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      platformActivityAlerts:
          platformActivityAlerts ?? this.platformActivityAlerts,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      frequency: frequency ?? this.frequency,
      dailyDigestDelivered: dailyDigestDelivered ?? this.dailyDigestDelivered,
    );
  }
}
