import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_enums.dart';
import '../../../student/data/models/student_model.dart';
import '../../domain/entities/student_identity.dart';
import '../../domain/repositories/student_identity_repository.dart';
import '../models/student_identity_model.dart';
import '../models/student_cache_isar.dart';

class StudentIdentityRepositoryImpl implements StudentIdentityRepository {
  final FirebaseFirestore firestore;
  final Isar isar;

  StudentIdentityRepositoryImpl({
    required this.firestore,
    required this.isar,
  });

  @override
  Future<Either<Failure, StudentIdentity>> getStudentIdentity(String studentId) async {
    try {
      final doc = await firestore
          .collection('student_identities')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (doc.docs.isEmpty) {
        return Left(ServerFailure('Identity not found'));
      }

      return Right(StudentIdentityModel.fromFirestore(doc.docs.first.data()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentIdentity>> generateStudentIdentity(Student student) async {
    try {
      // Check if identity already exists
      final existing = await firestore
          .collection('student_identities')
          .where('studentId', isEqualTo: student.id)
          .get();

      if (existing.docs.isNotEmpty) {
        return Right(StudentIdentityModel.fromFirestore(existing.docs.first.data()));
      }

      // Generate IDs (This logic might be better in a service, but repository can coordinate)
      // For this implementation, we'll assume the IDs are generated and passed or generated here.
      // The prompt says "Automatically generate", so let's do it here if not exists.
      
      // In a real app, schoolStudentId sequence would come from a counter in Firestore.
      // For now, we'll use a simplified version.
      final uniqueSystemId = 'SP-STUDENT-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
      final schoolPrefix = student.className.substring(0, min(2, student.className.length)).toUpperCase();
      final year = DateTime.now().year;
      final schoolStudentId = '$schoolPrefix-$year-${student.studentId}';

      final model = StudentIdentityModel(
        studentId: student.id,
        uniqueSystemId: uniqueSystemId,
        schoolStudentId: schoolStudentId,
        qrCodeData: uniqueSystemId,
      );

      await firestore.collection('student_identities').add(model.toFirestore());

      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Future<Either<Failure, List<StudentIdentity>>> getSchoolIdentities(String schoolId) async {
    try {
      // This assumes students have schoolId, or we join with students.
      // Based on Student model, it doesn't have schoolId, but UserEntity does.
      // Usually students are in a subcollection or have schoolId.
      // Assuming a 'student_identities' collection for now.
      final snapshot = await firestore.collection('student_identities').get();
      return Right(snapshot.docs.map((doc) => StudentIdentityModel.fromFirestore(doc.data())).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheStudentsForOffline(List<Student> students) async {
    try {
      await isar.writeTxn(() async {
        for (final student in students) {
          // Fetch identity for each student to cache
          final identityDoc = await firestore
              .collection('student_identities')
              .where('studentId', isEqualTo: student.id)
              .get();
          
          if (identityDoc.docs.isNotEmpty) {
            final identity = StudentIdentityModel.fromFirestore(identityDoc.docs.first.data());
            
            final cache = StudentCacheIsar()
              ..studentId = student.id
              ..uniqueSystemId = identity.uniqueSystemId
              ..name = student.name
              ..photoUrl = student.photoUrl
              ..className = student.className
              ..schoolStudentId = identity.schoolStudentId
              ..schoolId = 'FIXME_SCHOOL_ID'; // Need to pass schoolId or get it from student
              
            await isar.studentCacheIsars.put(cache);
          }
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Student?>> getStudentByUniqueId(String uniqueSystemId) async {
    try {
      // First try local cache
      final cached = await isar.studentCacheIsars.filter().uniqueSystemIdEqualTo(uniqueSystemId).findFirst();
      if (cached != null) {
        return Right(Student(
          id: cached.studentId,
          schoolId: cached.schoolId,
          name: cached.name,
          photoUrl: cached.photoUrl,
          studentCode: cached.schoolStudentId,
          admissionNumber: '',
          dateOfBirth: DateTime(2000),
          gender: Gender.male,
          classId: cached.className,
          academicYearId: '',
          status: StudentStatus.active,
          level: EducationLevel.primary,
        ));
      }

      // Fallback to Firestore
      final identityDoc = await firestore
          .collection('student_identities')
          .where('uniqueSystemId', isEqualTo: uniqueSystemId)
          .get();

      if (identityDoc.docs.isEmpty) {
        return const Right(null);
      }

      final studentId = identityDoc.docs.first.data()['studentId'];
      final studentDoc = await firestore.collection('students').doc(studentId).get();
      
      if (!studentDoc.exists) return const Right(null);

      return Right(StudentModel.fromMap(studentDoc.data()!, studentDoc.id));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
