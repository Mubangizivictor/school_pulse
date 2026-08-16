import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'calendar_event_type.dart';
import 'recurrence_rule.dart';

class CalendarEvent extends Equatable {
  final String id;
  final String schoolId;
  final String title;
  final String description;
  final CalendarEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool allDay;
  final String colorHex;
  final String category;
  final String location;
  final String organizer;
  final NotificationAudience audience;
  final String reminder;
  final String notes;
  final List<CalendarAttachment> attachments;
  final RecurrenceRule? recurrence;

  /// Shared by every document materialized from the same recurring event.
  /// Empty for a non-recurring event. Lets a scoped delete/edit ("this and
  /// following", "all occurrences") find its siblings without needing to
  /// re-parse the recurrence rule.
  final String recurrenceGroupId;

  final String createdBy;
  final DateTime createdAt;
  final bool archived;

  const CalendarEvent({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.description = '',
    this.allDay = true,
    this.colorHex = '4CAF50',
    this.category = '',
    this.location = '',
    this.organizer = '',
    this.audience = const NotificationAudience.school(),
    this.reminder = 'None',
    this.notes = '',
    this.attachments = const [],
    this.recurrence,
    this.recurrenceGroupId = '',
    this.createdBy = '',
    required this.createdAt,
    this.archived = false,
  });

  CalendarEvent copyWith({
    String? id,
    String? schoolId,
    String? title,
    String? description,
    CalendarEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? allDay,
    String? colorHex,
    String? category,
    String? location,
    String? organizer,
    NotificationAudience? audience,
    String? reminder,
    String? notes,
    List<CalendarAttachment>? attachments,
    RecurrenceRule? recurrence,
    bool clearRecurrence = false,
    String? recurrenceGroupId,
    String? createdBy,
    DateTime? createdAt,
    bool? archived,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      allDay: allDay ?? this.allDay,
      colorHex: colorHex ?? this.colorHex,
      category: category ?? this.category,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      audience: audience ?? this.audience,
      reminder: reminder ?? this.reminder,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    title,
    description,
    type,
    startDate,
    endDate,
    allDay,
    colorHex,
    category,
    location,
    organizer,
    audience,
    reminder,
    notes,
    attachments,
    recurrence,
    recurrenceGroupId,
    createdBy,
    createdAt,
    archived,
  ];
}

class CalendarAttachment extends Equatable {
  final String name;
  final String url;
  final int sizeBytes;

  const CalendarAttachment({
    required this.name,
    required this.url,
    this.sizeBytes = 0,
  });

  factory CalendarAttachment.fromMap(Map<String, dynamic> map) =>
      CalendarAttachment(
        name: map['name'] as String? ?? 'Attachment',
        url: map['url'] as String? ?? '',
        sizeBytes: map['sizeBytes'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'name': name,
    'url': url,
    'sizeBytes': sizeBytes,
  };

  @override
  List<Object?> get props => [name, url, sizeBytes];
}
