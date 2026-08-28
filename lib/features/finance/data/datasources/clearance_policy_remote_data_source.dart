import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';

/// Reads/writes the school's financial-clearance policy exclusively through
/// the trusted callables `getReportCardClearancePolicy` /
/// `saveReportCardClearancePolicy`. A direct Firestore write is deliberately
/// NOT offered: the save callable also re-materialises every finalized
/// report's access state and writes the audit entry with an effective
/// timestamp - a plain Firestore write would leave stale
/// `financialAccessStatus` values behind and no audit trail.
class ClearancePolicyRemoteDataSource {
  final FirebaseFunctions functions;
  ClearancePolicyRemoteDataSource({required this.functions});

  Future<({FinancialClearancePolicy policy, ClearancePolicyMeta meta})>
  getPolicy() async {
    final res = await functions
        .httpsCallable('getReportCardClearancePolicy')
        .call(<String, dynamic>{});
    final data = Map<String, dynamic>.from(res.data as Map);
    return (
      policy: FinancialClearancePolicy.fromMap(
        (data['policy'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      meta: ClearancePolicyMeta.fromMap(
        (data['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Future<({FinancialClearancePolicy policy, int reMaterialisedPeriods})>
  savePolicy(FinancialClearancePolicy policy) async {
    final res = await functions
        .httpsCallable('saveReportCardClearancePolicy')
        .call(<String, dynamic>{'financialClearance': policy.toMap()});
    final data = Map<String, dynamic>.from(res.data as Map);
    return (
      policy: FinancialClearancePolicy.fromMap(
        (data['policy'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      reMaterialisedPeriods:
          (data['reMaterialisedPeriods'] as num?)?.toInt() ?? 0,
    );
  }
}
