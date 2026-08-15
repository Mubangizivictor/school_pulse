import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/hr/domain/entities/payroll_record.dart';

abstract class HrRemoteDataSource {
  Future<List<PayrollRecord>> getPayrollRecords(String schoolId);
  Future<void> generatePayroll(PayrollRecord record);
}

class HrRemoteDataSourceImpl implements HrRemoteDataSource {
  final FirebaseFirestore firestore;

  HrRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PayrollRecord>> getPayrollRecords(String schoolId) async {
    final snapshot = await firestore
        .collection('payroll')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PayrollRecord(
        id: doc.id,
        schoolId: data['schoolId'] ?? '',
        staffId: data['staffId'] ?? '',
        staffName: data['staffName'] ?? '',
        month: data['month'] ?? '',
        baseSalary: (data['baseSalary'] ?? 0).toDouble(),
        allowances: (data['allowances'] ?? 0).toDouble(),
        bonuses: (data['bonuses'] ?? 0).toDouble(),
        deductions: (data['deductions'] ?? 0).toDouble(),
        nssfEmployee: (data['nssfEmployee'] ?? 0).toDouble(),
        nssfEmployer: (data['nssfEmployer'] ?? 0).toDouble(),
        paye: (data['paye'] ?? 0).toDouble(),
        netPay: (data['netPay'] ?? 0).toDouble(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> generatePayroll(PayrollRecord record) async {
    await firestore.collection('payroll').doc(record.id).set({
      'schoolId': record.schoolId,
      'staffId': record.staffId,
      'staffName': record.staffName,
      'month': record.month,
      'baseSalary': record.baseSalary,
      'allowances': record.allowances,
      'bonuses': record.bonuses,
      'deductions': record.deductions,
      'nssfEmployee': record.nssfEmployee,
      'nssfEmployer': record.nssfEmployer,
      'paye': record.paye,
      'netPay': record.netPay,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
