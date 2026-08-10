import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/finance/domain/usecases/initialize_student_financials.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_generator_service.dart';
import '../entities/admission_application.dart';
import '../entities/student.dart';
import '../entities/student_enums.dart';
import '../repositories/student_repository.dart';

class AdmissionService {
  final StudentRepository repository;
  final IdGeneratorService idGenerator;
  final StudentIdentityRepository identityRepository;
  final InitializeStudentFinancials? initializeFinancials;

  AdmissionService(
    this.repository, {
    required this.idGenerator,
    required this.identityRepository,
    this.initializeFinancials,
  });

  Future<Either<Failure, void>> submitApplication(
    AdmissionApplication application,
  ) {
    return repository.createAdmissionApplication(application);
  }

  /// Scoped name+DOB match against this school's existing applications -
  /// a review-step warning, not a hard block, since a genuine sibling or
  /// re-application can legitimately share both. Firestore can't fuzzy
  /// match, so this pulls the (small, per-school) application set and
  /// filters client-side.
  Future<Either<Failure, List<AdmissionApplication>>> checkForDuplicates(
    String schoolId,
    String studentName,
    DateTime dateOfBirth,
  ) async {
    final result = await repository.getApplications(schoolId);
    return result.fold(Left.new, (applications) {
      final normalizedName = studentName.trim().toLowerCase();
      final matches = applications.where((a) {
        final sameName = a.studentName.trim().toLowerCase() == normalizedName;
        final sameDob =
            a.dateOfBirth.year == dateOfBirth.year &&
            a.dateOfBirth.month == dateOfBirth.month &&
            a.dateOfBirth.day == dateOfBirth.day;
        return sameName && sameDob;
      }).toList();
      return Right(matches);
    });
  }

  Future<Either<Failure, List<AdmissionApplication>>> getPendingApplications(
    String schoolId,
  ) {
    return repository.getApplications(schoolId);
  }

  Future<Either<Failure, void>> reviewApplication(
    String applicationId, {
    required String reviewerId,
    required bool approve,
    String? comments,
  }) async {
    final status = approve
        ? AdmissionStatus.approved
        : AdmissionStatus.rejected;
    return repository.updateApplicationStatus(
      applicationId,
      status,
      reviewerId: reviewerId,
      comments: comments,
    );
  }

  /// Steps 1-3 of admission: mint the admission number and identity codes,
  /// then finalize the application into a Student record with status
  /// [StudentStatus.admitted]. Does not create the StudentIdentity or
  /// initialize finances - call [enrollStudent] next to complete those and
  /// transition the student to [StudentStatus.active].
  Future<Either<Failure, String>> admitStudent(
    String applicationId,
    String schoolId,
    String schoolCode,
    String academicYear,
    String academicYearId, {
    String? term,
    String? feeStructureId,
    double? totalBilled,
  }) async {
    // 1. Generate the legacy/sequential admission number.
    final numResult = await repository.generateAdmissionNumber(
      schoolId,
      academicYearId,
    );

    return numResult.fold((failure) => Left(failure), (admissionNumber) async {
      // 2. Mint the identity codes up front. finalizeAdmission needs a
      // studentCode as an *input* (the student doc doesn't exist yet), so
      // this can't wait for the Student.id that identityRepository would
      // otherwise generate against - reuse the admission sequence so the
      // human-friendly code and the admission number stay aligned.
      final sequenceNumber = _sequenceFrom(admissionNumber);
      final studentCode = idGenerator.generateSchoolStudentId(
        schoolPrefix: schoolCode,
        year: DateTime.now().year,
        sequenceNumber: sequenceNumber,
      );
      final uniqueSystemId = idGenerator.generateUniqueSystemId();

      // 3. Finalize admission with both codes. finalizeAdmission sets the
      // new Student's status to StudentStatus.admitted.
      final finalizeResult = await repository.finalizeAdmission(
        applicationId,
        studentCode: studentCode,
        admissionNumber: admissionNumber,
        qrReference: uniqueSystemId,
      );

      return finalizeResult.fold(
        (failure) => Left(failure),
        (studentId) => Right(studentId),
      );
    });
  }

  /// Steps 4-5 of admission: transitions an already-[StudentStatus.admitted]
  /// student to [StudentStatus.active], issues their StudentIdentity (QR
  /// data + NFC placeholder), and initializes finances if parameters are
  /// given. [uniqueSystemId] and [studentCode] must be the same codes
  /// [admitStudent] wrote to the student record, so identity and student
  /// data never drift apart.
  Future<Either<Failure, String>> enrollStudent(
    String studentId, {
    required String schoolId,
    required String uniqueSystemId,
    required String studentCode,
    String? academicYear,
    String? term,
    String? feeStructureId,
    double? totalBilled,
  }) async {
    final statusResult = await repository.updateStudentStatus(
      studentId,
      StudentStatus.active,
    );

    return statusResult.fold((failure) => Left(failure), (_) async {
      // generateStudentIdentity only reads id/schoolId off the student it's
      // given (codes are passed explicitly below) but needs the real
      // schoolId - Student.empty() would write an empty tenant scope onto
      // the identity record, breaking Firestore tenant isolation.
      final placeholderForIdentity = Student(
        id: studentId,
        schoolId: schoolId,
        name: '',
        studentCode: studentCode,
        admissionNumber: '',
        dateOfBirth: DateTime(2000),
        gender: Gender.male,
        classId: '',
        academicYearId: '',
        status: StudentStatus.active,
        level: EducationLevel.primary,
      );
      final identityResult = await identityRepository.generateStudentIdentity(
        placeholderForIdentity,
        uniqueSystemId: uniqueSystemId,
        schoolStudentId: studentCode,
      );

      return identityResult.fold((failure) => Left(failure), (_) async {
        if (initializeFinancials != null &&
            academicYear != null &&
            term != null &&
            feeStructureId != null &&
            totalBilled != null) {
          final financeResult = await initializeFinancials!(
            studentId: studentId,
            schoolId: schoolId,
            academicYear: academicYear,
            term: term,
            feeStructureId: feeStructureId,
            totalBilled: totalBilled,
          );
          return financeResult.fold(Left.new, (_) => Right(studentId));
        }
        return Right(studentId);
      });
    });
  }

  // Pulls the trailing sequence digits out of an admission number formatted
  // as "SP-2026-0001" so the school-facing studentCode uses the same
  // per-year sequence rather than a second, unrelated counter.
  int _sequenceFrom(String admissionNumber) {
    final match = RegExp(r'(\d+)$').firstMatch(admissionNumber);
    return match != null ? int.parse(match.group(1)!) : 1;
  }
}
