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

  Future<Either<Failure, void>> submitApplication(AdmissionApplication application) {
    return repository.createAdmissionApplication(application);
  }

  Future<Either<Failure, List<AdmissionApplication>>> getPendingApplications(String schoolId) {
    return repository.getApplications(schoolId);
  }

  Future<Either<Failure, void>> reviewApplication(
    String applicationId, {
    required String reviewerId,
    required bool approve,
    String? comments,
  }) async {
    final status = approve ? AdmissionStatus.approved : AdmissionStatus.rejected;
    return repository.updateApplicationStatus(
      applicationId,
      status,
      reviewerId: reviewerId,
      comments: comments,
    );
  }

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
    final numResult = await repository.generateAdmissionNumber(schoolId, academicYearId);

    return numResult.fold(
      (failure) => Left(failure),
      (admissionNumber) async {
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

        // 3. Finalize admission with both codes.
        final finalizeResult = await repository.finalizeAdmission(
          applicationId,
          studentCode: studentCode,
          admissionNumber: admissionNumber,
          qrReference: uniqueSystemId,
        );

        return finalizeResult.fold(
          (failure) => Left(failure),
          (studentId) async {
            // 4. Persist the StudentIdentity record (QR data + NFC
            // placeholder) using the same codes just written to the student
            // record, so the two never drift apart.
            final identityResult = await identityRepository.generateStudentIdentity(
              Student.empty(studentId),
              uniqueSystemId: uniqueSystemId,
              schoolStudentId: studentCode,
            );

            return identityResult.fold(
              (failure) => Left(failure),
              (_) async {
                // 5. Initialize the financial account if financial
                // parameters were provided.
                if (initializeFinancials != null &&
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
              },
            );
          },
        );
      },
    );
  }

  // Pulls the trailing sequence digits out of an admission number formatted
  // as "SP-2026-0001" so the school-facing studentCode uses the same
  // per-year sequence rather than a second, unrelated counter.
  int _sequenceFrom(String admissionNumber) {
    final match = RegExp(r'(\d+)$').firstMatch(admissionNumber);
    return match != null ? int.parse(match.group(1)!) : 1;
  }
}
