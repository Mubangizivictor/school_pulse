import 'package:equatable/equatable.dart';

enum MeetingType { board, management, department }

extension MeetingTypeWire on MeetingType {
  String get wire => name;
  static MeetingType parse(Object? value) => MeetingType.values.firstWhere(
    (v) => v.name == value,
    orElse: () => MeetingType.management,
  );
}

class MeetingAction extends Equatable {
  final String description, assignee;
  final DateTime deadline;
  final bool completed;

  const MeetingAction({
    required this.description,
    required this.assignee,
    required this.deadline,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
    'description': description,
    'assignee': assignee,
    'deadline': deadline.toIso8601String(),
    'completed': completed,
  };

  factory MeetingAction.fromMap(Map<String, dynamic> map) {
    DateTime date(Object? v) {
      if (v == null) return DateTime.now();
      try {
        final converted = (v as dynamic).toDate();
        if (converted is DateTime) return converted;
      } catch (_) {}
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return MeetingAction(
      description: map['description'] as String? ?? '',
      assignee: map['assignee'] as String? ?? '',
      deadline: date(map['deadline']),
      completed: map['completed'] == true,
    );
  }

  MeetingAction copyWith({bool? completed}) => MeetingAction(
    description: description,
    assignee: assignee,
    deadline: deadline,
    completed: completed ?? this.completed,
  );

  @override
  List<Object?> get props => [description, assignee, deadline, completed];
}

class LeadershipMeeting extends Equatable {
  final String meetingId, institutionId, title, agenda;
  final MeetingType type;
  final List<String> participants;
  final List<String> decisions;
  final List<MeetingAction> actions;
  final DateTime scheduledAt, createdAt;
  final String createdBy;

  const LeadershipMeeting({
    required this.meetingId,
    required this.institutionId,
    required this.title,
    required this.agenda,
    required this.type,
    required this.participants,
    required this.decisions,
    required this.actions,
    required this.scheduledAt,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
    'institutionId': institutionId,
    'title': title,
    'agenda': agenda,
    'type': type.wire,
    'participants': participants,
    'decisions': decisions,
    'actions': actions.map((a) => a.toMap()).toList(),
    'scheduledAt': scheduledAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory LeadershipMeeting.fromMap(Map<String, dynamic> map) {
    DateTime date(Object? v) {
      if (v == null) return DateTime.now();
      try {
        final converted = (v as dynamic).toDate();
        if (converted is DateTime) return converted;
      } catch (_) {}
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return LeadershipMeeting(
      meetingId: map['meetingId'] as String? ?? '',
      institutionId: map['institutionId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      agenda: map['agenda'] as String? ?? '',
      type: MeetingTypeWire.parse(map['type']),
      participants: List<String>.from(map['participants'] ?? const []),
      decisions: List<String>.from(map['decisions'] ?? const []),
      actions: ((map['actions'] as List?) ?? const [])
          .map((a) => MeetingAction.fromMap(Map<String, dynamic>.from(a as Map)))
          .toList(),
      scheduledAt: date(map['scheduledAt']),
      createdAt: date(map['createdAt']),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
    meetingId,
    institutionId,
    title,
    type,
    scheduledAt,
    actions,
  ];
}
