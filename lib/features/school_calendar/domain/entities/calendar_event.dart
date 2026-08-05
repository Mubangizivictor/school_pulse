import 'package:equatable/equatable.dart';
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
  final RecurrenceRule? recurrence;
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
    this.recurrence,
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
    RecurrenceRule? recurrence,
    bool clearRecurrence = false,
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
      recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
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
    recurrence,
    createdBy,
    createdAt,
    archived,
  ];
}
