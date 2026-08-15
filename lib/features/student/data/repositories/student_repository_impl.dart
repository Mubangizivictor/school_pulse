import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../relationships/domain/repositories/relationship_repository.dart';
import '../../../teacher/domain/entities/homework.dart';
import '../../../matron/domain/entities/boarding_entities.dart';
import '../../../matron/data/sources/matron_remote_data_source.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';
import '../../domain/entities/parent_access_code.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_local_data_source.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/student_model.dart';
import '../models/admission_application_model.dart';
import '../models/parent_access_code_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;
  final StudentLocalDataSource localDataSource;
  final MatronRemoteDataSource matronRemoteDataSource;
  final RelationshipRepository relationshipRepository;
  final NetworkInfo networkInfo;

  StudentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.matronRemoteDataSource,
    required this.relationshipRepository,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Student>> getStudentById(String studentId) async {
    try {
      if (await networkInfo.isConnected) {
        final student = await remoteDataSource.getStudentById(studentId);
        await localDataSource.cacheStudent(student);
        return Right(student);
      }
      final cached = await localDataSource.getCachedStudent(studentId);
      if (cached == null) {
        return Left(CacheFailure('Student not found offline.'));
      }
      return Right(cached);
    } catch (e) {
      final cached = await localDataSource.getCachedStudent(studentId);
      if (cached != null) return Right(cached);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getAllStudents({
    String? schoolId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final students = await remoteDataSource.getAllStudents(
          schoolId: schoolId,
        );
        if (schoolId != null && schoolId.isNotEmpty) {
          await localDataSource.cacheStudents(students);
        }
        return Right(students);
      }
      if (schoolId == null || schoolId.isEmpty) {
        return const Left(
          OfflineNotAllowedFailure(
            'School context required to read cached students offline.',
          ),
        );
      }
      final cached = await localDataSource.getCachedStudents(schoolId);
      return Right(cached);
    } catch (e) {
      if (schoolId != null && schoolId.isNotEmpty) {
        final cached = await localDataSource.getCachedStudents(schoolId);
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsByIds(
    List<String> ids,
  ) async {
    try {
      return Right(await remoteDataSource.getStudentsByIds(ids));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createStudent(
    Student student, {
    required String recordedBy,
  }) async {
    try {
      final model = StudentModel(
        id: student.id,
        schoolId: student.schoolId,
        name: student.name,
        photoUrl: student.photoUrl,
        studentCode: student.studentCode,
        admissionNumber: student.admissionNumber,
        qrReference: student.qrReference,
        dateOfBirth: student.dateOfBirth,
        gender: student.gender,
        classId: student.classId,
        streamId: student.streamId,
        academicYearId: student.academicYearId,
        previousSchool: student.previousSchool,
        status: student.status,
        medicalInfo: student.medicalInfo,
        emergencyContacts: student.emergencyContacts,
        parentIds: student.parentIds,
        documents: student.documents,
        campusId: student.campusId,
        level: student.level,
        dormLeadershipRole: student.dormLeadershipRole,
        dormLeadershipDormId: student.dormLeadershipDormId,
        dormLeadershipDormName: student.dormLeadershipDormName,
      );
      final studentId = await remoteDataSource.createStudent(
        model,
        recordedBy: recordedBy,
      );
      final created = model.copyWithModelId(studentId);
      await localDataSource.cacheStudent(created);
      return Right(studentId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> searchStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? parentPhone,
    String? classId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final students = await remoteDataSource.searchStudents(
          schoolId: schoolId,
          query: query,
          admissionNumber: admissionNumber,
          parentPhone: parentPhone,
          classId: classId,
        );
        return Right(students);
      }
      // Offline: the parentPhone filter needs parent_access_codes, which
      // isn't cached locally, so it's silently ignored here rather than
      // failing the whole search - name/admissionNumber/classId still work.
      final cached = await localDataSource.searchCachedStudents(
        schoolId: schoolId,
        query: query,
        admissionNumber: admissionNumber,
        classId: classId,
      );
      return Right(cached);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudent(
    Student student, {
    required String recordedBy,
  }) async {
    try {
      final before = await remoteDataSource.getStudentById(student.id);
      final model = StudentModel(
        id: student.id,
        schoolId: student.schoolId,
        name: student.name,
        photoUrl: student.photoUrl,
        studentCode: student.studentCode,
        admissionNumber: student.admissionNumber,
        qrReference: student.qrReference,
        dateOfBirth: student.dateOfBirth,
        gender: student.gender,
        classId: student.classId,
        streamId: student.streamId,
        academicYearId: student.academicYearId,
        previousSchool: student.previousSchool,
        status: student.status,
        medicalInfo: student.medicalInfo,
        emergencyContacts: student.emergencyContacts,
        parentIds: student.parentIds,
        documents: student.documents,
        campusId: student.campusId,
        level: student.level,
      );
      await remoteDataSource.updateStudent(model);
      await localDataSource.cacheStudent(model);

      final placementChanged =
          before.classId != student.classId ||
          before.streamId != student.streamId ||
          before.academicYearId != student.academicYearId;
      if (placementChanged) {
        await relationshipRepository.recordEnrolmentChange(
          schoolId: student.schoolId,
          studentId: student.id,
          classId: student.classId,
          streamId: student.streamId,
          academicYearId: student.academicYearId,
          recordedBy: recordedBy,
          reason: 'correction',
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentStatus(
    String studentId,
    StudentStatus status,
  ) async {
    try {
      await remoteDataSource.updateStudentStatus(studentId, status.name);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAdmissionApplication(
    AdmissionApplication application,
  ) async {
    try {
      final model = AdmissionApplicationModel(
        id: application.id,
        schoolId: application.schoolId,
        studentName: application.studentName,
        dateOfBirth: application.dateOfBirth,
        gender: application.gender,
        targetClassId: application.targetClassId,
        targetStreamId: application.targetStreamId,
        academicYearId: application.academicYearId,
        previousSchool: application.previousSchool,
        applicantParentName: application.applicantParentName,
        applicantParentPhone: application.applicantParentPhone,
        status: application.status,
        appliedAt: application.appliedAt,
        attachedDocuments: application.attachedDocuments,
      );
      await remoteDataSource.createAdmissionApplication(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdmissionApplication>>> getApplications(
    String schoolId,
  ) async {
    try {
      final applications = await remoteDataSource.getApplications(schoolId);
      return Right(applications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateApplicationStatus(
    String applicationId,
    AdmissionStatus status, {
    String? reviewerId,
    String? comments,
  }) async {
    try {
      await remoteDataSource.updateApplicationStatus(
        applicationId,
        status.name,
        reviewerId: reviewerId,
        comments: comments,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateAdmissionNumber(
    String schoolId,
    String academicYearId,
  ) async {
    try {
      final sequence = await remoteDataSource.getNextSequenceNumber(
        schoolId,
        academicYearId,
      );
      // Format: SCH-YEAR-0001
      final yearShort = academicYearId
          .split('-')
          .last; // Assuming year ID contains year info
      final admissionNumber =
          "SP-$yearShort-${sequence.toString().padLeft(4, '0')}";
      return Right(admissionNumber);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> finalizeAdmission(
    String applicationId, {
    required String studentCode,
    required String admissionNumber,
    String? qrReference,
  }) async {
    try {
      // Fetch through an explicitly tenant-scoped path. The old empty-scope
      // list query could never find an application and was unsafe by design.
      final application = await remoteDataSource.getApplicationById(
        applicationId,
      );

      // 2. Create Student Model with Identity System Codes
      final student = StudentModel(
        id: '', // Firestore will generate
        schoolId: application.schoolId,
        name: application.studentName,
        studentCode: studentCode,
        admissionNumber: admissionNumber,
        qrReference: qrReference,
        dateOfBirth: application.dateOfBirth,
        gender: application.gender,
        classId: application.targetClassId,
        streamId: application.targetStreamId,
        academicYearId: application.academicYearId,
        previousSchool: application.previousSchool,
        status: StudentStatus.admitted,
        level: EducationLevel.primary,
        documents: application.attachedDocuments,
      );

      final studentId = await remoteDataSource.finalizeAdmission(
        application,
        student,
      );
      return Right(studentId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadStudentDocument(
    String studentId,
    String type,
    dynamic file,
  ) async {
    try {
      final url = await remoteDataSource.uploadDocument(studentId, type, file);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudentDocument(
    String studentId,
    String type,
  ) async {
    try {
      await remoteDataSource.deleteDocument(studentId, type);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> promoteStudents({
    required String schoolId,
    required List<String> studentIds,
    required String targetClassId,
    String? targetStreamId,
    required String targetAcademicYearId,
    required String recordedBy,
  }) async {
    try {
      List<StudentModel> updatedStudents = [];
      for (var id in studentIds) {
        final student = await remoteDataSource.getStudentById(id);
        // Student.copyWith() returns a plain Student, not a StudentModel
        // (StudentModel doesn't override it) - build the model explicitly
        // rather than casting, which always failed at runtime.
        final updated = student.copyWith(
          classId: targetClassId,
          streamId: targetStreamId,
          academicYearId: targetAcademicYearId,
        );
        updatedStudents.add(
          StudentModel(
            id: updated.id,
            schoolId: updated.schoolId,
            name: updated.name,
            photoUrl: updated.photoUrl,
            studentCode: updated.studentCode,
            admissionNumber: updated.admissionNumber,
            qrReference: updated.qrReference,
            dateOfBirth: updated.dateOfBirth,
            gender: updated.gender,
            classId: updated.classId,
            streamId: updated.streamId,
            academicYearId: updated.academicYearId,
            previousSchool: updated.previousSchool,
            status: updated.status,
            medicalInfo: updated.medicalInfo,
            emergencyContacts: updated.emergencyContacts,
            parentIds: updated.parentIds,
            documents: updated.documents,
            campusId: updated.campusId,
            level: updated.level,
            dormLeadershipRole: updated.dormLeadershipRole,
            dormLeadershipDormId: updated.dormLeadershipDormId,
            dormLeadershipDormName: updated.dormLeadershipDormName,
          ),
        );
      }
      await remoteDataSource.batchUpdateStudents(updatedStudents);

      for (final id in studentIds) {
        await relationshipRepository.recordEnrolmentChange(
          schoolId: schoolId,
          studentId: id,
          classId: targetClassId,
          streamId: targetStreamId,
          academicYearId: targetAcademicYearId,
          recordedBy: recordedBy,
          reason: 'promotion',
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParentAccessCode>>> getAllAccessCodes({
    String? schoolId,
  }) async {
    try {
      return Right(
        await remoteDataSource.getAllAccessCodes(schoolId: schoolId),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createAccessCode({
    required List<String> studentIds,
    required String schoolId,
    required String phoneNumber,
    String? parentName,
  }) async {
    try {
      final code = await remoteDataSource.createAccessCode(
        studentIds: studentIds,
        schoolId: schoolId,
        phoneNumber: phoneNumber,
        parentName: parentName,
      );
      return Right(code);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> regenerateAccessCode(String oldCode) async {
    try {
      final newCode = await remoteDataSource.regenerateAccessCode(oldCode);
      return Right(newCode);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAccessCodeStatus(
    String code,
    bool isActive, {
    String? reason,
  }) async {
    try {
      await remoteDataSource.toggleAccessCodeStatus(
        code,
        isActive,
        reason: reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccessCode(String code) async {
    try {
      await remoteDataSource.deleteAccessCode(code);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAccessCode(ParentAccessCode code) async {
    try {
      final model = ParentAccessCodeModel(
        id: code.id,
        parentCode: code.parentCode,
        schoolId: code.schoolId,
        studentIds: code.studentIds,
        studentNames: code.studentNames,
        parentName: code.parentName,
        phoneNumber: code.phoneNumber,
        pin: code.pin,
        mustChangePin: code.mustChangePin,
        isActive: code.isActive,
        deactivationReason: code.deactivationReason,
      );
      await remoteDataSource.updateAccessCode(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParentAccessCode>> resolveAccessCode(
    String code,
  ) async {
    try {
      final accessCode = await remoteDataSource.resolveAccessCode(code);
      if (accessCode == null) {
        return Left(ServerFailure('No account found with this code.'));
      }
      return Right(accessCode);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Homework>>> getHomeworkForStudent(
    String schoolId,
    String className,
  ) async {
    try {
      final homework = await remoteDataSource.getHomeworkForStudent(
        schoolId,
        className,
      );
      return Right(homework);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WelfareRecord>>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    bool publicOnly = false,
  }) async {
    try {
      final records = await matronRemoteDataSource.getWelfareRecords(
        schoolId: schoolId,
        studentId: studentId,
        publicOnly: publicOnly,
      );
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DisciplineCase>>> getDisciplineCases({
    String? studentId,
  }) async {
    try {
      final cases = await matronRemoteDataSource.getDisciplineCases(
        studentId: studentId,
      );
      return Right(cases);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
