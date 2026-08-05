import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academic_year_model.dart';
import '../models/calendar_event_model.dart';

abstract class SchoolCalendarRemoteDataSource {
  Future<AcademicYearModel?> getCurrentAcademicYear(String schoolId);
  Future<List<CalendarEventModel>> getEvents(String schoolId);
  Future<void> upsertEvent(CalendarEventModel event);
  Future<void> deleteEvent(String schoolId, String eventId);
}

class SchoolCalendarRemoteDataSourceImpl
    implements SchoolCalendarRemoteDataSource {
  final FirebaseFirestore firestore;

  SchoolCalendarRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _academicYears(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection(
        'academic_years',
      );

  CollectionReference<Map<String, dynamic>> _events(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection(
        'calendar_events',
      );

  @override
  Future<AcademicYearModel?> getCurrentAcademicYear(String schoolId) async {
    final snapshot = await _academicYears(
      schoolId,
    ).where('isCurrent', isEqualTo: true).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return AcademicYearModel.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<List<CalendarEventModel>> getEvents(String schoolId) async {
    final snapshot = await _events(
      schoolId,
    ).where('archived', isEqualTo: false).orderBy('startDate').get();
    return snapshot.docs
        .map((doc) => CalendarEventModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> upsertEvent(CalendarEventModel event) async {
    final collection = _events(event.schoolId);
    if (event.id.isEmpty) {
      await collection.add(event.toFirestore());
    } else {
      await collection.doc(event.id).set(event.toFirestore());
    }
  }

  @override
  Future<void> deleteEvent(String schoolId, String eventId) async {
    await _events(schoolId).doc(eventId).update({'archived': true});
  }
}
