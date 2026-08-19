import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/admin_attendance_repository.dart';

class AdminAttendanceRepositoryImpl implements AdminAttendanceRepository {
  final FirebaseFirestore firestore;

  AdminAttendanceRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, (double, List<double>)>> getStudentAttendanceStats(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sampleDays = (startDate != null && endDate != null)
          ? _schoolDaysInRange(startDate, endDate, cap: 30)
          : _lastSchoolDays(DateTime.now(), count: 5);

      final List<double> weeklyStats = [];
      double totalSum = 0;
      int daysWithData = 0;

      for (final date in sampleDays) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final snapshot = await firestore
            .collection('schools')
            .doc(schoolId)
            .collection('class_attendance_sessions')
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('date', isLessThan: Timestamp.fromDate(endOfDay))
            .where('status', isEqualTo: 'submitted')
            .get();

        if (snapshot.docs.isEmpty) {
          weeklyStats.add(0.0);
          continue;
        }

        int present = 0;
        int total = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final counts = data['counts'] as Map<String, dynamic>?;
          if (counts != null) {
            final p = (counts['present'] as num?)?.toInt() ?? 0;
            final a = (counts['absent'] as num?)?.toInt() ?? 0;
            final l = (counts['late'] as num?)?.toInt() ?? 0;
            final e = (counts['excused'] as num?)?.toInt() ?? 0;

            present += p;
            total += (p + a + l + e);
          }
        }

        if (total > 0) {
          final dayAverage = present / total;
          weeklyStats.add(dayAverage);
          totalSum += dayAverage;
          daysWithData++;
        } else {
          weeklyStats.add(0.0);
        }
      }

      if (daysWithData == 0) {
        return const Left(ServerFailure('No attendance data recorded yet'));
      }

      final average = totalSum / daysWithData;
      return Right((average, weeklyStats));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  List<DateTime> _lastSchoolDays(DateTime from, {required int count}) {
    return List.generate(7, (i) => from.subtract(Duration(days: i)))
        .where(
          (date) =>
              date.weekday != DateTime.saturday &&
              date.weekday != DateTime.sunday,
        )
        .take(count)
        .toList()
        .reversed
        .toList();
  }

  /// School days across [start]..[end] inclusive, sampled down to at most
  /// [cap] evenly-spaced days so a full term doesn't trigger dozens of
  /// Firestore reads for one dashboard stat.
  List<DateTime> _schoolDaysInRange(
    DateTime start,
    DateTime end,
    {required int cap}
  ) {
    final schoolDays = <DateTime>[];
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (cursor.weekday != DateTime.saturday &&
          cursor.weekday != DateTime.sunday) {
        schoolDays.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    if (schoolDays.length <= cap) return schoolDays;
    final step = schoolDays.length / cap;
    return List.generate(cap, (i) => schoolDays[(i * step).floor()]);
  }
}
