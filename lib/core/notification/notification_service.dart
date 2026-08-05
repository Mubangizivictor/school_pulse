import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/app/router.dart';
import 'package:school_pulse/core/notification/local_notification_service.dart';
import 'package:school_pulse/core/user_roles.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;
  bool _initialized = false;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await LocalNotificationService.initialize();

    // Request permissions for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('User granted permission');
      }

      // Get the token for this device. iOS simulators have no APNs token,
      // so getToken() throws there - that's expected, not a failure worth
      // taking the whole app down over.
      try {
        String? token = await _fcm.getToken();
        final uid = _auth.currentUser?.uid;
        if (token != null && uid != null) {
          await _saveTokenToDatabase(uid, token);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Skipping FCM token (expected on simulators): $e');
        }
      }
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen((token) {
      final uid = _auth.currentUser?.uid;
      if (uid != null) _saveTokenToDatabase(uid, token);
    });

    // Re-sync the token once a user actually signs in - initialize() runs at
    // app startup, often before login, so the first getToken() above may
    // have nothing to attach it to yet.
    _authSub ??= _auth.authStateChanges().listen((user) async {
      if (user != null) {
        syncToken(user.uid);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
      }

      final notification = message.notification;
      if (notification != null) {
        LocalNotificationService.show(
          title: notification.title ?? 'School Pulse',
          body: notification.body ?? '',
        );
      }
    });

    // Tapping the local notification shown above (app was in foreground).
    LocalNotificationService.onNotificationTap = _navigateToNotifications;

    // Tapping a system-tray notification while the app was backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (_) => _navigateToNotifications(),
    );

    // App was cold-launched by tapping a notification (terminated state) -
    // getInitialMessage only ever returns a non-null value once per launch.
    // Timeout guards against this hanging forever on some simulators/devices
    // (observed on iOS), which would otherwise block runApp() and leave the
    // whole app on a permanent blank screen since initialize() is awaited
    // before runApp() in main().
    final initialMessage = await _fcm.getInitialMessage().timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
    if (initialMessage != null) {
      _navigateToNotifications();
    }
  }

  /// Routes to this user's notification center. Staff/admins authenticate
  /// through Firebase Auth directly; parents use a separate "virtual" login
  /// (see syncTopicsForUser), so the presence of a Firebase Auth user is what
  /// distinguishes which notification screen applies.
  void _navigateToNotifications() {
    final path = _auth.currentUser != null
        ? '/staff/notifications'
        : '/parent/notifications';
    router.push(path);
  }

  /// Manually sync the FCM token for a specific user ID.
  /// Used for both Firebase Auth users and "virtual" parent users.
  Future<void> syncToken(String uid) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToDatabase(uid, token);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing FCM token for $uid: $e');
      }
    }
  }

  /// Manually trigger a local notification for testing purposes
  Future<void> testLocalNotification() async {
    try {
      if (kDebugMode) debugPrint('Testing local notification...');
      await LocalNotificationService.show(
        title: "Test Notification",
        body:
            "This is a test notification from School Pulse. Time: ${DateTime.now().hour}:${DateTime.now().minute}",
      );
      if (kDebugMode) debugPrint('Test notification sent successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending test notification: $e');
    }
  }

  /// Sends an urgent security alert to all security personnel
  Future<void> sendSecurityAlert({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await sendBroadcast(
      title: "SECURITY ALERT: $title",
      body: body,
      targetGroups: ['Security', 'Bursars & Admin'],
    );
  }

  /// Tokens are stored per-user so sendDirectNotification (which reads
  /// users/{uid}/tokens) can actually find them.
  Future<void> _saveTokenToDatabase(String uid, String token) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .doc(token)
        .set({
          'token': token,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': defaultTargetPlatform.toString(),
        });
  }

  /// Subscribes this device to the FCM topics needed to receive broadcasts
  /// addressed to one of these groups - the counterpart to the group names
  /// BroadcastSmsScreen writes to `targets` (e.g. 'Parents', 'Class:P.1').
  /// Without this, processBroadcastQueue's admin.messaging().send({topic})
  /// calls succeed but reach zero devices.
  Future<void> subscribeToGroups(List<String> groups) async {
    for (final group in groups) {
      final topic = _topicNameFor(group);
      try {
        await _fcm.subscribeToTopic(topic);
      } catch (e) {
        if (kDebugMode) debugPrint('Error subscribing to topic $topic: $e');
      }
    }
  }

  /// Mirrors the Cloud Function's topic sanitization (functions/index.js
  /// processBroadcastQueue) so a client subscribed via this name actually
  /// matches the topic the server sends to.
  String _topicNameFor(String group) {
    final sanitized = group.replaceAll(RegExp(r'[^a-zA-Z0-9\-_.~%]'), '_');
    return 'topic_$sanitized';
  }

  /// Syncs both the FCM token and topic subscriptions for a freshly
  /// authenticated user (staff or parent) - call this right after login (and
  /// on app-restart auth checks) so broadcasts actually reach this device.
  Future<void> syncTopicsForUser(String uid, List<UserRole> roles) async {
    await syncToken(uid);
    if (roles.contains(UserRole.parent)) {
      // A parent's class-scoped groups can only be resolved server-side
      // (the Admin SDK looks up each child's class), so the login Cloud
      // Function computes and stores them on users/{uid}.groups.
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        final groups = List<String>.from(
          doc.data()?['groups'] as List? ?? const ['Parents'],
        );
        await subscribeToGroups(groups);
      } catch (e) {
        if (kDebugMode)
          debugPrint('Error resolving parent groups for $uid: $e');
        await subscribeToGroups(const ['Parents']);
      }
    } else {
      await subscribeToGroups(NotificationGroups.forRoles(roles));
    }
  }

  /// Sends a broadcast notification to a specific topic
  /// In FCM, "topics" is the standard way to broadcast to groups.
  Future<void> sendBroadcast({
    String? schoolId,
    required String title,
    required String body,
    required List<String> targetGroups,
    bool isSms = false,
    DateTime? scheduledAt,
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    final scheduledTimestamp = scheduledAt != null
        ? Timestamp.fromDate(scheduledAt)
        : null;

    // 1. Create the 'alert' document in Firestore (for the in-app "Audit Log")
    await _firestore.collection('alerts').add({
      if (schoolId != null) 'schoolId': schoolId,
      'title': title,
      'body': body,
      'targets': targetGroups,
      'timestamp': timestamp,
      'scheduledAt': scheduledTimestamp,
      'type': isSms ? 'SMS' : 'Push',
      'status': scheduledAt != null ? 'scheduled' : 'sent',
    });

    if (isSms) {
      // Queue for SMS Gateway (Backend handles this)
      await _firestore.collection('sms_queue').add({
        'body': body,
        'targets': targetGroups,
        'status': scheduledAt != null ? 'scheduled' : 'pending',
        'scheduledAt': scheduledTimestamp,
        'createdAt': timestamp,
      });
    } else {
      // 2. Trigger FCM via broadcast_queue
      await _firestore.collection('broadcast_queue').add({
        'notification': {'title': title, 'body': body},
        'targets': targetGroups,
        'status': scheduledAt != null ? 'scheduled' : 'pending',
        'scheduledAt': scheduledTimestamp,
        'createdAt': timestamp,
      });
    }
  }

  /// Sends a direct notification to a specific user (by UID)
  Future<void> sendDirectNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // 1. Create the alert document for the user
    await _firestore.collection('alerts').add({
      'userId': userId,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [], // Ensure readBy exists for the repository to read
      'type': 'Direct',
    });

    // 2. Trigger push to user's tokens
    final tokensSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .get();

    for (var doc in tokensSnapshot.docs) {
      String token = doc.id;
      // Queue for Cloud Function
      await _firestore.collection('notification_queue').add({
        'token': token,
        'notification': {'title': title, 'body': body},
        'data': data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Sends a child-scoped alert (arrival, departure, pickup, security event)
  /// to every linked parent. Writes a single `alerts` doc keyed by a
  /// top-level `studentId` field - this is the shape
  /// NotificationsRemoteDataSourceImpl._getStudentAlerts queries via
  /// `where('studentId', whereIn: studentIds)`, so it's what actually
  /// surfaces in the parent app's notification center. [sendDirectNotification]
  /// (keyed by `userId`) does NOT satisfy that query.
  Future<void> sendStudentAlert({
    String? schoolId,
    required String studentId,
    required List<String> parentIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('alerts').add({
      if (schoolId != null) 'schoolId': schoolId,
      'studentId': studentId,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [],
      'type': 'Security',
    });

    for (final parentId in parentIds) {
      final tokensSnapshot = await _firestore
          .collection('users')
          .doc(parentId)
          .collection('tokens')
          .get();
      for (final doc in tokensSnapshot.docs) {
        await _firestore.collection('notification_queue').add({
          'token': doc.id,
          'notification': {'title': title, 'body': body},
          'data': {...?data, 'studentId': studentId},
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint("Handling a background message: ${message.messageId}");
    debugPrint('Message data: ${message.data}');
    if (message.notification != null) {
      debugPrint('Message notification: ${message.notification?.title}');
    }
  }
}
