import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expenditure.dart';

class ExpenditureRequestModel extends ExpenditureRequest {
  const ExpenditureRequestModel({
    required super.id,
    required super.schoolId,
    required super.requesterId,
    required super.requesterName,
    required super.description,
    required super.amount,
    required super.budgetCategoryId,
    super.supplierId,
    super.supplierName,
    required super.status,
    super.attachmentUrls = const [],
    required super.createdAt,
    super.approvalHistory = const [],
  });

  factory ExpenditureRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenditureRequestModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      budgetCategoryId: data['budgetCategoryId'] ?? '',
      supplierId: data['supplierId'],
      supplierName: data['supplierName'],
      status: ExpenditureStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => ExpenditureStatus.pending,
      ),
      attachmentUrls: List<String>.from(data['attachmentUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvalHistory: (data['approvalHistory'] as List? ?? [])
          .map((item) => ApprovalStepModel.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'description': description,
      'amount': amount,
      'budgetCategoryId': budgetCategoryId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.name,
      'attachmentUrls': attachmentUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvalHistory': approvalHistory
          .map((item) => (item as ApprovalStepModel).toMap())
          .toList(),
    };
  }
}

class ApprovalStepModel extends ApprovalStep {
  const ApprovalStepModel({
    required super.id,
    required super.approverId,
    required super.approverName,
    required super.approverRole,
    required super.status,
    super.comment,
    required super.updatedAt,
  });

  factory ApprovalStepModel.fromMap(Map<String, dynamic> map) {
    return ApprovalStepModel(
      id: map['id'] ?? '',
      approverId: map['approverId'] ?? '',
      approverName: map['approverName'] ?? '',
      approverRole: map['approverRole'] ?? '',
      status: map['status'] ?? '',
      comment: map['comment'],
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'approverId': approverId,
      'approverName': approverName,
      'approverRole': approverRole,
      'status': status,
      'comment': comment,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
