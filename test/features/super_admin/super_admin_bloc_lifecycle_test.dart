// Proves SuperAdminBloc's suspend/activate/archive/subscription-update
// event handlers call the callable-backed repository methods
// (suspendSchool/activateSchool/archiveSchool/updateSchoolSubscription -
// which SuperAdminRepositoryImpl now routes through the
// setSchoolLifecycleStatus/updateSchoolSubscriptionPlan Cloud Functions,
// not a client-side read-modify-write of schools/{id}), and that the bloc
// no longer makes a *separate* client-side logAction call for those two
// events now that the callable writes the audit entry atomically itself.
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/audit_log.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/repositories/super_admin_repository.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_event.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_state.dart';

class _MockRepository extends Mock implements SuperAdminRepository {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockManualPaymentService extends Mock implements ManualPaymentService {}

class _FakeSchool extends Fake implements School {}

class _FakeAuditLog extends Fake implements AuditLog {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSchool());
    registerFallbackValue(_FakeAuditLog());
  });

  late _MockRepository repository;
  late _MockFirebaseAuth auth;
  late _MockManualPaymentService payments;

  setUp(() {
    repository = _MockRepository();
    auth = _MockFirebaseAuth();
    payments = _MockManualPaymentService();
    final user = _MockUser();
    when(() => user.uid).thenReturn('ownerUid');
    when(() => auth.currentUser).thenReturn(user);
    when(() => repository.getAllSchools()).thenAnswer((_) async => []);
    when(() => repository.getSchoolApplications()).thenAnswer((_) async => []);
    when(() => repository.getSubscriptionPlans()).thenAnswer((_) async => []);
    when(() => repository.getPlatformStats()).thenAnswer((_) async => {});
    when(
      () => payments.getPayments(status: ManualPaymentStatus.approved),
    ).thenAnswer((_) async => []);
  });

  blocTest<SuperAdminBloc, SuperAdminState>(
    'suspend calls repository.suspendSchool (the callable-backed path) and does not call logAction directly',
    build: () {
      when(() => repository.suspendSchool(any(), any())).thenAnswer((_) async {});
      return SuperAdminBloc(repository: repository, auth: auth, payments: payments);
    },
    act: (bloc) => bloc.add(
      const UpdateSchoolStatusEvent(
        schoolId: 'school1',
        status: SchoolStatus.suspended,
        reason: 'Non-payment',
      ),
    ),
    verify: (_) {
      verify(() => repository.suspendSchool('school1', 'Non-payment')).called(1);
      verifyNever(() => repository.logAction(any()));
      verifyNever(() => repository.updateSchool(any()));
    },
  );

  blocTest<SuperAdminBloc, SuperAdminState>(
    'activate calls repository.activateSchool and does not call logAction directly',
    build: () {
      when(() => repository.activateSchool(any())).thenAnswer((_) async {});
      return SuperAdminBloc(repository: repository, auth: auth, payments: payments);
    },
    act: (bloc) => bloc.add(
      const UpdateSchoolStatusEvent(schoolId: 'school1', status: SchoolStatus.active),
    ),
    verify: (_) {
      verify(() => repository.activateSchool('school1')).called(1);
      verifyNever(() => repository.logAction(any()));
      verifyNever(() => repository.updateSchool(any()));
    },
  );

  blocTest<SuperAdminBloc, SuperAdminState>(
    'archive calls repository.archiveSchool and does not call logAction directly',
    build: () {
      when(() => repository.archiveSchool(any(), any())).thenAnswer((_) async {});
      return SuperAdminBloc(repository: repository, auth: auth, payments: payments);
    },
    act: (bloc) => bloc.add(
      const UpdateSchoolStatusEvent(
        schoolId: 'school1',
        status: SchoolStatus.archived,
        reason: 'Closed down',
      ),
    ),
    verify: (_) {
      verify(() => repository.archiveSchool('school1', 'Closed down')).called(1);
      verifyNever(() => repository.logAction(any()));
      verifyNever(() => repository.updateSchool(any()));
    },
  );

  blocTest<SuperAdminBloc, SuperAdminState>(
    'subscription update calls repository.updateSchoolSubscription and does not call logAction directly',
    build: () {
      when(
        () => repository.updateSchoolSubscription(any(), any(), any()),
      ).thenAnswer((_) async {});
      return SuperAdminBloc(repository: repository, auth: auth, payments: payments);
    },
    act: (bloc) => bloc.add(
      UpdateSubscriptionEvent(
        schoolId: 'school1',
        planId: 'growth',
        expiry: DateTime(2027, 1, 1),
      ),
    ),
    verify: (_) {
      verify(
        () => repository.updateSchoolSubscription('school1', 'growth', DateTime(2027, 1, 1)),
      ).called(1);
      verifyNever(() => repository.logAction(any()));
      verifyNever(() => repository.updateSchool(any()));
    },
  );

  blocTest<SuperAdminBloc, SuperAdminState>(
    'a repository failure surfaces as an error message, not a silent no-op',
    build: () {
      when(
        () => repository.suspendSchool(any(), any()),
      ).thenThrow(StateError('Access denied.'));
      return SuperAdminBloc(repository: repository, auth: auth, payments: payments);
    },
    act: (bloc) => bloc.add(
      const UpdateSchoolStatusEvent(schoolId: 'school1', status: SchoolStatus.suspended),
    ),
    expect: () => [isA<SuperAdminState>().having((s) => s.errorMessage, 'errorMessage', isNotNull)],
  );

  blocTest<SuperAdminBloc, SuperAdminState>(
    'approvedRevenueTotal sums real submittedAmount from approved payments, not a plan-price estimate',
    build: () {
      when(
        () => payments.getPayments(status: ManualPaymentStatus.approved),
      ).thenAnswer(
        (_) async => [
          ManualSubscriptionPayment(
            id: 'p1',
            schoolId: 'school1',
            schoolName: 'Greenhill Academy',
            planId: 'growth',
            planName: 'Growth',
            paymentType: ManualPaymentType.activation,
            expectedAmount: 550000,
            submittedAmount: 550000,
            currency: 'UGX',
            method: ManualPaymentMethod.mtn,
            payerName: 'Victor Mubangizi',
            reference: 'MP1',
            paidAt: DateTime(2026, 1, 1),
            submittedAt: DateTime(2026, 1, 1),
            status: ManualPaymentStatus.approved,
            hasProof: true,
          ),
          ManualSubscriptionPayment(
            id: 'p2',
            schoolId: 'school2',
            schoolName: 'Rehema',
            planId: 'growth',
            planName: 'Growth',
            paymentType: ManualPaymentType.renewal,
            expectedAmount: 300000,
            submittedAmount: 250000,
            currency: 'UGX',
            method: ManualPaymentMethod.bank,
            payerName: 'Rehema Admin',
            reference: 'MP2',
            paidAt: DateTime(2026, 2, 1),
            submittedAt: DateTime(2026, 2, 1),
            status: ManualPaymentStatus.approved,
            hasProof: true,
          ),
        ],
      );
      return SuperAdminBloc(repository: repository, auth: auth, payments: payments);
    },
    act: (bloc) => bloc.add(LoadSuperAdminDashboard()),
    expect: () => [
      isA<SuperAdminState>().having(
        (s) => s.status,
        'status',
        SuperAdminStatus.loading,
      ),
      isA<SuperAdminState>().having(
        (s) => s.approvedRevenueTotal,
        'approvedRevenueTotal',
        550000 + 250000,
      ),
    ],
  );
}
