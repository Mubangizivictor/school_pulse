import 'package:cloud_firestore/cloud_firestore.dart';

enum SupportTicketStatus { open, inProgress, resolved }

enum SupportTicketPriority { low, medium, high }

SupportTicketStatus supportTicketStatusFromString(String value) {
  switch (value) {
    case 'inProgress':
      return SupportTicketStatus.inProgress;
    case 'resolved':
      return SupportTicketStatus.resolved;
    case 'open':
    default:
      return SupportTicketStatus.open;
  }
}

String supportTicketStatusToString(SupportTicketStatus status) {
  switch (status) {
    case SupportTicketStatus.inProgress:
      return 'inProgress';
    case SupportTicketStatus.resolved:
      return 'resolved';
    case SupportTicketStatus.open:
      return 'open';
  }
}

SupportTicketPriority supportTicketPriorityFromString(String value) {
  switch (value) {
    case 'high':
      return SupportTicketPriority.high;
    case 'low':
      return SupportTicketPriority.low;
    case 'medium':
    default:
      return SupportTicketPriority.medium;
  }
}

String supportTicketPriorityToString(SupportTicketPriority priority) {
  switch (priority) {
    case SupportTicketPriority.high:
      return 'high';
    case SupportTicketPriority.low:
      return 'low';
    case SupportTicketPriority.medium:
      return 'medium';
  }
}

/// A support ticket raised by the SaaS owner, stored in the
/// `super_admin_support_tickets` Firestore collection (naming follows the
/// existing `super_admin_notifications` / `super_admin_audit_logs`
/// owner-scoped convention).
class SupportTicket {
  final String id;
  final String ticketNumber;
  final String ownerId;
  final String subject;
  final String description;
  final SupportTicketPriority priority;
  final SupportTicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.ownerId,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];
    return SupportTicket(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String? ?? json['id'] as String,
      ownerId: json['ownerId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: supportTicketPriorityFromString(
        json['priority'] as String? ?? 'medium',
      ),
      status: supportTicketStatusFromString(
        json['status'] as String? ?? 'open',
      ),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),
      updatedAt: updatedAtRaw is Timestamp
          ? updatedAtRaw.toDate()
          : DateTime.now(),
    );
  }
}

enum SupportMessageSender { owner, agent }

SupportMessageSender supportMessageSenderFromString(String value) {
  return value == 'agent'
      ? SupportMessageSender.agent
      : SupportMessageSender.owner;
}

/// A single message inside a ticket's `messages` subcollection.
class SupportTicketMessage {
  final String id;
  final SupportMessageSender sender;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const SupportTicketMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory SupportTicketMessage.fromJson(String id, Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    return SupportTicketMessage(
      id: id,
      sender: supportMessageSenderFromString(
        json['sender'] as String? ?? 'owner',
      ),
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),
    );
  }
}
