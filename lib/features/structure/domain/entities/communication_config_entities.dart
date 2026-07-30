import 'package:equatable/equatable.dart';

/// An announcement category (e.g. "Academic", "Sports", "Emergency").
class AnnouncementCategoryDef extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const AnnouncementCategoryDef({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  AnnouncementCategoryDef copyWith({String? id, String? name, bool? isActive}) {
    return AnnouncementCategoryDef(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}

/// A notification category (e.g. "Fee Reminder", "Homework").
class NotificationCategoryDef extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const NotificationCategoryDef({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  NotificationCategoryDef copyWith({String? id, String? name, bool? isActive}) {
    return NotificationCategoryDef(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}

/// A reusable message template for a channel (email/sms/push/message).
class MessageTemplateDef extends Equatable {
  final String id;
  final String name;
  final String channel;
  final String subject;
  final String body;
  final bool isActive;

  const MessageTemplateDef({
    required this.id,
    required this.name,
    this.channel = 'sms',
    this.subject = '',
    required this.body,
    this.isActive = true,
  });

  MessageTemplateDef copyWith({
    String? id,
    String? name,
    String? channel,
    String? subject,
    String? body,
    bool? isActive,
  }) {
    return MessageTemplateDef(
      id: id ?? this.id,
      name: name ?? this.name,
      channel: channel ?? this.channel,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, channel, subject, body, isActive];
}
