import '../../../finance/domain/repositories/finance_repository.dart';
import '../entities/report_release_policy.dart';

/// Enforces the school's configured report release policy, integrating
/// read-only with the Finance module (never modifies Finance's own logic).
class ReportPolicyService {
  final FinanceRepository financeRepository;

  ReportPolicyService({required this.financeRepository});

  Future<bool> canDownloadReport({
    required String studentId,
    required ReportReleasePolicy policy,
  }) async {
    switch (policy.option) {
      case ReleaseOption.everyoneImmediate:
        return true;
      case ReleaseOption.onlyFullyClearedFees:
        return await _isFeesCleared(studentId);
      case ReleaseOption.viewEveryoneDownloadCleared:
        return await _isFeesCleared(studentId);
      case ReleaseOption.afterSpecificDate:
        if (policy.releaseDate == null) return true;
        return DateTime.now().isAfter(policy.releaseDate!);
      case ReleaseOption.manualOverrideOnly:
        return false; // Requires an explicit Bursar/Headteacher override
    }
  }

  Future<bool> canViewReport({
    required String studentId,
    required ReportReleasePolicy policy,
  }) async {
    if (policy.option == ReleaseOption.viewEveryoneDownloadCleared) return true;
    if (policy.option == ReleaseOption.everyoneImmediate) return true;

    // For other options, viewing is gated the same way as downloading.
    return await canDownloadReport(studentId: studentId, policy: policy);
  }

  Future<bool> _isFeesCleared(String studentId) async {
    final result = await financeRepository.getFees(studentId);
    return result.fold(
      (failure) => false,
      (fees) => fees.every((fee) => fee.status.toString().split('.').last == 'paid'),
    );
  }
}
