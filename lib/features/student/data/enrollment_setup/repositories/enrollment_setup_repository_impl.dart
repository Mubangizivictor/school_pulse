import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/dormitory_assignment.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/student_club_membership.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/repositories/enrollment_setup_repository.dart';

class EnrollmentSetupRepositoryImpl implements EnrollmentSetupRepository {
  final FirebaseFirestore firestore;

  EnrollmentSetupRepositoryImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _scholarships =>
      firestore.collection('scholarship_awards');
  CollectionReference<Map<String, dynamic>> get _dormitoryAssignments =>
      firestore.collection('dormitory_assignments');
  CollectionReference<Map<String, dynamic>> get _clubMemberships =>
      firestore.collection('student_club_memberships');

  ScholarshipAward _awardFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ScholarshipAward(
      id: doc.id,
      schoolId: data['schoolId'] as String,
      studentId: data['studentId'] as String,
      type: ScholarshipAwardType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ScholarshipAwardType.none,
      ),
      amountOrPercentage: (data['amountOrPercentage'] as num).toDouble(),
      isPercentage: data['isPercentage'] as bool? ?? false,
      effectiveStart: (data['effectiveStart'] as Timestamp).toDate(),
      effectiveEnd: (data['effectiveEnd'] as Timestamp?)?.toDate(),
      approvedBy: data['approvedBy'] as String,
      reason: data['reason'] as String? ?? '',
      supportingDocumentUrl: data['supportingDocumentUrl'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, List<ScholarshipAward>>> getScholarshipAwards(
    String schoolId,
    String studentId,
  ) async {
    try {
      final snap = await _scholarships
          .where('schoolId', isEqualTo: schoolId)
          .where('studentId', isEqualTo: studentId)
          .get();
      return Right(snap.docs.map(_awardFromDoc).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ScholarshipAward>> createScholarshipAward(
    ScholarshipAward award,
  ) async {
    try {
      final doc = _scholarships.doc();
      final data = {
        'schoolId': award.schoolId,
        'studentId': award.studentId,
        'type': award.type.name,
        'amountOrPercentage': award.amountOrPercentage,
        'isPercentage': award.isPercentage,
        'effectiveStart': Timestamp.fromDate(award.effectiveStart),
        'effectiveEnd': award.effectiveEnd != null
            ? Timestamp.fromDate(award.effectiveEnd!)
            : null,
        'approvedBy': award.approvedBy,
        'reason': award.reason,
        'supportingDocumentUrl': award.supportingDocumentUrl,
        'createdAt': Timestamp.now(),
      };
      await doc.set(data);
      final saved = await doc.get();
      return Right(_awardFromDoc(saved));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  DormitoryAssignment _dormFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DormitoryAssignment(
      id: doc.id,
      studentId: data['studentId'] as String,
      schoolId: data['schoolId'] as String,
      hostelId: data['hostelId'] as String,
      roomId: data['roomId'] as String,
      bed: data['bed'] as String,
      assignedAt:
          (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedBy: data['assignedBy'] as String,
    );
  }

  @override
  Future<Either<Failure, DormitoryAssignment?>> findBedAssignment({
    required String schoolId,
    required String hostelId,
    required String roomId,
    required String bed,
  }) async {
    try {
      final snap = await _dormitoryAssignments
          .where('schoolId', isEqualTo: schoolId)
          .where('hostelId', isEqualTo: hostelId)
          .where('roomId', isEqualTo: roomId)
          .where('bed', isEqualTo: bed)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return const Right(null);
      return Right(_dormFromDoc(snap.docs.first));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DormitoryAssignment?>> getDormitoryAssignment(
    String schoolId,
    String studentId,
  ) async {
    try {
      final snap = await _dormitoryAssignments
          .where('schoolId', isEqualTo: schoolId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return const Right(null);
      return Right(_dormFromDoc(snap.docs.first));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DormitoryAssignment>> assignDormitory(
    DormitoryAssignment assignment,
  ) async {
    try {
      final existingResult = await findBedAssignment(
        schoolId: assignment.schoolId,
        hostelId: assignment.hostelId,
        roomId: assignment.roomId,
        bed: assignment.bed,
      );
      final failure = existingResult.fold((f) => f, (_) => null);
      if (failure != null) return Left(failure);
      final existing = existingResult.fold((_) => null, (a) => a);
      if (existing != null && existing.studentId != assignment.studentId) {
        return const Left(BedAlreadyAssignedFailure());
      }
      if (existing != null && existing.studentId == assignment.studentId) {
        // Idempotent retry: same student already holds this exact bed.
        return Right(existing);
      }

      final doc = _dormitoryAssignments.doc();
      final data = {
        'studentId': assignment.studentId,
        'schoolId': assignment.schoolId,
        'hostelId': assignment.hostelId,
        'roomId': assignment.roomId,
        'bed': assignment.bed,
        'assignedAt': Timestamp.now(),
        'assignedBy': assignment.assignedBy,
      };
      await doc.set(data);
      final saved = await doc.get();
      return Right(_dormFromDoc(saved));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  StudentClubMembership _clubFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return StudentClubMembership(
      id: doc.id,
      studentId: data['studentId'] as String,
      schoolId: data['schoolId'] as String,
      clubId: data['clubId'] as String,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ClubMembershipStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ClubMembershipStatus.active,
      ),
    );
  }

  @override
  Future<Either<Failure, List<StudentClubMembership>>> getClubMemberships(
    String schoolId,
    String studentId,
  ) async {
    try {
      final snap = await _clubMemberships
          .where('schoolId', isEqualTo: schoolId)
          .where('studentId', isEqualTo: studentId)
          .get();
      return Right(snap.docs.map(_clubFromDoc).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentClubMembership>> joinClub(
    StudentClubMembership membership,
  ) async {
    try {
      final existingSnap = await _clubMemberships
          .where('schoolId', isEqualTo: membership.schoolId)
          .where('studentId', isEqualTo: membership.studentId)
          .where('clubId', isEqualTo: membership.clubId)
          .where('status', isEqualTo: ClubMembershipStatus.active.name)
          .limit(1)
          .get();
      if (existingSnap.docs.isNotEmpty) {
        return Right(_clubFromDoc(existingSnap.docs.first));
      }

      final doc = _clubMemberships.doc();
      final data = {
        'studentId': membership.studentId,
        'schoolId': membership.schoolId,
        'clubId': membership.clubId,
        'joinedAt': Timestamp.now(),
        'status': ClubMembershipStatus.active.name,
      };
      await doc.set(data);
      final saved = await doc.get();
      return Right(_clubFromDoc(saved));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
