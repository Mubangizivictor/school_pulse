import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/attendance_hub/data/datasources/attendance_remote_data_source.dart';
import 'package:school_pulse/features/attendance_hub/data/models/attendance_record_model.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_record.dart';

AttendanceRecordModel _record({
  String schoolId = 'school-a',
  String personId = 'student-1',
}) => AttendanceRecordModel(
  id: '',
  schoolId: schoolId,
  category: AttendanceCategory.students,
  scopeId: 'class-1',
  date: DateTime(2026, 8, 13),
  personId: personId,
  status: AttendanceStatus.present,
  method: AttendanceMethod.manual,
  createdAt: DateTime(2026, 8, 13, 8),
);

void main() {
  late FakeFirebaseFirestore firestore;
  late AttendanceRemoteDataSourceImpl dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = AttendanceRemoteDataSourceImpl(firestore: firestore);
  });

  test('rejects a mixed-school batch before writing any record', () async {
    await expectLater(
      dataSource.markBatch([
        _record(schoolId: 'school-a'),
        _record(schoolId: 'school-b', personId: 'student-2'),
      ]),
      throwsArgumentError,
    );

    final schoolA = await firestore
        .collection('schools')
        .doc('school-a')
        .collection('attendance_records')
        .get();
    final schoolB = await firestore
        .collection('schools')
        .doc('school-b')
        .collection('attendance_records')
        .get();
    expect(schoolA.docs, isEmpty);
    expect(schoolB.docs, isEmpty);
  });

  test('rejects duplicate deterministic records inside one batch', () async {
    await expectLater(
      dataSource.markBatch([_record(), _record()]),
      throwsA(isA<DuplicateAttendanceException>()),
    );

    final records = await firestore
        .collection('schools')
        .doc('school-a')
        .collection('attendance_records')
        .get();
    expect(records.docs, isEmpty);
  });
}
