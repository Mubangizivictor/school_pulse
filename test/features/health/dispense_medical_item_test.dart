import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/health/data/datasources/health_local_data_source.dart';
import 'package:school_pulse/features/health/data/datasources/health_remote_data_source.dart';
import 'package:school_pulse/features/health/data/repositories/health_repository_impl.dart';

class MockRemote extends Mock implements HealthRemoteDataSource {}

class MockLocal extends Mock implements HealthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late MockNetworkInfo net;
  late HealthRepositoryImpl repo;

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    net = MockNetworkInfo();
    repo = HealthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: net,
    );
  });

  const args = {
    'itemId': 'item-1',
    'visitId': 'visit-1',
    'studentId': 'student-1',
    'quantity': 2,
  };

  Future<Either<Failure, void>> callRepo() => repo.dispenseMedicalItem(
    itemId: args['itemId']! as String,
    visitId: args['visitId']! as String,
    studentId: args['studentId']! as String,
    quantity: args['quantity']! as int,
  );

  test(
    'offline: never reaches the callable and returns a ServerFailure',
    () async {
      when(() => net.isConnected).thenAnswer((_) async => false);

      final result = await callRepo();

      expect(result.isLeft(), isTrue);
      verifyNever(
        () => remote.dispenseMedicalItem(
          itemId: any(named: 'itemId'),
          visitId: any(named: 'visitId'),
          studentId: any(named: 'studentId'),
          quantity: any(named: 'quantity'),
        ),
      );
    },
  );

  test(
    'online: forwards itemId/visitId/studentId/quantity to the datasource',
    () async {
      when(() => net.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.dispenseMedicalItem(
          itemId: any(named: 'itemId'),
          visitId: any(named: 'visitId'),
          studentId: any(named: 'studentId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async {});

      final result = await callRepo();

      expect(result, const Right<Failure, void>(null));
      verify(
        () => remote.dispenseMedicalItem(
          itemId: 'item-1',
          visitId: 'visit-1',
          studentId: 'student-1',
          quantity: 2,
        ),
      ).called(1);
    },
  );

  test(
    "surfaces the callable's precondition message verbatim to the nurse",
    () async {
      when(() => net.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.dispenseMedicalItem(
          itemId: any(named: 'itemId'),
          visitId: any(named: 'visitId'),
          studentId: any(named: 'studentId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenThrow(
        Exception(
          '[firebase_functions/failed-precondition] Insufficient stock.',
        ),
      );

      final result = await callRepo();

      result.fold(
        (f) => expect(f.message, contains('Insufficient stock')),
        (_) => fail('expected a failure'),
      );
    },
  );

  test('an unrecognised error falls back to a generic message', () async {
    when(() => net.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.dispenseMedicalItem(
        itemId: any(named: 'itemId'),
        visitId: any(named: 'visitId'),
        studentId: any(named: 'studentId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenThrow(Exception('some unexpected transport error'));

    final result = await callRepo();

    result.fold(
      (f) => expect(
        f.message,
        'The item could not be dispensed. Please try again.',
      ),
      (_) => fail('expected a failure'),
    );
  });
}
