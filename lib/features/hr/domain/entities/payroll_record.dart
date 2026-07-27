import 'package:equatable/equatable.dart';

class PayrollRecord extends Equatable {
  final String id;
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

  const PayrollRecord({
    required this.id,
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
  });

  @override
  List<Object?> get props => [
        id,
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
      ];
}
