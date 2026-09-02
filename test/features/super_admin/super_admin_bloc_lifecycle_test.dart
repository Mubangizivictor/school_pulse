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
import 'package:school_pulse/features/super_admin/domain/entities/audit_log.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/repositories/super_admin_repository.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_event.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_state.dart';

class _MockRepository extends Mock implements SuperAdminRepository {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _FakeSchool extends Fake implements School {}

class _FakeAuditLog extends Fake implements AuditLog {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSchool());
    registerFallbackValue(_FakeAuditLog());
  });

  late _MockRepository repository;
  late _MockFirebaseAuth auth;

  setUp(() {
    repository = _MockRepository();
    auth = _MockFirebaseAuth();
    final user = _MockUser();
    when(() => user.uid).thenReturn('ownerUid');
    when(() => auth.currentUser).thenReturn(user);
    when(() => repository.getAllSchools()).thenAnswer((_) async => []);
    when(() => repository.getSchoolApplications()).thenAnswer((_) async => []);
    when(() => repository.getSubscriptionPlans()).thenAnswer((_) async => []);
    when(() => repository.getPlatformStats()).thenAnswer((_) async => {});
  });

  blocTest<SuperAdminBloc, SuperAdminState>(
    'suspend calls repository.suspendSchool (the callable-backed path) and does not call logAction directly',
    build: () {
      when(() => repository.suspendSchool(any(), any())).thenAnswer((_) async {});
      return SuperAdminBloc(repository: repository, auth: auth);
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
      return SuperAdminBloc(repository: repository, auth: auth);
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
      return SuperAdminBloc(repository: repository, auth: auth);
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
      return SuperAdminBloc(repository: repository, auth: auth);
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
      return SuperAdminBloc(repository: repository, auth: auth);
    },
    act: (bloc) => bloc.add(
      const UpdateSchoolStatusEvent(schoolId: 'school1', status: SchoolStatus.suspended),
    ),
    expect: () => [isA<SuperAdminState>().having((s) => s.errorMessage, 'errorMessage', isNotNull)],
  );
}
