import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_preferences.dart';

/// Firestore serialisation for user notification preferences and the
/// school-wide policy that constrains them.
///
/// Times are stored as `"HH:mm"` strings rather than timestamps: quiet hours
/// are a wall-clock concept ("no pings after 21:00"), so they must not shift
/// when a user travels or when the server applies a timezone.
class NotificationPreferencesMapper {
  const NotificationPreferencesMapper._();

  static NotificationPreferences fromFirestore(
    Map<String, dynamic> data, {
    required String userId,
    required String schoolId,
  }) {
    return NotificationPreferences(
      userId: userId,
      schoolId: schoolId,
      categoryEnabled: _categoryMapFrom(data['categoryEnabled']),
      soundEnabled: data['soundEnabled'] as bool? ?? true,
      vibrationEnabled: data['vibrationEnabled'] as bool? ?? true,
      badgeEnabled: data['badgeEnabled'] as bool? ?? true,
      lockScreenPreview: _enumFromName(
        LockScreenPreview.values,
        data['lockScreenPreview'] as String?,
        LockScreenPreview.senderAndTitle,
      ),
      imageDownloadPolicy: _enumFromName(
        ImageDownloadPolicy.values,
        data['imageDownloadPolicy'] as String?,
        ImageDownloadPolicy.wifiOnly,
      ),
      quietHoursStart: _timeFrom(data['quietHoursStart']),
      quietHoursEnd: _timeFrom(data['quietHoursEnd']),
      emailCopies: data['emailCopies'] as bool? ?? false,
      smsCopies: data['smsCopies'] as bool? ?? false,
      dailyDigest: data['dailyDigest'] as bool? ?? false,
      weeklyDigest: data['weeklyDigest'] as bool? ?? false,
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toFirestore(NotificationPreferences p) {
    return {
      'categoryEnabled': {
        for (final entry in p.categoryEnabled.entries)
          entry.key.name: entry.value,
      },
      'soundEnabled': p.soundEnabled,
      'vibrationEnabled': p.vibrationEnabled,
      'badgeEnabled': p.badgeEnabled,
      'lockScreenPreview': p.lockScreenPreview.name,
      'imageDownloadPolicy': p.imageDownloadPolicy.name,
      // Explicitly deleted rather than omitted, so clearing quiet hours in the
      // app actually removes them server-side instead of leaving stale values
      // that a merge write would preserve.
      'quietHoursStart': p.quietHoursStart == null
          ? FieldValue.delete()
          : _timeToString(p.quietHoursStart!),
      'quietHoursEnd': p.quietHoursEnd == null
          ? FieldValue.delete()
          : _timeToString(p.quietHoursEnd!),
      'emailCopies': p.emailCopies,
      'smsCopies': p.smsCopies,
      'dailyDigest': p.dailyDigest,
      'weeklyDigest': p.weeklyDigest,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static SchoolNotificationPolicy policyFromFirestore(
    Map<String, dynamic> data,
    String schoolId,
  ) {
    return SchoolNotificationPolicy(
      schoolId: schoolId,
      disabledCategories: _categorySetFrom(data['disabledCategories']),
      mandatoryCategories: _categorySetFrom(data['mandatoryCategories']),
      allowImages: data['allowImages'] as bool? ?? true,
      allowAttachments: data['allowAttachments'] as bool? ?? true,
      maxLockScreenPreview: _enumFromName(
        LockScreenPreview.values,
        data['maxLockScreenPreview'] as String?,
        LockScreenPreview.full,
      ),
      quietHoursStart: _timeFrom(data['quietHoursStart']),
      quietHoursEnd: _timeFrom(data['quietHoursEnd']),
      retentionDaysOverride: (data['retentionDaysOverride'] as num?)?.toInt(),
      senderRateLimitPerHour: (data['senderRateLimitPerHour'] as num?)?.toInt(),
      parentVisibility: data['parentVisibility'] as bool? ?? true,
      studentVisibility: data['studentVisibility'] as bool? ?? true,
      staffVisibility: data['staffVisibility'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> policyToFirestore(SchoolNotificationPolicy p) {
    return {
      'disabledCategories': p.disabledCategories.map((c) => c.name).toList(),
      'mandatoryCategories': p.mandatoryCategories.map((c) => c.name).toList(),
      'allowImages': p.allowImages,
      'allowAttachments': p.allowAttachments,
      'maxLockScreenPreview': p.maxLockScreenPreview.name,
      if (p.quietHoursStart != null)
        'quietHoursStart': _timeToString(p.quietHoursStart!),
      if (p.quietHoursEnd != null)
        'quietHoursEnd': _timeToString(p.quietHoursEnd!),
      if (p.retentionDaysOverride != null)
        'retentionDaysOverride': p.retentionDaysOverride,
      if (p.senderRateLimitPerHour != null)
        'senderRateLimitPerHour': p.senderRateLimitPerHour,
      'parentVisibility': p.parentVisibility,
      'studentVisibility': p.studentVisibility,
      'staffVisibility': p.staffVisibility,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // --- helpers -------------------------------------------------------------

  static Map<NotificationCategory, bool> _categoryMapFrom(dynamic value) {
    if (value is! Map) return const {};
    final result = <NotificationCategory, bool>{};
    value.forEach((k, v) {
      final category = _categoryByName(k.toString());
      if (category != null && v is bool) result[category] = v;
    });
    return result;
  }

  static Set<NotificationCategory> _categorySetFrom(dynamic value) {
    if (value is! List) return const {};
    return value
        .map((e) => _categoryByName(e.toString()))
        .whereType<NotificationCategory>()
        .toSet();
  }

  /// Unknown category names are dropped rather than throwing - a school
  /// document written by a newer app version must not break an older client.
  static NotificationCategory? _categoryByName(String name) {
    for (final c in NotificationCategory.values) {
      if (c.name == name) return c;
    }
    return null;
  }

  static T _enumFromName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  /// Parses `"HH:mm"`. Returns null for anything malformed or out of range.
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

  static DateTime? _dateFrom(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
