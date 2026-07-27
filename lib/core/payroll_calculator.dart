class PayrollCalculator {
  /// Calculates Uganda PAYE based on the monthly income.
  /// Rates as of 2023:
  /// Not exceeding UGX 235,000: Nil
  /// 235,001 - 335,000: 10% of amount exceeding 235,000
  /// 335,001 - 410,000: UGX 10,000 + 20% of amount exceeding 335,000
  /// Exceeding 410,000: UGX 25,000 + 30% of amount exceeding 410,000
  /// Additional 10% for income exceeding 10,000,000
  static double calculatePAYE(double grossTaxableIncome) {
    double paye = 0;
    if (grossTaxableIncome <= 235000) {
      paye = 0;
    } else if (grossTaxableIncome <= 335000) {
      paye = (grossTaxableIncome - 235000) * 0.10;
    } else if (grossTaxableIncome <= 410000) {
      paye = 10000 + (grossTaxableIncome - 335000) * 0.20;
    } else {
      paye = 25000 + (grossTaxableIncome - 410000) * 0.30;
    }

    if (grossTaxableIncome > 10000000) {
      paye += (grossTaxableIncome - 10000000) * 0.10;
    }

    return paye;
  }

  static double calculateNSSFEmployee(double grossSalary) {
    return grossSalary * 0.05;
  }

  static double calculateNSSFEmployer(double grossSalary) {
    return grossSalary * 0.10;
  }
}
