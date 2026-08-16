import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/services/recurrence_expander.dart';
import '../models/calendar_event_model.dart';

abstract class SchoolCalendarRemoteDataSource {
  Future<List<CalendarEventModel>> getEvents(String schoolId);

  /// Returns the saved document's id. For a new recurring event this
  /// materializes one document per occurrence (all sharing a freshly
  /// generated `recurrenceGroupId`) in a single batch, and returns the
  /// *first* occurrence's id - the id callers use afterwards (e.g. to
  /// upload attachments) always resolves to a real, existing document.
  /// Editing an existing document (non-empty `event.id`) always targets
  /// that single document, regardless of whether it carries a recurrence
  /// rule - scope-based edits are not supported, only scope-based deletes.
  Future<String> upsertEvent(CalendarEventModel event);

  /// Deletes (archives) one occurrence, or a scoped set of sibling
  /// occurrences sharing the same `recurrenceGroupId`, depending on
  /// [scope]. Deleting a non-recurring event (empty `recurrenceGroupId`)
  /// always behaves as a single-document delete regardless of [scope].
  Future<void> deleteEvent(
    String schoolId,
    String eventId, {
    RecurrenceEditScope scope = RecurrenceEditScope.allOccurrences,
  });
}

class SchoolCalendarRemoteDataSourceImpl
    implements SchoolCalendarRemoteDataSource {
  final FirebaseFirestore firestore;

  SchoolCalendarRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _events(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('calendar_events');

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
  Future<String> upsertEvent(CalendarEventModel event) async {
    final collection = _events(event.schoolId);

    // Editing an existing document always targets just that document -
    // scope only applies to delete, matching the Event Details screen's
    // "this occurrence only" default for edits.
    if (event.id.isNotEmpty) {
      await collection.doc(event.id).set(event.toFirestore());
      return event.id;
    }

    final rule = event.recurrence;
    if (rule == null) {
      final doc = await collection.add(event.toFirestore());
      return doc.id;
    }

    final dates = expandRecurrenceDates(start: event.startDate, rule: rule);
    final groupId = const Uuid().v4();
    final duration = event.endDate.difference(event.startDate);
    final batch = firestore.batch();
    final docRefs = <DocumentReference<Map<String, dynamic>>>[];
    for (final date in dates) {
      final occurrence = CalendarEventModel.fromEntity(
        event.copyWith(
          startDate: date,
          endDate: date.add(duration),
          recurrenceGroupId: groupId,
        ),
      );
      final ref = collection.doc();
      docRefs.add(ref);
      batch.set(ref, occurrence.toFirestore());
    }
    await batch.commit();
    return docRefs.first.id;
  }

  @override
  Future<void> deleteEvent(
    String schoolId,
    String eventId, {
    RecurrenceEditScope scope = RecurrenceEditScope.allOccurrences,
  }) async {
    final collection = _events(schoolId);
    if (scope == RecurrenceEditScope.thisOccurrence) {
      await collection.doc(eventId).update({'archived': true});
      return;
    }

    final doc = await collection.doc(eventId).get();
    final groupId = doc.data()?['recurrenceGroupId'] as String? ?? '';
    if (groupId.isEmpty) {
      // Not part of a recurring series - scope is meaningless, fall back to
      // a plain single-document delete.
      await collection.doc(eventId).update({'archived': true});
      return;
    }

    Query<Map<String, dynamic>> query = collection.where(
      'recurrenceGroupId',
      isEqualTo: groupId,
    );
    if (scope == RecurrenceEditScope.thisAndFuture) {
      final startDate = doc.data()?['startDate'] as Timestamp?;
      if (startDate != null) {
        query = query.where('startDate', isGreaterThanOrEqualTo: startDate);
      }
    }

    final siblings = await query.get();
    final batch = firestore.batch();
    for (final siblingDoc in siblings.docs) {
      batch.update(siblingDoc.reference, {'archived': true});
    }
    await batch.commit();
  }
}
