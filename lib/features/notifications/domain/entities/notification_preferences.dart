import 'package:flutter/material.dart';

import 'notification_model.dart';

/// How much of a notification may appear on a locked screen.
enum LockScreenPreview {
  /// Full title and body.
  full,

  /// Sender and title only - body withheld.
  senderAndTitle,

  /// Neither - just "New School Pulse notification".
  hidden,
}

/// When notification images may be downloaded automatically.
enum ImageDownloadPolicy { always, wifiOnly, never }

/// A user's own notification settings.
///
/// Category switches live in [categoryEnabled]; a category absent from the map
/// is treated as enabled. Mandatory categories (emergency, medical, attendance,
/// security) are filtered out by [isCategoryEnabled] regardless of what is
/// stored, so a stale preference row can never suppress a safety alert.
@immutable
class NotificationPreferences {
  final String userId;
  final String schoolId;

  final Map<NotificationCategory, bool> categoryEnabled;

  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool badgeEnabled;

  final LockScreenPreview lockScreenPreview;
  final ImageDownloadPolicy imageDownloadPolicy;

  /// Suppresses non-urgent pushes between these times. Both null = disabled.
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  final bool emailCopies;
  final bool smsCopies;

  /// Opt-in periodic summary instead of individual low-priority pushes.
  final bool dailyDigest;
  final bool weeklyDigest;

  final DateTime? updatedAt;

  const NotificationPreferences({
    required this.userId,
    required this.schoolId,
    this.categoryEnabled = const {},
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.badgeEnabled = true,
    this.lockScreenPreview = LockScreenPreview.senderAndTitle,
    this.imageDownloadPolicy = ImageDownloadPolicy.wifiOnly,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.emailCopies = false,
    this.smsCopies = false,
    this.dailyDigest = false,
    this.weeklyDigest = false,
    this.updatedAt,
  });

  /// Sensible starting point for a user who has never opened settings.
  ///
  /// Defaults to `wifiOnly` images and a redacted lock screen because the
  /// deployment context is mobile-data-heavy and notifications routinely carry
  /// student names.
  factory NotificationPreferences.defaults({
    required String userId,
    required String schoolId,
  }) {
    return NotificationPreferences(userId: userId, schoolId: schoolId);
  }

  bool get quietHoursConfigured =>
      quietHoursStart != null && quietHoursEnd != null;

  NotificationPreferences copyWith({
    Map<NotificationCategory, bool>? categoryEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? badgeEnabled,
    LockScreenPreview? lockScreenPreview,
    ImageDownloadPolicy? imageDownloadPolicy,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool clearQuietHours = false,
    bool? emailCopies,
    bool? smsCopies,
    bool? dailyDigest,
    bool? weeklyDigest,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      userId: userId,
      schoolId: schoolId,
      categoryEnabled: categoryEnabled ?? this.categoryEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      badgeEnabled: badgeEnabled ?? this.badgeEnabled,
      lockScreenPreview: lockScreenPreview ?? this.lockScreenPreview,
      imageDownloadPolicy: imageDownloadPolicy ?? this.imageDownloadPolicy,
      quietHoursStart:
          clearQuietHours ? null : (quietHoursStart ?? this.quietHoursStart),
      quietHoursEnd:
          clearQuietHours ? null : (quietHoursEnd ?? this.quietHoursEnd),
      emailCopies: emailCopies ?? this.emailCopies,
      smsCopies: smsCopies ?? this.smsCopies,
      dailyDigest: dailyDigest ?? this.dailyDigest,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// School-level notification policy, configured by a School Admin.
///
/// Sits above user preferences: a school may force a category on (making it
/// mandatory for everyone) or disable it outright for the whole tenant.
@immutable
class SchoolNotificationPolicy {
  final String schoolId;

  /// Categories switched off for the entire school.
  final Set<NotificationCategory> disabledCategories;

  /// Categories users may not opt out of, beyond the built-in mandatory set.
  final Set<NotificationCategory> mandatoryCategories;

  final bool allowImages;
  final bool allowAttachments;

  /// Ceiling on lock-screen detail for the whole tenant. A user may choose a
  /// stricter setting than this, never a looser one.
  final LockScreenPreview maxLockScreenPreview;

  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  /// Overrides the per-category retention default when set.
  final int? retentionDaysOverride;

  /// Cap on notifications a single sender may originate per hour.
  final int? senderRateLimitPerHour;

  final bool parentVisibility;
  final bool studentVisibility;
  final bool staffVisibility;

  const SchoolNotificationPolicy({
    required this.schoolId,
    this.disabledCategories = const {},
    this.mandatoryCategories = const {},
    this.allowImages = true,
    this.allowAttachments = true,
    this.maxLockScreenPreview = LockScreenPreview.full,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.retentionDaysOverride,
    this.senderRateLimitPerHour,
    this.parentVisibility = true,
    this.studentVisibility = true,
    this.staffVisibility = true,
  });

  factory SchoolNotificationPolicy.defaults(String schoolId) =>
      SchoolNotificationPolicy(schoolId: schoolId);
}
