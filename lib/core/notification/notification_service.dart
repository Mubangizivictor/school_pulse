import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/notification/local_notification_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await LocalNotificationService.initialize();

    // Request permissions for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }

      // Get the token for this device. iOS simulators have no APNs token,
      // so getToken() throws there - that's expected, not a failure worth
      // taking the whole app down over.
      try {
        String? token = await _fcm.getToken();
        if (token != null) {
          await _saveTokenToDatabase(token);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Skipping FCM token (expected on simulators): $e');
        }
      }
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // Re-sync the token once a user actually signs in - initialize() runs at
    // app startup, often before login, so the first getToken() above may
    // have nothing to attach it to yet.
    _authSub ??= _auth.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          final token = await _fcm.getToken();
          if (token != null) await _saveTokenToDatabase(token);
        } catch (e) {
          if (kDebugMode) {
            print('Skipping FCM token (expected on simulators): $e');
          }
        }
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      final notification = message.notification;
      if (notification != null) {
        LocalNotificationService.show(
          title: notification.title ?? 'School Pulse',
          body: notification.body ?? '',
        );
      }
    });
  }

  /// Tokens are stored per-user so sendDirectNotification (which reads
  /// users/{uid}/tokens) can actually find them - a token saved before
  /// login has no uid to attach to yet, so it's simply skipped and will be
  /// retried by the auth-state listener above once the user signs in.
  Future<void> _saveTokenToDatabase(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
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

  /// Sends a broadcast notification to a specific topic
  /// In FCM, "topics" is the standard way to broadcast to groups.
  Future<void> sendBroadcast({
    required String title,
    required String body,
    required List<String> targetGroups,
    bool isSms = false,
    DateTime? scheduledAt,
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    final scheduledTimestamp = scheduledAt != null ? Timestamp.fromDate(scheduledAt) : null;

    // 1. Create the 'alert' document in Firestore (for the in-app "Audit Log")
    await _firestore.collection('alerts').add({
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
        'notification': {
          'title': title,
          'body': body,
        },
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
      'read': false,
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
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}
