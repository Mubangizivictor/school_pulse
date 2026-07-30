import 'package:equatable/equatable.dart';

enum SchoolEventType {
  general,
  staffMeeting,
  parentMeeting,
  exam,
  holiday,
  sportsEvent,
  trip,
  deadline,
  assembly,
  other,
}

/// Broadcast group labels an event can be aimed at - matches the topic
/// names BroadcastSmsScreen and NotificationGroups already use, so picking
/// "Parents" here reaches the same devices a manual broadcast would.
const List<String> defaultEventTargetGroups = ['Parents', 'All Staff'];

class SchoolEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String createdBy;
  final List<String> targetGroups;
  final SchoolEventType type;

  const SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdBy,
    this.targetGroups = defaultEventTargetGroups,
    this.type = SchoolEventType.general,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        createdBy,
        targetGroups,
        type,
      ];
}
