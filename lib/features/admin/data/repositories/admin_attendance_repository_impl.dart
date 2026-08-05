import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/admin_attendance_repository.dart';

class AdminAttendanceRepositoryImpl implements AdminAttendanceRepository {
  final FirebaseFirestore firestore;

  AdminAttendanceRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, (double, List<double>)>> getStudentAttendanceStats(
    String schoolId,
  ) async {
    try {
      final now = DateTime.now();
      final last7Days = List.generate(7, (i) => now.subtract(Duration(days: i)))
          .where(
            (date) =>
                date.weekday != DateTime.saturday &&
                date.weekday != DateTime.sunday,
          )
          .take(5)
          .toList()
          .reversed
          .toList();

      final List<double> weeklyStats = [];
      double totalSum = 0;
      int daysWithData = 0;

      for (final date in last7Days) {
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

      final average = daysWithData > 0 ? totalSum / daysWithData : 0.0;

      // Fallback if no data at all to make dashboard look "alive" during initial setup
      if (weeklyStats.every((v) => v == 0.0)) {
        return const Right((0.0, [0.0, 0.0, 0.0, 0.0, 0.0]));
      }

      return Right((average, weeklyStats));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
