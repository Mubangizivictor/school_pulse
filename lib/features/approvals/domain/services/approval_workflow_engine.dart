import '../entities/approval_models.dart';

class ApprovalWorkflowEngine {
  const ApprovalWorkflowEngine();
  bool canAct({
    required ApprovalRequest request,
    required ApprovalPolicy policy,
    required String actorId,
    required Set<String> permissions,
    required bool activeAssignment,
    bool hasValidDelegation = false,
    bool isSourceCurrent = true,
  }) =>
      activeAssignment &&
      isSourceCurrent &&
      request.currentStatus == ApprovalStatus.pending &&
      (policy.selfApprovalAllowed || request.requestedBy != actorId) &&
      (permissions.contains('approvals.approve') || hasValidDelegation);

  ApprovalStatus nextStatus({
    required ApprovalPolicy policy,
    required ApprovalStage stage,
    required int approvalsAtStage,
  }) {
    if (approvalsAtStage < stage.minimumApprovals) {
      return ApprovalStatus.partiallyApproved;
    }
    if (stage.order <
        policy.stages.map((s) => s.order).fold(0, (a, b) => a > b ? a : b)) {
      return ApprovalStatus.pending;
    }
    return ApprovalStatus.approved;
  }
}
