import 'package:equatable/equatable.dart';

enum ApprovalStatus { pending, approved, rejected, clarificationRequested }

class DirectorApproval extends Equatable {
  final String id;
  final String requesterName;
  final String department;
  final String title;
  final String description;
  final double amount;
  final DateTime dateRequested;
  final ApprovalStatus status;
  final List<String> attachments;
  final List<ApprovalStep> timeline;

  const DirectorApproval({
    required this.id,
    required this.requesterName,
    required this.department,
    required this.title,
    required this.description,
    required this.amount,
    required this.dateRequested,
    required this.status,
    required this.attachments,
    required this.timeline,
  });

  @override
  List<Object?> get props => [
        id,
        requesterName,
        department,
        title,
        description,
        amount,
        dateRequested,
        status,
        attachments,
        timeline,
      ];
}

class ApprovalStep extends Equatable {
  final String role;
  final String action;
  final DateTime timestamp;
  final String? comment;

  const ApprovalStep({
    required this.role,
    required this.action,
    required this.timestamp,
    this.comment,
  });

  @override
  List<Object?> get props => [role, action, timestamp, comment];
}
