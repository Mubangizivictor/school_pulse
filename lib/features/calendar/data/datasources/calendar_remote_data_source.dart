import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import '../../domain/entities/school_event.dart';
import '../models/school_event_model.dart';

abstract class CalendarRemoteDataSource {
  Future<List<SchoolEventModel>> getUpcomingEvents();
  Future<void> addEvent(SchoolEventModel event);
  Future<void> deleteEvent(String eventId);
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final FirebaseFirestore firestore;

  CalendarRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<SchoolEventModel>> getUpcomingEvents() async {
    final now = DateTime.now();

    // 1. Cleanup: Remove events that have already passed.
    // We do this here so it happens automatically as users view the calendar.
    try {
      final oldEvents = await firestore
          .collection('school_events')
          .where('date', isLessThan: Timestamp.fromDate(now))
          .get();
      
      if (oldEvents.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in oldEvents.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      // Log error but don't block fetching upcoming events
      debugPrint('Error cleaning up old events: $e');
    }

    // 2. Fetch upcoming events (current and future)
    final snapshot = await firestore
        .collection('school_events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('date', descending: false)
        .get();

    return snapshot.docs.map((doc) => SchoolEventModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addEvent(SchoolEventModel event) async {
    // An existing id means this is an edit to an already-announced event -
    // only a genuinely new event (empty id, Firestore assigns one) should
    // trigger a fresh broadcast.
    final isNewEvent = event.id.isEmpty;

    if (!isNewEvent) {
      await firestore.collection('school_events').doc(event.id).set(event.toFirestore());
    } else {
      await firestore.collection('school_events').add(event.toFirestore());
    }

    if (isNewEvent) {
      try {
        await NotificationService().sendBroadcast(
          title: 'New School Event: ${event.title}',
          body: event.description,
          targetGroups: event.targetGroups.isEmpty ? defaultEventTargetGroups : event.targetGroups,
        );
      } catch (e) {
        if (kDebugMode) print('Error broadcasting calendar event: $e');
      }

      AuditRepository().logAction(
        title: 'School Event Created',
        description: '"${event.title}" scheduled for ${event.date.day}/${event.date.month}/${event.date.year}.',
        iconName: 'send',
        colorHex: 'FF3F51B5',
        userId: FirebaseAuth.instance.currentUser?.uid,
      );
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await firestore.collection('school_events').doc(eventId).delete();
  }
}
