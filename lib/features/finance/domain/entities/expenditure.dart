import 'package:equatable/equatable.dart';

enum ExpenditureStatus { pending, reviewed, approved, rejected, released }

class ExpenditureRequest extends Equatable {
  final String id;
  final String schoolId;
  final String requesterId;
  final String requesterName;
  final String description;
  final double amount;
  final String budgetCategoryId;
  final String? supplierId;
  final String? supplierName;
  final ExpenditureStatus status;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final List<ApprovalStep> approvalHistory;

  const ExpenditureRequest({
    required this.id,
    required this.schoolId,
    required this.requesterId,
    required this.requesterName,
    required this.description,
    required this.amount,
    required this.budgetCategoryId,
    this.supplierId,
    this.supplierName,
    required this.status,
    this.attachmentUrls = const [],
    required this.createdAt,
    this.approvalHistory = const [],
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    requesterId,
    requesterName,
    description,
    amount,
    budgetCategoryId,
    supplierId,
    supplierName,
    status,
    attachmentUrls,
    createdAt,
    approvalHistory,
  ];
}

class ApprovalStep extends Equatable {
  final String id;
  final String approverId;
  final String approverName;
  final String approverRole;
  final String status; // Approved, Rejected, Commented
  final String? comment;
  final DateTime updatedAt;

  const ApprovalStep({
    required this.id,
    required this.approverId,
    required this.approverName,
    required this.approverRole,
    required this.status,
    this.comment,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    approverId,
    approverName,
    approverRole,
    status,
    comment,
    updatedAt,
  ];
}
