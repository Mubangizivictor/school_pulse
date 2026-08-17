import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/attendance_hub/data/datasources/sheets_integration_remote_data_source.dart';
import 'package:school_pulse/features/attendance_hub/data/repositories/sheets_integration_repository_impl.dart';

class _MockRemoteDataSource extends Mock
    implements SheetsIntegrationRemoteDataSource {}

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockResult extends Mock implements HttpsCallableResult {}

void main() {
  late _MockRemoteDataSource remoteDataSource;
  late _MockFunctions functions;
  late _MockCallable callable;
  late SheetsIntegrationRepositoryImpl repository;

  const schoolId = 'schoolA';

  setUp(() {
    remoteDataSource = _MockRemoteDataSource();
    functions = _MockFunctions();
    callable = _MockCallable();
    repository = SheetsIntegrationRepositoryImpl(
      remoteDataSource: remoteDataSource,
      functions: functions,
    );
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  test('startConnect returns the authUrl from startGoogleSheetsOAuth', () async {
    final result = _MockResult();
    when(() => result.data).thenReturn({'authUrl': 'https://accounts.google.com/o/oauth2/auth'});
    when(() => callable.call()).thenAnswer((_) async => result);

    final either = await repository.startConnect(schoolId);

    expect(either.isRight(), isTrue);
    either.fold((_) => fail('expected Right'), (url) {
      expect(url, 'https://accounts.google.com/o/oauth2/auth');
    });
    verify(() => functions.httpsCallable('startGoogleSheetsOAuth')).called(1);
  });

  test(
    'a needs_reauth backend error maps to the friendly renewal message, not the raw error',
    () async {
      when(() => callable.call()).thenThrow(
        FirebaseFunctionsException(
          message: 'invalid_grant from Google',
          code: 'failed-precondition',
          details: {'reason': 'needs_reauth'},
        ),
      );

      final either = await repository.triggerSync(schoolId, 0);

      expect(either.isLeft(), isTrue);
      either.fold(
        (failure) => expect(
          failure.message,
          'Google Sheets connection needs to be renewed.',
        ),
        (_) => fail('expected Left'),
      );
    },
  );

  test('a not_connected backend error maps to a friendly connect-first message', () async {
    when(() => callable.call(any())).thenThrow(
      FirebaseFunctionsException(
        message: 'no token doc',
        code: 'failed-precondition',
        details: {'reason': 'not_connected'},
      ),
    );

    final either = await repository.resync(schoolId);

    expect(either.isLeft(), isTrue);
    either.fold(
      (failure) => expect(failure.message, 'Connect Google Sheets first.'),
      (_) => fail('expected Left'),
    );
  });

  test('a temporary backend failure never claims attendance itself failed', () async {
    when(() => callable.call(any())).thenThrow(
      FirebaseFunctionsException(
        message: 'quota exceeded',
        code: 'internal',
        details: {'reason': 'temporary'},
      ),
    );

    final either = await repository.exportSession(schoolId, ['rec1']);

    expect(either.isLeft(), isTrue);
    either.fold(
      (failure) => expect(
        failure.message,
        'Attendance is saved. Google Sheets will sync automatically when available.',
      ),
      (_) => fail('expected Left'),
    );
  });

  test('updateAutoSync writes only the preference field via the data source', () async {
    when(() => remoteDataSource.updatePreferences(schoolId, autoSync: true))
        .thenAnswer((_) async {});

    final either = await repository.updateAutoSync(schoolId, true);

    expect(either.isRight(), isTrue);
    verify(() => remoteDataSource.updatePreferences(schoolId, autoSync: true)).called(1);
  });
}
