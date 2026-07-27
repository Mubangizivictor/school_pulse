import 'package:cloud_firestore/cloud_firestore.dart';
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
      print('Error cleaning up old events: $e');
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
    if (event.id.isNotEmpty) {
      await firestore.collection('school_events').doc(event.id).set(event.toFirestore());
    } else {
      await firestore.collection('school_events').add(event.toFirestore());
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await firestore.collection('school_events').doc(eventId).delete();
  }
}
