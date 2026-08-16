import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/approvals/domain/entities/approval_models.dart';
import 'package:school_pulse/features/approvals/domain/services/approval_workflow_engine.dart';

void main() {
  final first = ApprovalStage(
    stageId: 'bursar',
    order: 1,
    name: 'Bursar',
    requiredPermission: 'approvals.approve',
  );
  final last = ApprovalStage(
    stageId: 'head',
    order: 2,
    name: 'Headteacher',
    requiredPermission: 'approvals.approve',
    minimumApprovals: 2,
    parallel: true,
  );
  final policy = ApprovalPolicy(
    approvalPolicyId: 'p',
    institutionId: 'school',
    name: 'Finance',
    moduleKey: 'finance',
    requestType: 'expenditure',
    stages: [first, last],
  );
  ApprovalRequest request(String requester) => ApprovalRequest(
    approvalRequestId: 'r',
    institutionId: 'school',
    moduleKey: 'finance',
    requestType: 'expenditure',
    sourceRecordType: 'expenditure',
    sourceRecordId: 'source',
    sourceRoute: '/finance',
    title: 'Purchase',
    summary: '',
    requestedBy: requester,
    requesterRole: 'bursar',
    currentStage: 'bursar',
    currentStatus: ApprovalStatus.pending,
    priority: ApprovalPriority.normal,
    sensitivity: ApprovalSensitivity.normal,
    approvalPolicyId: 'p',
    sourceRecordVersion: '1',
    correlationId: 'c',
    createdAt: DateTime(2026),
    submittedAt: DateTime(2026),
  );
  const engine = ApprovalWorkflowEngine();
  test('denies self approval unless the policy explicitly permits it', () {
    expect(
      engine.canAct(
        request: request('u1'),
        policy: policy,
        actorId: 'u1',
        permissions: {'approvals.approve'},
        activeAssignment: true,
      ),
      isFalse,
    );
    final permissive = ApprovalPolicy(
      approvalPolicyId: 'p',
      institutionId: 'school',
      name: 'Finance',
      moduleKey: 'finance',
      requestType: 'expenditure',
      stages: [first],
      selfApprovalAllowed: true,
    );
    expect(
      engine.canAct(
        request: request('u1'),
        policy: permissive,
        actorId: 'u1',
        permissions: {'approvals.approve'},
        activeAssignment: true,
      ),
      isTrue,
    );
  });
  test('requires current assignment and source version', () {
    expect(
      engine.canAct(
        request: request('u2'),
        policy: policy,
        actorId: 'u1',
        permissions: {'approvals.approve'},
        activeAssignment: false,
      ),
      isFalse,
    );
    expect(
      engine.canAct(
        request: request('u2'),
        policy: policy,
        actorId: 'u1',
        permissions: {'approvals.approve'},
        activeAssignment: true,
        isSourceCurrent: false,
      ),
      isFalse,
    );
  });
  test('sequential and parallel stages advance only at threshold', () {
    expect(
      engine.nextStatus(policy: policy, stage: first, approvalsAtStage: 1),
      ApprovalStatus.pending,
    );
    expect(
      engine.nextStatus(policy: policy, stage: last, approvalsAtStage: 1),
      ApprovalStatus.partiallyApproved,
    );
    expect(
      engine.nextStatus(policy: policy, stage: last, approvalsAtStage: 2),
      ApprovalStatus.approved,
    );
  });
}
