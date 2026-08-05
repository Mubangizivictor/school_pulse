class PayrollRecord {
  final String id;
  final String staffId;
  final String staffName;
  final double basicSalary;
  final double allowances;
  final double paye;
  final double nssf;
  final double otherDeductions;
  final double netSalary;
  final DateTime date;
  final String status; // 'Draft', 'Processed', 'Paid'

  const PayrollRecord({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.basicSalary,
    required this.allowances,
    required this.paye,
    required this.nssf,
    required this.otherDeductions,
    required this.netSalary,
    required this.date,
    required this.status,
  });

  factory PayrollRecord.calculate({
    required String id,
    required String staffId,
    required String staffName,
    required double basicSalary,
    required double allowances,
    required double otherDeductions,
    required DateTime date,
  }) {
    // Basic PAYE calculation for Uganda (simplified for demo)
    // Thresholds: 235k, 335k, 410k, 10M
    double taxableIncome = basicSalary + allowances;
    double paye = 0;
    if (taxableIncome > 10000000) {
      paye =
          0.3 * (taxableIncome - 410000) +
          25000 +
          0.1 * (taxableIncome - 10000000);
    } else if (taxableIncome > 410000) {
      paye = 0.3 * (taxableIncome - 410000) + 25000;
    } else if (taxableIncome > 335000) {
      paye = 0.2 * (taxableIncome - 335000) + 10000;
    } else if (taxableIncome > 235000) {
      paye = 0.1 * (taxableIncome - 235000);
    }

    // NSSF is usually 5% from employee, 10% from employer. We track employee 5% here.
    double nssf = taxableIncome * 0.05;

    double netSalary = taxableIncome - paye - nssf - otherDeductions;

    return PayrollRecord(
      id: id,
      staffId: staffId,
      staffName: staffName,
      basicSalary: basicSalary,
      allowances: allowances,
      paye: paye,
      nssf: nssf,
      otherDeductions: otherDeductions,
      netSalary: netSalary,
      date: date,
      status: 'Draft',
    );
  }
}
