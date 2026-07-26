import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school_event_model.dart';

abstract class CalendarRemoteDataSource {
  Future<List<SchoolEventModel>> getUpcomingEvents();
  Future<void> addEvent(SchoolEventModel event);
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final FirebaseFirestore firestore;

  CalendarRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<SchoolEventModel>> getUpcomingEvents() async {
    final snapshot = await firestore
        .collection('school_events')
        .orderBy('date', descending: false)
        .get();
    return snapshot.docs.map((doc) => SchoolEventModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addEvent(SchoolEventModel event) async {
    await firestore.collection('school_events').add(event.toFirestore());
  }
}
