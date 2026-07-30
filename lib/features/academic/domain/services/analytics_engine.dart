import 'package:equatable/equatable.dart';
import '../entities/subject_result.dart';

class AcademicAnalytics extends Equatable {
  final Map<String, double> gradeDistribution; // Grade -> Percentage
  final double averagePassRate;
  final List<SubjectResult> topPerformers;
  final List<SubjectResult> bottomPerformers;
  final List<PerformanceTrendPoint> trends;

  const AcademicAnalytics({
    required this.gradeDistribution,
    required this.averagePassRate,
    required this.topPerformers,
    required this.bottomPerformers,
    required this.trends,
  });

  @override
  List<Object?> get props => [gradeDistribution, averagePassRate, topPerformers, bottomPerformers, trends];
}

class PerformanceTrendPoint extends Equatable {
  final String label; // e.g., "Term 1 2023"
  final double average;

  const PerformanceTrendPoint(this.label, this.average);

  @override
  List<Object?> get props => [label, average];
}

class Award extends Equatable {
  final String title;
  final String studentId;
  final String studentName;
  final String reason;

  const Award({required this.title, required this.studentId, required this.studentName, required this.reason});

  @override
  List<Object?> get props => [title, studentId, studentName, reason];
}

class RankingResult extends Equatable {
  final Map<String, int> subjectPositions; // subjectId -> position
  final int classPosition;
  final int streamPosition;
  final int totalStudentsInClass;
  final int totalStudentsInStream;

  const RankingResult({
    required this.subjectPositions,
    required this.classPosition,
    required this.streamPosition,
    required this.totalStudentsInClass,
    required this.totalStudentsInStream,
  });

  @override
  List<Object?> get props => [subjectPositions, classPosition, streamPosition, totalStudentsInClass, totalStudentsInStream];
}

/// Automatically computes class/subject/term/year comparisons, grade
/// distribution, pass rate, rankings and awards - never entered manually.
class AnalyticsEngine {
  static AcademicAnalytics calculateClassAnalytics(List<SubjectResult> allStudentResults) {
    // 1. Grade Distribution
    Map<String, int> counts = {};
    for (var result in allStudentResults) {
      counts[result.grade] = (counts[result.grade] ?? 0) + 1;
    }

    Map<String, double> distribution = {};
    if (allStudentResults.isNotEmpty) {
      counts.forEach((grade, count) {
        distribution[grade] = (count / allStudentResults.length) * 100;
      });
    }

    // 2. Pass Rate - a subject counts as a pass unless its grade/remarks
    // says otherwise. Since grade labels are school-configurable (not
    // always 'F'), pass/fail is derived from the grade's remarks field
    // containing 'fail' rather than a hardcoded grade letter.
    int passes = allStudentResults.where((r) => !r.remarks.toLowerCase().contains('fail')).length;
    double passRate = allStudentResults.isEmpty ? 0 : (passes / allStudentResults.length) * 100;

    // 3. Sorting for general analytics
    List<SubjectResult> sorted = List.from(allStudentResults)
      ..sort((a, b) => b.totalMark.compareTo(a.totalMark));

    return AcademicAnalytics(
      gradeDistribution: distribution,
      averagePassRate: passRate,
      topPerformers: sorted.take(5).toList(),
      bottomPerformers: sorted.reversed.take(5).toList(),
      trends: const [],
    );
  }

  /// Calculates positions for all students in a given group (Class or Stream).
  /// Returns a Map of StudentID -> RankingResult.
  static Map<String, RankingResult> calculateBatchRankings({
    required Map<String, List<SubjectResult>> studentResults, // studentId -> list of results
    required Map<String, String> studentStreams, // studentId -> streamId
    required Map<String, String> studentClasses, // studentId -> classId
  }) {
    Map<String, RankingResult> rankings = {};

    // 1. Calculate Overall Averages
    Map<String, double> overallAverages = {};
    studentResults.forEach((studentId, results) {
      if (results.isEmpty) {
        overallAverages[studentId] = 0;
      } else {
        double total = results.fold(0, (sum, r) => sum + r.percentage);
        overallAverages[studentId] = total / results.length;
      }
    });

    // 2. Class Positions
    final classGroups = _groupBy(studentClasses);
    classGroups.forEach((classId, studentIds) {
      final sortedIds = List<String>.from(studentIds)
        ..sort((a, b) => overallAverages[b]!.compareTo(overallAverages[a]!));

      for (int i = 0; i < sortedIds.length; i++) {
        final studentId = sortedIds[i];
        final currentRanking = rankings[studentId];
        rankings[studentId] = _updateRanking(
          currentRanking,
          classPosition: i + 1,
          totalClass: sortedIds.length,
        );
      }
    });

    // 3. Stream Positions
    final streamGroups = _groupBy(studentStreams);
    streamGroups.forEach((streamId, studentIds) {
      final sortedIds = List<String>.from(studentIds)
        ..sort((a, b) => overallAverages[b]!.compareTo(overallAverages[a]!));

      for (int i = 0; i < sortedIds.length; i++) {
        final studentId = sortedIds[i];
        final currentRanking = rankings[studentId];
        rankings[studentId] = _updateRanking(
          currentRanking,
          streamPosition: i + 1,
          totalStream: sortedIds.length,
        );
      }
    });

    // 4. Subject Positions (Class-wide)
    Map<String, Map<String, List<MapEntry<String, double>>>> subjectScoresByClass = {};

    studentResults.forEach((studentId, results) {
      final classId = studentClasses[studentId] ?? 'unknown';
      subjectScoresByClass.putIfAbsent(classId, () => {});

      for (var result in results) {
        subjectScoresByClass[classId]!.putIfAbsent(result.subjectId, () => []);
        subjectScoresByClass[classId]![result.subjectId]!.add(MapEntry(studentId, result.totalMark));
      }
    });

    subjectScoresByClass.forEach((classId, subjects) {
      subjects.forEach((subjectId, scores) {
        scores.sort((a, b) => b.value.compareTo(a.value));
        for (int i = 0; i < scores.length; i++) {
          final studentId = scores[i].key;
          final currentRanking = rankings[studentId];
          final subjectPositions = Map<String, int>.from(currentRanking?.subjectPositions ?? {});
          subjectPositions[subjectId] = i + 1;

          rankings[studentId] = _updateRanking(
            currentRanking,
            subjectPositions: subjectPositions,
          );
        }
      });
    });

    return rankings;
  }

  static Map<String, List<String>> _groupBy(Map<String, String> map) {
    Map<String, List<String>> groups = {};
    map.forEach((key, value) {
      groups.putIfAbsent(value, () => []).add(key);
    });
    return groups;
  }

  static RankingResult _updateRanking(
    RankingResult? current, {
    int? classPosition,
    int? streamPosition,
    int? totalClass,
    int? totalStream,
    Map<String, int>? subjectPositions,
  }) {
    return RankingResult(
      classPosition: classPosition ?? current?.classPosition ?? 0,
      streamPosition: streamPosition ?? current?.streamPosition ?? 0,
      totalStudentsInClass: totalClass ?? current?.totalStudentsInClass ?? 0,
      totalStudentsInStream: totalStream ?? current?.totalStudentsInStream ?? 0,
      subjectPositions: subjectPositions ?? current?.subjectPositions ?? {},
    );
  }

  /// Best Overall Student + Top Subject Performer per subject. Most
  /// Improved and attendance/discipline-based awards are added once prior
  /// term data and read access to those modules are wired (Phase 5).
  static List<Award> calculateAwards(
    Map<String, List<SubjectResult>> studentResultsMap,
    Map<String, String> studentNames,
  ) {
    List<Award> awards = [];

    // 1. Best Overall Student
    String? topStudentId;
    double highestAvg = -1;

    studentResultsMap.forEach((studentId, results) {
      double avg = results.isEmpty ? 0 : results.fold(0.0, (sum, r) => sum + r.percentage) / results.length;
      if (avg > highestAvg) {
        highestAvg = avg;
        topStudentId = studentId;
      }
    });

    if (topStudentId != null) {
      awards.add(Award(
        title: 'Best Overall Student',
        studentId: topStudentId!,
        studentName: studentNames[topStudentId] ?? 'Unknown',
        reason: 'Attained an overall average of ${highestAvg.toStringAsFixed(1)}%',
      ));
    }

    // 2. Top Performer in Each Subject
    Map<String, MapEntry<String, double>> topBySubject = {}; // subjectId -> (studentId, score)

    studentResultsMap.forEach((studentId, results) {
      for (var r in results) {
        if (!topBySubject.containsKey(r.subjectId) || r.totalMark > topBySubject[r.subjectId]!.value) {
          topBySubject[r.subjectId] = MapEntry(studentId, r.totalMark);
        }
      }
    });

    topBySubject.forEach((subjectId, entry) {
      final subjectName = studentResultsMap[entry.key]!.firstWhere((r) => r.subjectId == subjectId).subjectName;
      awards.add(Award(
        title: 'Top Subject Performer: $subjectName',
        studentId: entry.key,
        studentName: studentNames[entry.key] ?? 'Unknown',
        reason: 'Scored ${entry.value.toStringAsFixed(1)} in $subjectName',
      ));
    });

    return awards;
  }
}
