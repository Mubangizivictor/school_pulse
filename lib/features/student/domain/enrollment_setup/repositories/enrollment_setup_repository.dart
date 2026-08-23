import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/scholarship_award.dart';
import '../entities/dormitory_assignment.dart';
import '../entities/student_club_membership.dart';

/// A bed already carries an assignment - surfaced instead of silently
/// overwriting the previous occupant's record.
class BedAlreadyAssignedFailure extends Failure {
  const BedAlreadyAssignedFailure()
    : super('This bed is already assigned to another student.');
}

/// Repository for the new master data this wizard introduces:
/// scholarship awards, dormitory bed assignments and club memberships.
/// Deliberately separate from [StructureRepository]/[FinanceRepository] -
/// those own master data (fee structures, hostels, clubs); this owns the
/// per-student assignment records against that master data.
abstract class EnrollmentSetupRepository {
  // Scholarship awards -------------------------------------------------
  Future<Either<Failure, List<ScholarshipAward>>> getScholarshipAwards(
    String schoolId,
    String studentId,
  );

  /// Creates a new award. Callers must verify
  /// `Permission.enrollmentBursaryAssign` before calling this for any
  /// [ScholarshipAward.type] other than [ScholarshipAwardType.none] - this
  /// method itself performs no permission check, matching the pattern used
  /// by every other repository in the codebase (enforcement lives in the
  /// bloc/service layer, mirroring AdmissionBloc).
  Future<Either<Failure, ScholarshipAward>> createScholarshipAward(
    ScholarshipAward award,
  );

  // Dormitory assignments -----------------------------------------------
  Future<Either<Failure, DormitoryAssignment?>> findBedAssignment({
    required String schoolId,
    required String hostelId,
    required String roomId,
    required String bed,
  });

  Future<Either<Failure, DormitoryAssignment?>> getDormitoryAssignment(
    String schoolId,
    String studentId,
  );

  /// Fails with [BedAlreadyAssignedFailure] if the bed is already taken -
  /// checks via [findBedAssignment] internally before writing.
  Future<Either<Failure, DormitoryAssignment>> assignDormitory(
    DormitoryAssignment assignment,
  );

  /// Occupied bed count per room id, for every room in [hostelId] - used to
  /// show "2/6 beds free" in the Boarding step's room picker.
  Stream<Map<String, int>> watchOccupiedBedCounts(
    String schoolId,
    String hostelId,
  );

  // Club memberships -----------------------------------------------------
  Future<Either<Failure, List<StudentClubMembership>>> getClubMemberships(
    String schoolId,
    String studentId,
  );

  /// Idempotent: if the student already has an active membership for
  /// [membership.clubId], returns the existing record rather than
  /// creating a duplicate.
  Future<Either<Failure, StudentClubMembership>> joinClub(
    StudentClubMembership membership,
  );
}
