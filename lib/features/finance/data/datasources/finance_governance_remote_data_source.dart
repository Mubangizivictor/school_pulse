import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/budget.dart';
import '../../domain/entities/expenditure.dart';

/// Callable-only writes for finance governance (audit area 2).
///
/// Raising an expenditure requisition, deciding one (approve/reject/return),
/// and saving a school budget line all go through
/// `functions/finance_governance.js` — never a direct Firestore write — so
/// validation, tenant/role checks, the requester-can't-self-approve rule,
/// idempotency and audit-event creation are enforced server-side.
class FinanceGovernanceRemoteDataSource {
  final FirebaseFunctions functions;

  FinanceGovernanceRemoteDataSource({required this.functions});

  /// Create or amend a `pending` requisition. [clientRequestId] makes the
  /// call idempotent across retries — pass a value that is stable for one
  /// user submit attempt (e.g. a v4 UUID minted when the form opens).
  Future<String> submitExpenditure(
    ExpenditureRequest request, {
    String? clientRequestId,
  }) async {
    final res = await functions
        .httpsCallable('submitExpenditure')
        .call<Map<String, dynamic>>({
          'schoolId': request.schoolId,
          if (request.id.isNotEmpty) 'expenditureId': request.id,
          'description': request.description,
          'budgetCategoryId': request.budgetCategoryId,
          'amount': request.amount.round(),
          if (request.supplierId != null) 'supplierId': request.supplierId,
          if (request.supplierName != null)
            'supplierName': request.supplierName,
          'attachmentUrls': request.attachmentUrls,
          'clientRequestId': ?clientRequestId,
        });
    return (res.data['expenditureId'] ?? '').toString();
  }

  /// [decision] is one of `approve`, `reject`, `return`. A comment is
  /// required for reject/return.
  Future<String> decideExpenditure({
    required String schoolId,
    required String expenditureId,
    required String decision,
    String? comment,
  }) async {
    final res = await functions
        .httpsCallable('decideExpenditure')
        .call<Map<String, dynamic>>({
          'schoolId': schoolId,
          'expenditureId': expenditureId,
          'decision': decision,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        });
    return (res.data['status'] ?? '').toString();
  }

  /// Upsert a budget line. `spentAmount` is never sent — the server keeps
  /// actuals authoritative.
  Future<String> saveSchoolBudget(
    Budget budget, {
    String? clientRequestId,
  }) async {
    final res = await functions
        .httpsCallable('saveSchoolBudget')
        .call<Map<String, dynamic>>({
          'schoolId': budget.schoolId,
          if (budget.id.isNotEmpty) 'budgetId': budget.id,
          'name': budget.name,
          'academicYear': budget.academicYear,
          'term': budget.term,
          'allocatedAmount': budget.allocatedAmount.round(),
          if (budget.description != null) 'description': budget.description,
          'clientRequestId': ?clientRequestId,
        });
    return (res.data['budgetId'] ?? '').toString();
  }

  /// Map the UI's [ExpenditureStatus] decision to the callable verb.
  static String decisionFor(ExpenditureStatus status) {
    switch (status) {
      case ExpenditureStatus.approved:
        return 'approve';
      case ExpenditureStatus.rejected:
        return 'reject';
      case ExpenditureStatus.pending:
        return 'return';
      case ExpenditureStatus.reviewed:
      case ExpenditureStatus.released:
        return 'approve';
    }
  }
}
