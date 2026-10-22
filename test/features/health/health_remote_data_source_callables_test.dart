import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/health/data/datasources/health_remote_data_source.dart';
import 'package:school_pulse/features/health/data/models/clinic_visit_model.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';

class MockFunctions extends Mock implements FirebaseFunctions {}

class MockCallable extends Mock implements HttpsCallable {}

class FakeResult<T> implements HttpsCallableResult<T> {
  FakeResult(this._data);
  final T _data;
  @override
  T get data => _data;
}

void main() {
  late MockFunctions functions;
  late MockCallable createCallable;
  late MockCallable dispenseCallable;
  late FakeFirebaseFirestore firestore;
  late HealthRemoteDataSourceImpl ds;

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    functions = MockFunctions();
    createCallable = MockCallable();
    dispenseCallable = MockCallable();
    firestore = FakeFirebaseFirestore();
    ds = HealthRemoteDataSourceImpl(firestore: firestore, functions: functions);

    when(
      () => functions.httpsCallable('createClinicVisit'),
    ).thenReturn(createCallable);
    when(
      () => functions.httpsCallable('dispenseMedicalItem'),
    ).thenReturn(dispenseCallable);
  });

  ClinicVisitModel visit() => ClinicVisitModel(
    id: 'visit-1',
    studentId: 'student-1',
    dateTime: DateTime.utc(2026, 7, 25, 10),
    reason: 'Headache',
    symptoms: 'Pain',
    outcome: VisitOutcome.sentBackToClass,
    recordedBy: 'nurse-1',
    schoolId: 'school-1',
  );

  test(
    'recordClinicVisit calls createClinicVisit with a JSON-safe payload',
    () async {
      final result = FakeResult<Map<String, dynamic>>({
        'id': 'visit-1',
        'status': 'completed',
      });
      Map<String, dynamic>? sent;
      when(() => createCallable.call<Map<String, dynamic>>(any())).thenAnswer((
        inv,
      ) async {
        sent = (inv.positionalArguments.first as Map).cast<String, dynamic>();
        return result;
      });

      await ds.recordClinicVisit(visit());

      verify(() => functions.httpsCallable('createClinicVisit')).called(1);
      final payload = sent!['visit'] as Map<String, dynamic>;
      expect(payload['schoolId'], 'school-1');
      expect(payload['studentId'], 'student-1');
      // dateTime must be an ISO string, not a Firestore Timestamp.
      expect(payload['dateTime'], isA<String>());
      expect(payload['dateTime'], startsWith('2026-07-25T10:00:00'));
    },
  );

  test('recordClinicVisit throws when the callable returns no id', () async {
    final result = FakeResult<Map<String, dynamic>>(<String, dynamic>{});
    when(
      () => createCallable.call<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => result);

    expect(() => ds.recordClinicVisit(visit()), throwsA(isA<StateError>()));
  });

  test(
    'pushClinicVisitIfAbsent also goes through the idempotent callable (no client existence check)',
    () async {
      final result = FakeResult<Map<String, dynamic>>({'id': 'visit-1'});
      when(
        () => createCallable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => result);

      await ds.pushClinicVisitIfAbsent(visit());

      verify(() => createCallable.call<Map<String, dynamic>>(any())).called(1);
    },
  );

  test('dispenseMedicalItem forwards the four args to the callable', () async {
    Map<String, dynamic>? sent;
    when(() => dispenseCallable.call<dynamic>(any())).thenAnswer((inv) async {
      sent = (inv.positionalArguments.first as Map).cast<String, dynamic>();
      return FakeResult<dynamic>(null);
    });

    await ds.dispenseMedicalItem(
      itemId: 'item-1',
      visitId: 'visit-1',
      studentId: 'student-1',
      quantity: 3,
    );

    verify(() => functions.httpsCallable('dispenseMedicalItem')).called(1);
    expect(sent, {
      'itemId': 'item-1',
      'visitId': 'visit-1',
      'studentId': 'student-1',
      'quantity': 3,
    });
  });
}
