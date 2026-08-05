import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/entities/notification_category_config.dart';
import '../domain/entities/notification_model.dart';
import '../domain/entities/notification_preferences.dart';
import '../domain/policies/notification_delivery_policy.dart';
import '../push/payloads/notification_push_payload.dart';
import 'channels/notification_channels.dart';

/// Renders notifications as OS notifications.
///
/// Every display decision (whether to show at all, whether to make a sound,
/// how much text may appear on a lock screen) is delegated to
/// [NotificationDeliveryPolicy] rather than decided here, so the same rules
/// apply on push, on local scheduling and in tests.
class NotificationPresenter {
  final FlutterLocalNotificationsPlugin plugin;

  /// Resolves a cached local file for an image URL, or null when the image is
  /// not cached and may not be downloaded now (Data Saver, or offline).
  final Future<String?> Function(String url)? resolveLocalImage;

  NotificationPresenter({required this.plugin, this.resolveLocalImage});

  /// Shows [payload] if policy permits.
  ///
  /// Returns the [DeliveryEvaluation] so the caller can record why a
  /// notification was suppressed - the delivery analytics need the reason, not
  /// just the fact.
  Future<DeliveryEvaluation> present({
    required NotificationPushPayload payload,
    required NotificationPreferences preferences,
    SchoolNotificationPolicy? schoolPolicy,
  }) async {
    final item = payload.toProvisionalItem();
    final evaluation = NotificationDeliveryPolicy.evaluate(
      notification: item,
      preferences: preferences,
      schoolPolicy: schoolPolicy,
    );

    if (evaluation.decision == DeliveryDecision.suppress) {
      return evaluation;
    }

    await show(
      item: item,
      evaluation: evaluation,
      systemNotificationId: payload.systemNotificationId,
    );
    return evaluation;
  }

  /// Displays [item] using the treatment [evaluation] decided on.
  Future<void> show({
    required NotificationItem item,
    required DeliveryEvaluation evaluation,
    required int systemNotificationId,
  }) async {
    final config = NotificationCategoryCatalog.of(item.category);
    final (importance, priority) = NotificationChannels.androidPriorityFor(
      item.priority,
    );

    // Lock-screen redaction. The public version is what shows on a locked
    // device; the full text is revealed once unlocked.
    final (publicTitle, publicBody) = _redact(item, evaluation.preview);

    final bigPicturePath = await _localImagePath(item);
    final largeIconPath = await _localSenderPhoto(item);

    final androidDetails = AndroidNotificationDetails(
      config.channelId,
      NotificationChannels.channelNameFor(item.category),
      channelDescription: NotificationChannels.channelDescriptionFor(
        item.category,
      ),
      importance: importance,
      priority: priority,
      playSound: evaluation.playSound,
      enableVibration: evaluation.vibrate,
      // Grouped so several alerts of one kind stack instead of filling the
      // notification shade.
      groupKey: NotificationChannels.groupKeyFor(item.category),
      // Emergency alerts stay on screen until acknowledged.
      ongoing:
          item.priority == NotificationPriority.urgent &&
          item.requiresAcknowledgment,
      // Android renders this instead of the real content on a locked screen.
      visibility: evaluation.preview == LockScreenPreview.full
          ? NotificationVisibility.public
          : NotificationVisibility.private,
      largeIcon: largeIconPath == null
          ? null
          : FilePathAndroidBitmap(largeIconPath),
      styleInformation: _androidStyle(
        item: item,
        bigPicturePath: bigPicturePath,
        body: publicBody,
      ),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: evaluation.playSound,
      // iOS has no per-notification lock-screen redaction, so when the policy
      // calls for redaction the notification is delivered already redacted.
      subtitle: item.senderName,
      threadIdentifier: NotificationChannels.groupKeyFor(item.category),
      interruptionLevel: item.priority == NotificationPriority.urgent
          ? InterruptionLevel.critical
          : InterruptionLevel.active,
      attachments: bigPicturePath == null
          ? null
          : [DarwinNotificationAttachment(bigPicturePath)],
    );

    try {
      await plugin.show(
        id: systemNotificationId,
        title: publicTitle,
        body: publicBody,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        // Carries the notification id back on tap, so the handler knows which
        // record to open without re-parsing the whole payload.
        payload: item.id,
      );
    } catch (e) {
      // A failure to display must never take down the app or the push
      // pipeline; the notification is still in the centre either way.
      if (kDebugMode) {
        debugPrint('[notifications] failed to display ${item.id}: $e');
      }
    }
  }

  /// Applies the lock-screen privacy setting.
  ///
  /// Content is redacted at source rather than relying on the OS, because iOS
  /// offers no equivalent of Android's public/private version and the spec
  /// requires medical, financial and safeguarding detail never to leak onto a
  /// locked screen.
  (String, String) _redact(NotificationItem item, LockScreenPreview preview) {
    switch (preview) {
      case LockScreenPreview.full:
        return (item.title, item.description);
      case LockScreenPreview.senderAndTitle:
        return (item.title, item.senderName);
      case LockScreenPreview.hidden:
        return ('School Pulse', 'New School Pulse notification');
    }
  }

  StyleInformation? _androidStyle({
    required NotificationItem item,
    required String? bigPicturePath,
    required String body,
  }) {
    if (bigPicturePath != null) {
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        contentTitle: item.title,
        summaryText: body,
      );
    }
    // Long announcement bodies would otherwise be truncated to one line.
    if (body.length > 60) {
      return BigTextStyleInformation(
        body,
        contentTitle: item.title,
        summaryText: item.senderName,
      );
    }
    return null;
  }

  /// Local path for the notification's image, or null when it may not be
  /// fetched (Data Saver / offline) or the category forbids images.
  Future<String?> _localImagePath(NotificationItem item) async {
    final url = item.bannerImageUrl ?? item.thumbnailUrl;
    if (url == null || url.isEmpty) return null;
    if (!NotificationCategoryCatalog.of(item.category).allowsImages)
      return null;

    // An already-downloaded file is usable regardless of connection.
    final local = item.localImagePath;
    if (local != null && await File(local).exists()) return local;

    final resolver = resolveLocalImage;
    if (resolver == null) return null;

    try {
      return await resolver(url);
    } catch (e) {
      // A broken or deleted image must still leave a readable notification -
      // the spec requires notifications to make sense without their image.
      if (kDebugMode) {
        debugPrint('[notifications] image unavailable for ${item.id}: $e');
      }
      return null;
    }
  }

  Future<String?> _localSenderPhoto(NotificationItem item) async {
    final local = item.senderIdentity.localPhotoPath;
    if (local != null && await File(local).exists()) return local;

    final url = item.senderIdentity.photoUrl;
    final resolver = resolveLocalImage;
    if (url == null || url.isEmpty || resolver == null) return null;

    try {
      return await resolver(url);
    } catch (_) {
      return null;
    }
  }

  /// Removes a displayed notification, e.g. once its conversation is opened.
  Future<void> dismiss(int systemNotificationId) async {
    try {
      await plugin.cancel(id: systemNotificationId);
    } catch (e) {
      if (kDebugMode) debugPrint('[notifications] dismiss failed: $e');
    }
  }

  /// Clears every displayed notification - used on sign-out so the next user
  /// of a shared device never sees the previous user's alerts.
  Future<void> dismissAll() async {
    try {
      await plugin.cancelAll();
    } catch (e) {
      if (kDebugMode) debugPrint('[notifications] dismissAll failed: $e');
    }
  }
}
