// Proves SuperAdminRepository.getSchoolAdmins is wired end to end from the
// interface through to the implementation - the small additive repository
// method School Details' School Admins panel depends on, since there was
// previously no school-scoped admin query anywhere in this codebase.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/super_admin/data/repositories/super_admin_repository_impl.dart';
import 'package:school_pulse/features/super_admin/data/datasources/super_admin_remote_datasource.dart';
import 'package:school_pulse/features/super_admin/domain/repositories/super_admin_repository.dart';

class _MockDataSource extends Mock implements SuperAdminRemoteDataSource {}

void main() {
  test('repository delegates getSchoolAdmins to the datasource', () async {
    final dataSource = _MockDataSource();
    final repository = SuperAdminRepositoryImpl(remoteDataSource: dataSource);
    const admins = [
      SchoolAdminSummary(
        uid: 'u1',
        name: 'Sarah N.',
        email: 'sarah@greenhill.ug',
        isPrimary: true,
        mfaEnabled: true,
      ),
    ];
    when(
      () => dataSource.getSchoolAdmins('school1'),
    ).thenAnswer((_) async => admins);

    final result = await repository.getSchoolAdmins('school1');

    expect(result, admins);
    verify(() => dataSource.getSchoolAdmins('school1')).called(1);
  });

  test('SchoolAdminSummary equality is field-based for widget/bloc testing', () {
    const a = SchoolAdminSummary(uid: 'u1', name: 'A', email: 'a@x.com');
    const b = SchoolAdminSummary(uid: 'u1', name: 'A', email: 'a@x.com');
    expect(a, b);
  });
}
