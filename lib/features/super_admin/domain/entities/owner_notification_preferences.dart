import 'package:flutter/material.dart';

/// Delivery frequency for non-critical owner notifications.
///
/// Only the two values the backend callable
/// (`public_functions/owner_notification_preferences.js`) accepts:
/// `realtime` and `daily_digest`.
enum OwnerNotificationFrequency {
  realtime,
  dailyDigest;

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
/// Matches the redesigned owner "Notification settings" screen:
///  * Delivery: in-app + push toggles.
///  * Categories: Payments, Platform health, Schools, Security, Weekly
///    digest.
///  * Preferences: quiet hours, digest frequency.
///
/// There is deliberately no per-category "critical" switch: a degraded
/// platform, a security alert or a payment failure is always delivered.
/// Turning *Platform health* or *Security* off here only suppresses the
/// routine / informational entries in those categories.
@immutable
class OwnerNotificationPreferences {
  final String ownerId;

  // Delivery channels.
  final bool inAppEnabled;
  final bool pushEnabled;
  final bool emailEnabled;

  // Category toggles (routine / non-critical entries only).
  final bool paymentAlerts;
  final bool platformHealthAlerts;
  final bool schoolAlerts;
  final bool securityAlerts;
  final bool weeklyDigestEnabled;

  /// Legacy aliases kept so existing callers/tests keep compiling. Billing
  /// and school-application alerts are folded into [paymentAlerts] /
  /// [schoolAlerts]; "platform activity" into [platformHealthAlerts].
  bool get billingAlerts => paymentAlerts;
  bool get schoolApplicationAlerts => schoolAlerts;
  bool get platformActivityAlerts => platformHealthAlerts;

  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  final OwnerNotificationFrequency frequency;

  final bool dailyDigestDelivered;

  const OwnerNotificationPreferences({
    required this.ownerId,
    this.inAppEnabled = true,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.paymentAlerts = true,
    this.platformHealthAlerts = true,
    this.schoolAlerts = true,
    this.securityAlerts = true,
    this.weeklyDigestEnabled = true,
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
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? paymentAlerts,
    bool? platformHealthAlerts,
    bool? schoolAlerts,
    bool? securityAlerts,
    bool? weeklyDigestEnabled,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    OwnerNotificationFrequency? frequency,
    bool? dailyDigestDelivered,
    // Legacy names — folded onto the new fields.
    bool? billingAlerts,
    bool? schoolApplicationAlerts,
    bool? platformActivityAlerts,
  }) {
    return OwnerNotificationPreferences(
      ownerId: ownerId,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      paymentAlerts:
          paymentAlerts ?? billingAlerts ?? this.paymentAlerts,
      platformHealthAlerts: platformHealthAlerts ??
          platformActivityAlerts ??
          this.platformHealthAlerts,
      schoolAlerts:
          schoolAlerts ?? schoolApplicationAlerts ?? this.schoolAlerts,
      securityAlerts: securityAlerts ?? this.securityAlerts,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      frequency: frequency ?? this.frequency,
      dailyDigestDelivered: dailyDigestDelivered ?? this.dailyDigestDelivered,
    );
  }

  bool sameAs(OwnerNotificationPreferences other) =>
      inAppEnabled == other.inAppEnabled &&
      pushEnabled == other.pushEnabled &&
      emailEnabled == other.emailEnabled &&
      paymentAlerts == other.paymentAlerts &&
      platformHealthAlerts == other.platformHealthAlerts &&
      schoolAlerts == other.schoolAlerts &&
      securityAlerts == other.securityAlerts &&
      weeklyDigestEnabled == other.weeklyDigestEnabled &&
      quietHoursEnabled == other.quietHoursEnabled &&
      quietHoursStart == other.quietHoursStart &&
      quietHoursEnd == other.quietHoursEnd &&
      frequency == other.frequency;
}
