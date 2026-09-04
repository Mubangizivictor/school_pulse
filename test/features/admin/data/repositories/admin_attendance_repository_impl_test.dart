import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/data/repositories/admin_attendance_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AdminAttendanceRepositoryImpl repository;
  const schoolId = 'school-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = AdminAttendanceRepositoryImpl(firestore: firestore);
  });

  Future<void> seedSession({
    required DateTime date,
    required String status,
    required Map<String, int> counts,
  }) => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('class_attendance_sessions')
      .add({
        'date': Timestamp.fromDate(date),
        'status': status,
        'counts': counts,
      });

  group('getTodayAttendanceCounts', () {
    test('sums present/late/absent/excused across today\'s submitted sessions', () async {
      final today = DateTime.now();
      await seedSession(
        date: today,
        status: 'submitted',
        counts: {'present': 20, 'late': 2, 'absent': 1, 'excused': 0},
      );
      await seedSession(
        date: today,
        status: 'submitted',
        counts: {'present': 15, 'late': 0, 'absent': 3, 'excused': 1},
      );

      final result = await repository.getTodayAttendanceCounts(schoolId);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (counts) {
        expect(counts.present, 35);
        expect(counts.late, 2);
        expect(counts.absent, 4);
        expect(counts.excused, 1);
        expect(counts.total, 42);
      });
    });

    test('excludes non-submitted (draft) sessions', () async {
      final today = DateTime.now();
      await seedSession(
        date: today,
        status: 'draft',
        counts: {'present': 99, 'late': 0, 'absent': 0, 'excused': 0},
      );

      final result = await repository.getTodayAttendanceCounts(schoolId);

      result.fold((_) => fail('expected Right'), (counts) {
        expect(counts.total, 0);
      });
    });

    test('excludes sessions from other days', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await seedSession(
        date: yesterday,
        status: 'submitted',
        counts: {'present': 50, 'late': 0, 'absent': 0, 'excused': 0},
      );

      final result = await repository.getTodayAttendanceCounts(schoolId);

      result.fold((_) => fail('expected Right'), (counts) {
        expect(counts.total, 0);
      });
    });

    test('returns zero counts (not a failure) when nothing submitted yet', () async {
      final result = await repository.getTodayAttendanceCounts(schoolId);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (counts) {
        expect(counts.total, 0);
        expect(counts.presentPercent, 0);
      });
    });
  });
}
