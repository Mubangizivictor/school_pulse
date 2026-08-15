import 'package:school_pulse/features/hr/domain/entities/payroll_record.dart';

abstract class HrRepository {
  Future<List<PayrollRecord>> getPayrollRecords(String schoolId);
  Future<void> generatePayroll(PayrollRecord record);
}
