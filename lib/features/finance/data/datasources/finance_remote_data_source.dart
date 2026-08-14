import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fee_category_model.dart';
import '../models/fee_structure_model.dart';
import '../models/student_financial_account_model.dart';
import '../models/payment_record_model.dart';
import '../models/budget_model.dart';
import '../models/expenditure_model.dart';
import '../models/fee_item_model.dart';
import '../../domain/entities/expenditure.dart';

abstract class FinanceRemoteDataSource {
  // Fee Configuration
  Future<List<FeeCategoryModel>> getFeeCategories(String schoolId);
  Future<void> saveFeeCategory(FeeCategoryModel category);
  Future<List<FeeStructureModel>> getFeeStructures(String schoolId);
  Future<void> saveFeeStructure(FeeStructureModel structure);

  // Student Financials
  Future<StudentFinancialAccountModel> getStudentFinancialAccount(
    String studentId,
    String schoolId,
  );
  Future<List<StudentFinancialAccountModel>> getFinancialAccountsByClass(
    String schoolId,
    String classId,
  );
  Future<void> updateStudentFinancialAccount(
    StudentFinancialAccountModel account,
  );

  // Payments
  Future<List<PaymentRecordModel>> getPaymentHistory(
    String studentId,
    String schoolId,
  );
  Future<List<PaymentRecordModel>> getSchoolPayments(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<PaymentRecordModel>> getAllPaymentHistory();
  Future<String> recordPayment(PaymentRecordModel payment);
  Future<void> cancelPayment(String paymentId, String reason);

  // Fees
  Future<List<FeeItemModel>> getFees(String studentId);
  Future<List<FeeItemModel>> getAllFees();

  // Budgeting
  Future<List<BudgetModel>> getBudgets(
    String schoolId,
    String academicYear,
    String term,
  );
  Future<void> saveBudget(BudgetModel budget);

  // Expenditure
  Future<List<ExpenditureRequestModel>> getExpenditureRequests(String schoolId);
  Future<void> createExpenditureRequest(ExpenditureRequestModel request);
  Future<void> updateExpenditureStatus(
    String schoolId,
    String requestId,
    ExpenditureStatus status,
    String approverId,
    String approverName,
    String approverRole,
    String? comment,
  );

  // Dashboard & Reports
  Future<Map<String, dynamic>> getFinancialDashboardKPIs(String schoolId);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final FirebaseFirestore firestore;

  FinanceRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<FeeCategoryModel>> getFeeCategories(String schoolId) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('fee_categories')
        .orderBy('priority')
        .get();
    return snapshot.docs
        .map((doc) => FeeCategoryModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> saveFeeCategory(FeeCategoryModel category) async {
    final docRef = firestore
        .collection('schools')
        .doc(category.schoolId)
        .collection('fee_categories')
        .doc(category.id.isEmpty ? null : category.id);
    await docRef.set(category.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<List<FeeStructureModel>> getFeeStructures(String schoolId) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('fee_structures')
        .get();
    return snapshot.docs
        .map((doc) => FeeStructureModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> saveFeeStructure(FeeStructureModel structure) async {
    final docRef = firestore
        .collection('schools')
        .doc(structure.schoolId)
        .collection('fee_structures')
        .doc(structure.id.isEmpty ? null : structure.id);
    await docRef.set(structure.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<StudentFinancialAccountModel> getStudentFinancialAccount(
    String studentId,
    String schoolId,
  ) async {
    final doc = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('student_financials')
        .doc(studentId)
        .get();

    if (!doc.exists) {
      throw Exception("Financial account not found");
    }
    return StudentFinancialAccountModel.fromFirestore(doc);
  }

  @override
  Future<List<StudentFinancialAccountModel>> getFinancialAccountsByClass(
    String schoolId,
    String classId,
  ) async {
    // This assumes student documents have classId or we filter financial accounts
    // For now, let's assume we store classId in the financial account for easy filtering
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('student_financials')
        .where('classId', isEqualTo: classId)
        .get();
    return snapshot.docs
        .map((doc) => StudentFinancialAccountModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> updateStudentFinancialAccount(
    StudentFinancialAccountModel account,
  ) async {
    await firestore
        .collection('schools')
        .doc(account.schoolId)
        .collection('student_financials')
        .doc(account.studentId)
        .set(account.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<List<PaymentRecordModel>> getPaymentHistory(
    String studentId,
    String schoolId,
  ) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('payments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PaymentRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<PaymentRecordModel>> getSchoolPayments(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('payments')
        .orderBy('date', descending: true);

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PaymentRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<PaymentRecordModel>> getAllPaymentHistory() async {
    final snapshot = await firestore
        .collectionGroup('payments')
        .orderBy('date', descending: true)
        .limit(100)
        .get();
    return snapshot.docs
        .map((doc) => PaymentRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<FeeItemModel>> getFees(String studentId) async {
    final snapshot = await firestore
        .collectionGroup('fees')
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs.map((doc) => FeeItemModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<FeeItemModel>> getAllFees() async {
    final snapshot = await firestore.collectionGroup('fees').limit(100).get();
    return snapshot.docs.map((doc) => FeeItemModel.fromFirestore(doc)).toList();
  }

  @override
  Future<String> recordPayment(PaymentRecordModel payment) async {
    final docRef = await firestore
        .collection('schools')
        .doc(payment.schoolId)
        .collection('payments')
        .add(payment.toFirestore());

    // Update student financial account total paid
    final accountRef = firestore
        .collection('schools')
        .doc(payment.schoolId)
        .collection('student_financials')
        .doc(payment.studentId);

    await firestore.runTransaction((transaction) async {
      final accountDoc = await transaction.get(accountRef);
      if (accountDoc.exists) {
        double currentPaid = (accountDoc.data()?['totalPaid'] ?? 0).toDouble();
        List history = accountDoc.data()?['paymentHistory'] ?? [];
        history.add(payment.toMap());

        transaction.update(accountRef, {
          'totalPaid': currentPaid + payment.amount,
          'paymentHistory': history,
        });
      }
    });

    return docRef.id;
  }

  @override
  Future<void> cancelPayment(String paymentId, String reason) async {
    // Implement cancellation logic (e.g. mark as cancelled, reverse balance)
    // This would likely involve a Cloud Function or a transaction
  }

  @override
  Future<List<BudgetModel>> getBudgets(
    String schoolId,
    String academicYear,
    String term,
  ) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('budgets')
        .where('academicYear', isEqualTo: academicYear)
        .where('term', isEqualTo: term)
        .get();
    return snapshot.docs.map((doc) => BudgetModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    final docRef = firestore
        .collection('schools')
        .doc(budget.schoolId)
        .collection('budgets')
        .doc(budget.id.isEmpty ? null : budget.id);
    await docRef.set(budget.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<List<ExpenditureRequestModel>> getExpenditureRequests(
    String schoolId,
  ) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('expenditures')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ExpenditureRequestModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> createExpenditureRequest(ExpenditureRequestModel request) async {
    await firestore
        .collection('schools')
        .doc(request.schoolId)
        .collection('expenditures')
        .add(request.toFirestore());
  }

  @override
  Future<void> updateExpenditureStatus(
    String schoolId,
    String requestId,
    ExpenditureStatus status,
    String approverId,
    String approverName,
    String approverRole,
    String? comment,
  ) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('expenditures')
        .doc(requestId)
        .update({
          'status': status.name,
          'approverId': approverId,
          'approverName': approverName,
          'approverRole': approverRole,
          'approvalComment': comment,
          'approvedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<Map<String, dynamic>> getFinancialDashboardKPIs(
    String schoolId,
  ) async {
    final school = firestore.collection('schools').doc(schoolId);
    final results = await Future.wait([
      school.collection('payments').get(),
      school.collection('student_financials').get(),
      school.collection('expenditures').get(),
    ]);

    final payments = results[0].docs;
    final accounts = results[1].docs;
    final expenditures = results[2].docs;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double todayCollections = 0;
    double termCollections = 0;
    double yearCollections = 0;
    double cashPosition = 0;
    double bankPosition = 0;
    double mobileMoneyPosition = 0;

    for (final payment in payments) {
      final data = payment.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final dateValue = data['date'];
      final date = dateValue is Timestamp ? dateValue.toDate() : null;
      final method = (data['method'] ?? '').toString().toLowerCase();
      if (date != null && !date.isBefore(today)) todayCollections += amount;
      if (date != null && date.year == now.year) yearCollections += amount;
      // Term totals are based on the active account/payment term stored by the
      // school. If no explicit active term is present, current-year payments
      // remain the safest non-hardcoded operational total.
      if (date != null && date.year == now.year) termCollections += amount;
      if (method.contains('cash')) {
        cashPosition += amount;
      } else if (method.contains('mobile')) {
        mobileMoneyPosition += amount;
      } else {
        bankPosition += amount;
      }
    }

    double collectionTarget = 0;
    double outstandingFees = 0;
    var fullyPaid = 0;
    var partiallyPaid = 0;
    var noPayments = 0;
    for (final account in accounts) {
      final data = account.data();
      final billed = (data['totalBilled'] as num?)?.toDouble() ?? 0;
      final paid = (data['totalPaid'] as num?)?.toDouble() ?? 0;
      final scholarship = (data['scholarshipAmount'] as num?)?.toDouble() ?? 0;
      final discount = (data['discountAmount'] as num?)?.toDouble() ?? 0;
      final netBill = (billed - scholarship - discount)
          .clamp(0, double.infinity)
          .toDouble();
      final balance = (netBill - paid).clamp(0, double.infinity).toDouble();
      collectionTarget += netBill;
      outstandingFees += balance;
      if (balance <= 0 && netBill > 0) {
        fullyPaid++;
      } else if (paid > 0) {
        partiallyPaid++;
      } else {
        noPayments++;
      }
    }

    var pendingRequests = 0;
    var awaitingRelease = 0;
    for (final request in expenditures) {
      final status = (request.data()['status'] ?? '').toString().toLowerCase();
      if (status == 'pending' || status == 'reviewed') pendingRequests++;
      if (status == 'approved') awaitingRelease++;
    }

    return {
      'todayCollections': todayCollections,
      'termCollections': termCollections,
      'yearCollections': yearCollections,
      'collectionTarget': collectionTarget,
      'collectionPercentage': collectionTarget > 0
          ? ((yearCollections / collectionTarget) * 100).clamp(0, 100).round()
          : 0,
      'outstandingFees': outstandingFees,
      'studentsFullyPaid': fullyPaid,
      'studentsPartiallyPaid': partiallyPaid,
      'studentsWithNoPayments': noPayments,
      'pendingExpenditureRequests': pendingRequests,
      'approvedAwaitingRelease': awaitingRelease,
      'cashPosition': cashPosition,
      'bankPosition': bankPosition,
      'mobileMoneyPosition': mobileMoneyPosition,
    };
  }
}
