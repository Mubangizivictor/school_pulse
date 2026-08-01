import 'package:flutter/material.dart';

import '../entities/notification_category_config.dart';
import '../entities/notification_model.dart';
import '../entities/notification_preferences.dart';

/// Why a notification was or was not surfaced. Returned rather than a bare
/// bool so delivery analytics can record the reason a push was suppressed.
enum DeliveryDecision {
  /// Show it, with sound/vibration per preferences.
  deliver,

  /// Store it in the notification centre but do not alert the device. Used for
  /// quiet hours and digest-batched categories.
  deliverSilently,

  /// Do not surface at all - the user or school switched this category off.
  suppress,
}

@immutable
class DeliveryEvaluation {
  final DeliveryDecision decision;
  final String reason;

  /// Effective preview text permitted on the lock screen, after applying the
  /// stricter of the user's and the school's setting plus category sensitivity.
  final LockScreenPreview preview;

  final bool playSound;
  final bool vibrate;

  const DeliveryEvaluation({
    required this.decision,
    required this.reason,
    required this.preview,
    required this.playSound,
    required this.vibrate,
  });

  bool get shouldAlertDevice => decision == DeliveryDecision.deliver;
  bool get shouldStore => decision != DeliveryDecision.suppress;
}

/// Decides whether and how a notification reaches the user.
///
/// Deliberately pure and dependency-free so the same rules can be exercised in
/// unit tests, applied client-side when a push arrives, and mirrored by the
/// Cloud Function that decides whether to send in the first place.
///
/// Precedence, strictest first:
///   1. Emergency and other mandatory categories always deliver.
///   2. School policy disabling a category beats a user opting in.
///   3. User preference disabling a category.
///   4. Quiet hours downgrade to silent (never to suppressed).
class NotificationDeliveryPolicy {
  const NotificationDeliveryPolicy._();

  static DeliveryEvaluation evaluate({
    required NotificationItem notification,
    required NotificationPreferences preferences,
    SchoolNotificationPolicy? schoolPolicy,
    DateTime? now,
  }) {
    final config = NotificationCategoryCatalog.of(notification.category);
    final at = now ?? DateTime.now();

    final preview = _effectivePreview(
      user: preferences.lockScreenPreview,
      schoolMax: schoolPolicy?.maxLockScreenPreview ?? LockScreenPreview.full,
      categoryIsSensitive: config.isSensitive,
    );

    // 1. Mandatory categories bypass every switch below. An emergency alert
    //    must reach the user even if they muted everything and it is 2am.
    final isMandatory = config.isMandatory ||
        (schoolPolicy?.mandatoryCategories.contains(notification.category) ??
            false);
    final isUrgent = notification.priority == NotificationPriority.urgent;

    if (isMandatory || isUrgent) {
      return DeliveryEvaluation(
        decision: DeliveryDecision.deliver,
        reason: isUrgent ? 'urgent_priority' : 'mandatory_category',
        preview: preview,
        // Safety alerts ignore the silent-mode preference deliberately.
        playSound: true,
        vibrate: true,
      );
    }

    // 2. School-level kill switch.
    if (schoolPolicy?.disabledCategories.contains(notification.category) ??
        false) {
      return DeliveryEvaluation(
        decision: DeliveryDecision.suppress,
        reason: 'disabled_by_school',
        preview: preview,
        playSound: false,
        vibrate: false,
      );
    }

    // 3. User opt-out. Absent from the map means enabled.
    final userEnabled = preferences.categoryEnabled[notification.category] ?? true;
    if (!userEnabled) {
      return DeliveryEvaluation(
        decision: DeliveryDecision.suppress,
        reason: 'disabled_by_user',
        preview: preview,
        playSound: false,
        vibrate: false,
      );
    }

    // 4. Quiet hours. Downgrades to silent rather than suppressing, so the
    //    notification is still waiting in the centre in the morning.
    if (_inQuietHours(preferences, schoolPolicy, at)) {
      return DeliveryEvaluation(
        decision: DeliveryDecision.deliverSilently,
        reason: 'quiet_hours',
        preview: preview,
        playSound: false,
        vibrate: false,
      );
    }

    // Low-priority categories are batched when the user opted into a digest.
    if (preferences.dailyDigest &&
        notification.priority == NotificationPriority.low) {
      return DeliveryEvaluation(
        decision: DeliveryDecision.deliverSilently,
        reason: 'batched_into_digest',
        preview: preview,
        playSound: false,
        vibrate: false,
      );
    }

    return DeliveryEvaluation(
      decision: DeliveryDecision.deliver,
      reason: 'allowed',
      preview: preview,
      playSound: preferences.soundEnabled,
      vibrate: preferences.vibrationEnabled,
    );
  }

  /// The stricter of the user's choice and the school's ceiling. Sensitive
  /// categories (medical, finance, discipline, counselling, safeguarding) are
  /// clamped to at most sender+title regardless of either setting.
  static LockScreenPreview _effectivePreview({
    required LockScreenPreview user,
    required LockScreenPreview schoolMax,
    required bool categoryIsSensitive,
  }) {
    // Enum order runs full -> senderAndTitle -> hidden, so a larger index is
    // strictly more private and `max` picks the more restrictive option.
    var strictest = user.index > schoolMax.index ? user : schoolMax;
    if (categoryIsSensitive &&
        strictest.index < LockScreenPreview.senderAndTitle.index) {
      strictest = LockScreenPreview.senderAndTitle;
    }
    return strictest;
  }

  /// True when [at] falls inside the user's quiet hours, or the school's if the
  /// user has not set their own. Handles windows that cross midnight.
  static bool _inQuietHours(
    NotificationPreferences preferences,
    SchoolNotificationPolicy? schoolPolicy,
    DateTime at,
  ) {
    TimeOfDay? start = preferences.quietHoursStart;
    TimeOfDay? end = preferences.quietHoursEnd;

    if (start == null || end == null) {
      start = schoolPolicy?.quietHoursStart;
      end = schoolPolicy?.quietHoursEnd;
    }
    if (start == null || end == null) return false;

    final nowMinutes = at.hour * 60 + at.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    // Same-day window, e.g. 13:00-14:00.
    if (startMinutes <= endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
    // Overnight window, e.g. 21:00-06:00.
    return nowMinutes >= startMinutes || nowMinutes < endMinutes;
  }

  /// Whether the full image may be fetched now, given the download policy and
  /// current connection. Thumbnails are always permitted - they are small and
  /// the list would otherwise look broken on mobile data.
  static bool mayDownloadFullImage({
    required ImageDownloadPolicy policy,
    required bool isOnWifi,
  }) {
    switch (policy) {
      case ImageDownloadPolicy.always:
        return true;
      case ImageDownloadPolicy.wifiOnly:
        return isOnWifi;
      case ImageDownloadPolicy.never:
        return false;
    }
  }

  /// Whether a notification should be removed from the centre once its source
  /// has been opened. True only for transient categories such as chat pings.
  static bool shouldClearOnOpen(NotificationItem notification) {
    if (notification.persistence == NotificationPersistence.permanent) {
      return false;
    }
    return !NotificationCategoryCatalog.of(notification.category).persistsAfterOpen;
  }

  /// Retention cutoff for a category, honouring a school-wide override.
  /// Returns null when records are kept indefinitely (emergency notices).
  static DateTime? retentionCutoff({
    required NotificationCategory category,
    SchoolNotificationPolicy? schoolPolicy,
    DateTime? now,
  }) {
    final override = schoolPolicy?.retentionDaysOverride;
    final days = override ?? NotificationCategoryCatalog.of(category).retentionDays;
    if (days == null) return null;
    return (now ?? DateTime.now()).subtract(Duration(days: days));
  }
}
