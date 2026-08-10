import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

import '../entities/notification_category_config.dart';
import '../entities/notification_model.dart';
import '../failures/notification_failure.dart';

/// Who a notification is addressed to.
///
/// Mirrors the `audience.kind` values `functions/notifications.js` resolves.
/// Kept as a closed enum so the client cannot invent an audience the server
/// does not understand and silently reach nobody.
enum NotificationAudienceKind {
  users,
  roles,
  classParents,
  studentParents,
  allStaff,
  allParents,
  school,
}

@immutable
class NotificationAudience {
  final NotificationAudienceKind kind;
  final List<String> userIds;
  final List<String> roles;
  final List<String> classNames;
  final List<String> studentIds;

  const NotificationAudience({
    required this.kind,
    this.userIds = const [],
    this.roles = const [],
    this.classNames = const [],
    this.studentIds = const [],
  });

  const NotificationAudience.school()
    : this(kind: NotificationAudienceKind.school);
  const NotificationAudience.allParents()
    : this(kind: NotificationAudienceKind.allParents);
  const NotificationAudience.allStaff()
    : this(kind: NotificationAudienceKind.allStaff);

  /// Server-side field name for [kind]. Snake_case to match the Cloud
  /// Function's switch.
  String get kindName {
    switch (kind) {
      case NotificationAudienceKind.users:
        return 'users';
      case NotificationAudienceKind.roles:
        return 'roles';
      case NotificationAudienceKind.classParents:
        return 'class_parents';
      case NotificationAudienceKind.studentParents:
        return 'student_parents';
      case NotificationAudienceKind.allStaff:
        return 'all_staff';
      case NotificationAudienceKind.allParents:
        return 'all_parents';
      case NotificationAudienceKind.school:
        return 'school';
    }
  }

  Map<String, dynamic> toMap() => {
    'kind': kindName,
    if (userIds.isNotEmpty) 'userIds': userIds,
    if (roles.isNotEmpty) 'roles': roles,
    if (classNames.isNotEmpty) 'classNames': classNames,
    if (studentIds.isNotEmpty) 'studentIds': studentIds,
  };

  /// Human description used in confirmation dialogs, so a sender sees who they
  /// are about to reach before committing.
  String get description {
    switch (kind) {
      case NotificationAudienceKind.school:
        return 'everyone at this school';
      case NotificationAudienceKind.allParents:
        return 'all parents';
      case NotificationAudienceKind.allStaff:
        return 'all staff';
      case NotificationAudienceKind.roles:
        return roles.join(', ');
      case NotificationAudienceKind.classParents:
        return 'parents of ${classNames.join(', ')}';
      case NotificationAudienceKind.studentParents:
        return 'parents of ${studentIds.length} student(s)';
      case NotificationAudienceKind.users:
        return '${userIds.length} recipient(s)';
    }
  }
}

/// Submits notification send requests.
///
/// The client never writes notification documents or calls FCM directly - it
/// writes a `notification_requests` document and a Cloud Function performs the
/// fan-out with the Admin SDK. That is what keeps the FCM credential off the
/// device and lets recipient resolution read data the sender themselves is not
/// permitted to read.
///
/// Using a Firestore write (rather than a callable) means a request survives
/// the app being closed mid-send, and retries are driven by Firestore.
class NotificationSendService {
  final FirebaseFirestore firestore;

  NotificationSendService({required this.firestore});

  static const collection = 'notification_requests';

  /// Submits a send request.
  ///
  /// [scheduledAt] in the future parks the request until the scheduler picks
  /// it up. Returns the request id so the caller can watch delivery counts.
  Future<Either<NotificationFailure, String>> send({
    required UserEntity sender,
    required NotificationAudience audience,
    required NotificationCategory category,
    required NotificationType type,
    required String title,
    required String body,
    String? fullBody,
    NotificationPriority? priority,
    String? imageUrl,
    String? relatedStudentId,
    String? sourceModule,
    String? sourceEntityId,
    bool? requiresAcknowledgment,
    DateTime? scheduledAt,
    DateTime? expiresAt,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();

    if (trimmedTitle.isEmpty || trimmedBody.isEmpty) {
      return const Left(
        NotificationUnknownFailure(debugDetail: 'title and body are required'),
      );
    }

    final config = NotificationCategoryCatalog.of(category);

    try {
      final doc = await firestore.collection(collection).add({
        'schoolId': sender.schoolId,
        'audience': audience.toMap(),
        'category': category.name,
        'type': type.name,
        'title': trimmedTitle,
        'shortBody': trimmedBody,
        if (fullBody != null && fullBody.trim().isNotEmpty)
          'fullBody': fullBody.trim(),
        // Sender identity is stamped from the signed-in user, never accepted
        // as a parameter - the security rules also require senderId to equal
        // the caller, so a request cannot be attributed to somebody else.
        'senderId': sender.id,
        'senderNameSnapshot': sender.name,
        'senderRoleSnapshot': _roleLabel(sender),
        'senderKind': 'human',
        if (sender.photoUrl != null) 'senderPhotoUrl': sender.photoUrl,
        'sourceModule': ?sourceModule,
        'sourceEntityId': ?sourceEntityId,
        'relatedStudentId': ?relatedStudentId,
        if (imageUrl != null && config.allowsImages) 'imageUrl': imageUrl,
        'priority': (priority ?? config.defaultPriority).name,
        'persistence': config.defaultPersistence.name,
        'requiresAcknowledgment':
            requiresAcknowledgment ?? config.requiresAcknowledgment,
        if (scheduledAt != null) 'scheduledAt': Timestamp.fromDate(scheduledAt),
        if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt),
        'status': 'pending',
        // Lets a retried submission be recognised server-side rather than
        // fanning out to every recipient twice.
        'idempotencyKey':
            '${sender.id}-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Right(doc.id);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left(NotificationPermissionFailure(debugDetail: e.message));
      }
      return Left(NotificationServerFailure(debugDetail: e.message));
    } catch (e) {
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  /// Cancels a request that has not gone out yet.
  Future<Either<NotificationFailure, Unit>> cancel(String requestId) async {
    try {
      await firestore.collection(collection).doc(requestId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  /// Live delivery counts for a request the caller sent.
  Stream<NotificationDeliveryReport?> watchDelivery(String requestId) {
    return firestore.collection(collection).doc(requestId).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return NotificationDeliveryReport.fromMap(requestId, data);
    });
  }

  /// Requests this sender has submitted, newest first.
  Stream<List<NotificationDeliveryReport>> watchMyRequests({
    required String schoolId,
    required String senderId,
    int limit = 30,
  }) {
    return firestore
        .collection(collection)
        .where('schoolId', isEqualTo: schoolId)
        .where('senderId', isEqualTo: senderId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => NotificationDeliveryReport.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// Best available label for the sender's role, for the identity snapshot.
  static String _roleLabel(UserEntity sender) {
    if (sender.roles.isEmpty) return 'Staff';
    return UserRoleDisplay.name(sender.roles.first);
  }
}

/// Delivery outcome for one send request, as recorded by the Cloud Function.
@immutable
class NotificationDeliveryReport {
  final String requestId;
  final String title;
  final String status;
  final int recipientCount;
  final int deviceCount;
  final int successCount;
  final int failureCount;
  final DateTime? createdAt;
  final DateTime? sentAt;
  final DateTime? scheduledAt;
  final String? error;

  const NotificationDeliveryReport({
    required this.requestId,
    required this.title,
    required this.status,
    this.recipientCount = 0,
    this.deviceCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.createdAt,
    this.sentAt,
    this.scheduledAt,
    this.error,
  });

  factory NotificationDeliveryReport.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return NotificationDeliveryReport(
      requestId: id,
      title: data['title'] as String? ?? 'Notification',
      status: data['status'] as String? ?? 'pending',
      recipientCount: (data['recipientCount'] as num?)?.toInt() ?? 0,
      deviceCount: (data['deviceCount'] as num?)?.toInt() ?? 0,
      successCount: (data['successCount'] as num?)?.toInt() ?? 0,
      failureCount: (data['failureCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      error: data['error'] as String?,
    );
  }

  bool get isPending => status == 'pending' || status == 'processing';
  bool get isScheduled => status == 'scheduled';
  bool get isSent => status == 'sent';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  /// Share of targeted devices FCM accepted the message for. Null while the
  /// request has not been dispatched, so the UI shows "pending" rather than a
  /// misleading 0%.
  double? get successRate {
    if (!isSent || deviceCount == 0) return null;
    return successCount / deviceCount;
  }
}
