import 'package:school_pulse/features/hr/data/datasources/hr_remote_data_source.dart';
import 'package:school_pulse/features/hr/domain/entities/payroll_record.dart';
import 'package:school_pulse/features/hr/domain/repositories/hr_repository.dart';

class HrRepositoryImpl implements HrRepository {
  final HrRemoteDataSource remoteDataSource;

  HrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PayrollRecord>> getPayrollRecords(String schoolId) async {
    return await remoteDataSource.getPayrollRecords(schoolId);
  }

  @override
  Future<void> generatePayroll(PayrollRecord record) async {
    return await remoteDataSource.generatePayroll(record);
  }
}
