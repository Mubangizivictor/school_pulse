import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/approvals/domain/entities/approval_models.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart';

ApprovalRequest _req({
  String id = 'r1',
  String moduleKey = 'finance',
  String requestType = 'payment_voucher',
  ApprovalStatus status = ApprovalStatus.pending,
  ApprovalPriority priority = ApprovalPriority.normal,
  double? amount = 500000,
  List<String> approvers = const ['u-approver'],
  DateTime? dueAt,
  String requestedBy = 'u-requester',
}) {
  return ApprovalRequest(
    approvalRequestId: id,
    institutionId: 's1',
    moduleKey: moduleKey,
    requestType: requestType,
    sourceRecordType: 'expenditure',
    sourceRecordId: 'e1',
    sourceRoute: '',
    title: 'Supplier payment',
    summary: '',
    requestedBy: requestedBy,
    requesterRole: 'bursar',
    currentStage: 'stage-1',
    approvalPolicyId: 'p1',
    sourceRecordVersion: '1',
    correlationId: 'c1',
    currentStatus: status,
    priority: priority,
    sensitivity: ApprovalSensitivity.normal,
    amount: amount,
    attachments: const [],
    requiredApprovers: approvers,
    createdAt: DateTime(2026, 5, 1),
    submittedAt: DateTime(2026, 5, 1),
    dueAt: dueAt,
    version: 1,
  );
}

void main() {
  group('isFinanceApproval', () {
    test('matches finance moduleKey and finance-flavoured request types', () {
      expect(isFinanceApproval(_req(moduleKey: 'finance')), isTrue);
      expect(
        isFinanceApproval(_req(moduleKey: 'hr', requestType: 'expenditure')),
        isTrue,
      );
      expect(
        isFinanceApproval(_req(moduleKey: 'hr', requestType: 'refund_request')),
        isTrue,
      );
      expect(
        isFinanceApproval(_req(moduleKey: 'hr', requestType: 'leave_request')),
        isFalse,
      );
    });
  });

  group('approvalIsActionable', () {
    test('true only when open, a current-stage approver, and not overdue', () {
      expect(approvalIsActionable(_req(), 'u-approver'), isTrue);
      // not an approver
      expect(approvalIsActionable(_req(), 'someone-else'), isFalse);
      // already resolved
      expect(
        approvalIsActionable(
          _req(status: ApprovalStatus.approved),
          'u-approver',
        ),
        isFalse,
      );
      // past its due date
      expect(
        approvalIsActionable(_req(dueAt: DateTime(2020, 1, 1)), 'u-approver'),
        isFalse,
      );
    });
  });

  group('approvalIsHighRisk', () {
    test('large spend, high priority, or overdue', () {
      expect(approvalIsHighRisk(_req(amount: 5000000)), isTrue);
      expect(
        approvalIsHighRisk(_req(priority: ApprovalPriority.urgent)),
        isTrue,
      );
      expect(approvalIsHighRisk(_req(dueAt: DateTime(2020, 1, 1))), isTrue);
      expect(approvalIsHighRisk(_req(amount: 100000)), isFalse);
    });
  });

  group('approvalTypeLabel', () {
    test('humanises the request type', () {
      expect(approvalTypeLabel('payment_voucher'), 'Payment Voucher');
      expect(approvalTypeLabel('refund_request'), 'Refund Request');
    });
  });

  test('approvalIsOpen covers the in-flight statuses', () {
    for (final s in [
      ApprovalStatus.pending,
      ApprovalStatus.partiallyApproved,
      ApprovalStatus.inReview,
      ApprovalStatus.awaitingInformation,
    ]) {
      expect(approvalIsOpen(_req(status: s)), isTrue, reason: '$s');
    }
    for (final s in [
      ApprovalStatus.approved,
      ApprovalStatus.rejected,
      ApprovalStatus.cancelled,
      ApprovalStatus.expired,
    ]) {
      expect(approvalIsOpen(_req(status: s)), isFalse, reason: '$s');
    }
  });
}
