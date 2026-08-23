import 'package:equatable/equatable.dart';

/// Which budget line pays a staff member's salary. Uganda-school-specific
/// terminology: government-aided schools split staff between the
/// government payroll and school-funded (PTA) positions.
enum PayrollFundingSource {
  government,
  pta,
  other;

  static PayrollFundingSource fromId(String? id) {
    for (final v in PayrollFundingSource.values) {
      if (v.name == id) return v;
    }
    return PayrollFundingSource.other;
  }
}

class PayrollRecord extends Equatable {
  final String id;
  final String schoolId;
  final String staffId;
  final String staffName;
  final String month; // e.g., "October 2023"
  final double baseSalary;
  final double allowances;
  final double bonuses;
  final double deductions;
  final double nssfEmployee; // 5%
  final double nssfEmployer; // 10%
  final double paye;
  final double netPay;
  final DateTime createdAt;
  final PayrollFundingSource fundingSource;

  const PayrollRecord({
    required this.id,
    required this.schoolId,
    required this.staffId,
    required this.staffName,
    required this.month,
    required this.baseSalary,
    required this.allowances,
    required this.bonuses,
    required this.deductions,
    required this.nssfEmployee,
    required this.nssfEmployer,
    required this.paye,
    required this.netPay,
    required this.createdAt,
    this.fundingSource = PayrollFundingSource.government,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    staffId,
    staffName,
    month,
    baseSalary,
    allowances,
    bonuses,
    deductions,
    nssfEmployee,
    nssfEmployer,
    paye,
    netPay,
    createdAt,
    fundingSource,
  ];
}
