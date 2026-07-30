import 'package:equatable/equatable.dart';

abstract class DirectorEvent extends Equatable {
  const DirectorEvent();

  @override
  List<Object?> get props => [];
}

class DirectorDashboardRequested extends DirectorEvent {}

class DirectorApprovalsRequested extends DirectorEvent {}

class DirectorApprovalActionRequested extends DirectorEvent {
  final String approvalId;
  final String action; // 'approve', 'reject', 'clarify'
  final String? comment;

  const DirectorApprovalActionRequested({
    required this.approvalId,
    required this.action,
    this.comment,
  });

  @override
  List<Object?> get props => [approvalId, action, comment];
}
