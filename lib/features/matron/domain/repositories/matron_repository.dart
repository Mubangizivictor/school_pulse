import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/boarding_entities.dart';

abstract class MatronRepository {
  /// [gender] scopes results to 'Male' (Patron) or 'Female' (Matron)
  Future<Either<Failure, BoardingDashboardData>> getDashboardData({
    String? schoolId,
    String? gender,
  });

  // Dormitory Management
  Future<Either<Failure, List<Dormitory>>> getDormitories({String? gender});
  Future<Either<Failure, List<BoardingStudent>>> getUnallocatedStudents({
    String? gender,
  });
  Future<Either<Failure, void>> allocateStudent(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  );
  Future<Either<Failure, List<BoardingStudent>>> getDormitoryStudents(
    String dormitoryId,
  );

  // Attendance
  Future<Either<Failure, void>> submitAttendance({
    required String dormitoryId,
    required String type, // 'Morning', 'Evening', 'Night'
    required Map<String, String> attendance, // studentId -> status
  });

  // Welfare
  Future<Either<Failure, List<WelfareRecord>>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    String? gender,
    bool publicOnly = false,
  });
  Future<Either<Failure, void>> addWelfareRecord(WelfareRecord record);

  // Discipline
  Future<Either<Failure, List<DisciplineCase>>> getDisciplineCases({
    String? studentId,
    String? gender,
  });
  Future<Either<Failure, void>> addDisciplineCase(
    DisciplineCase disciplineCase,
  );

  // Hygiene
  Future<Either<Failure, List<HygieneCheck>>> getHygieneChecks({
    String? dormitoryId,
    String? gender,
  });
  Future<Either<Failure, void>> addHygieneCheck(HygieneCheck check);

  // Movements / Leave
  Future<Either<Failure, List<BoardingStudent>>> getStudentsOnLeave({
    String? gender,
  });
}

class BoardingDashboardData {
  final List<Dormitory> dormitories;
  final int totalStudents;
  final int studentsPresent;
  final int studentsOnLeave;
  final int activeDisciplineCases;
  final int pendingWelfareConcerns;

  const BoardingDashboardData({
    required this.dormitories,
    required this.totalStudents,
    required this.studentsPresent,
    required this.studentsOnLeave,
    required this.activeDisciplineCases,
    required this.pendingWelfareConcerns,
  });
}
