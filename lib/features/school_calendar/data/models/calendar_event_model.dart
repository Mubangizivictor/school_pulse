import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
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
    super.category,
    super.location,
    super.organizer,
    super.audience,
    super.reminder,
    super.notes,
    super.attachments,
    super.recurrence,
    super.recurrenceGroupId,
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
      // `date` was used by an early seeder; retain it as a read-only migration
      // path so existing tenant records do not make the calendar fail to load.
      startDate: ((data['startDate'] ?? data['date']) as Timestamp).toDate(),
      endDate:
          ((data['endDate'] ?? data['startDate'] ?? data['date']) as Timestamp)
              .toDate(),
      allDay: data['allDay'] as bool? ?? true,
      colorHex: data['colorHex'] as String? ?? '4CAF50',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      organizer: data['organizer'] as String? ?? '',
      audience: NotificationAudience.fromMap(
        (data['audience'] is Map)
            ? Map<String, dynamic>.from(data['audience'] as Map)
            // Migration path: legacy records stored audience as a plain
            // display string (e.g. "All School"). Map the common values to
            // an equivalent typed audience so old events keep working.
            : _legacyAudienceFromLabel(data['audience'] as String?),
      ),
      reminder: data['reminder'] as String? ?? 'None',
      notes: data['notes'] as String? ?? '',
      attachments: (data['attachments'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                CalendarAttachment.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      recurrence: _recurrenceFromMap(
        data['recurrence'] as Map<String, dynamic>?,
      ),
      recurrenceGroupId: data['recurrenceGroupId'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      archived: data['archived'] as bool? ?? false,
    );
  }

  static Map<String, dynamic>? _legacyAudienceFromLabel(String? label) {
    switch (label) {
      case 'Students':
        return {'kind': 'student_parents'};
      case 'Staff':
        return {'kind': 'all_staff'};
      case 'Parents':
        return {'kind': 'all_parents'};
      case 'All School':
      default:
        return {'kind': 'school'};
    }
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
      'category': category,
      'location': location,
      'organizer': organizer,
      'audience': audience.toMap(),
      'reminder': reminder,
      'notes': notes,
      'attachments': attachments
          .map((attachment) => attachment.toMap())
          .toList(),
      'recurrence': _recurrenceToMap(recurrence),
      'recurrenceGroupId': recurrenceGroupId,
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
      category: event.category,
      location: event.location,
      organizer: event.organizer,
      audience: event.audience,
      reminder: event.reminder,
      notes: event.notes,
      attachments: event.attachments,
      recurrence: event.recurrence,
      recurrenceGroupId: event.recurrenceGroupId,
      createdBy: event.createdBy,
      createdAt: event.createdAt,
      archived: event.archived,
    );
  }
}
