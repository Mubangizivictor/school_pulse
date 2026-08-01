import 'package:isar/isar.dart';

part 'notification_token_isar.g.dart';

/// Locally-held record of this device's FCM registration token.
///
/// Kept on-device so the app can tell whether the token it currently holds has
/// already been published to Firestore for the signed-in user. Without this,
/// every cold start re-writes the same token document, which costs a write per
/// launch per user for no benefit.
///
/// One row per (user, token) pair: a shared device used by two staff members
/// keeps a row each, so signing one of them out revokes only their own
/// registration.
@collection
class NotificationTokenIsar {
  Id id = Isar.autoIncrement;

  /// The FCM token itself.
  @Index(unique: true, replace: true, composite: [CompositeIndex('userId')])
  late String token;

  late String userId;
  late String schoolId;

  /// `android` | `ios` | `web` | `macos` | `windows` | `linux`.
  late String platform;

  /// When this token was last successfully written to Firestore. Null means it
  /// has never been published - the sync path treats that as work to do.
  DateTime? publishedAt;

  /// Last time the app confirmed this token is still the live one for this
  /// device. Refreshed on each successful sync so stale tokens can be pruned.
  DateTime? lastSeenAt;

  /// Set when logout could not reach the server, so the token document still
  /// needs deleting. Drained on next connectivity.
  late bool pendingRevocation;

  /// Topics this device is currently subscribed to. Compared against the
  /// desired set on login so only the difference is applied, rather than
  /// re-subscribing to every topic on each launch.
  List<String> subscribedTopics = const [];

  NotificationTokenIsar();

  NotificationTokenIsar.create({
    required this.token,
    required this.userId,
    required this.schoolId,
    required this.platform,
    this.publishedAt,
    this.lastSeenAt,
    this.pendingRevocation = false,
    this.subscribedTopics = const [],
  });

  bool get needsPublishing => publishedAt == null;
}
