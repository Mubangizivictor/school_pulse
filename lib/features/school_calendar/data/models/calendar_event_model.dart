import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/calendar_event.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/calendar_event_type.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/recurrence_rule.dart';

class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.schoolId,
    required super.title,
    required super.type,
    required super.startDate,
    required super.endDate,
    super.description,
    super.allDay,
    super.colorHex,
    super.recurrence,
    super.createdBy,
    required super.createdAt,
    super.archived,
  });

  factory CalendarEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEventModel(
      id: doc.id,
      schoolId: data['schoolId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: CalendarEventType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => CalendarEventType.event,
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      allDay: data['allDay'] as bool? ?? true,
      colorHex: data['colorHex'] as String? ?? '4CAF50',
      recurrence: _recurrenceFromMap(
        data['recurrence'] as Map<String, dynamic>?,
      ),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      archived: data['archived'] as bool? ?? false,
    );
  }

  static RecurrenceRule? _recurrenceFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return RecurrenceRule(
      frequency: RecurrenceFrequency.values.firstWhere(
        (f) => f.name == map['frequency'],
        orElse: () => RecurrenceFrequency.weekly,
      ),
      repeatsOn:
          (map['repeatsOn'] as List?)
              ?.map(
                (w) => Weekday.values.firstWhere(
                  (weekday) => weekday.name == w,
                  orElse: () => Weekday.monday,
                ),
              )
              .toList() ??
          const [],
      endType: RecurrenceEndType.values.firstWhere(
        (e) => e.name == map['endType'],
        orElse: () => RecurrenceEndType.never,
      ),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      occurrences: map['occurrences'] as int?,
    );
  }

  static Map<String, dynamic>? _recurrenceToMap(RecurrenceRule? rule) {
    if (rule == null) return null;
    return {
      'frequency': rule.frequency.name,
      'repeatsOn': rule.repeatsOn.map((w) => w.name).toList(),
      'endType': rule.endType.name,
      'endDate': rule.endDate != null
          ? Timestamp.fromDate(rule.endDate!)
          : null,
      'occurrences': rule.occurrences,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'title': title,
      'description': description,
      'type': type.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'allDay': allDay,
      'colorHex': colorHex,
      'recurrence': _recurrenceToMap(recurrence),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'archived': archived,
    };
  }

  factory CalendarEventModel.fromEntity(CalendarEvent event) {
    return CalendarEventModel(
      id: event.id,
      schoolId: event.schoolId,
      title: event.title,
      description: event.description,
      type: event.type,
      startDate: event.startDate,
      endDate: event.endDate,
      allDay: event.allDay,
      colorHex: event.colorHex,
      recurrence: event.recurrence,
      createdBy: event.createdBy,
      createdAt: event.createdAt,
      archived: event.archived,
    );
  }
}
