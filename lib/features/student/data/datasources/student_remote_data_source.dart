import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../teacher/domain/entities/homework.dart';
import '../models/student_model.dart';
import '../models/admission_application_model.dart';
import '../models/parent_access_code_model.dart';
import '../models/student_access_code_model.dart';

// Excludes visually-ambiguous characters (0/O, 1/I/L) since these codes are
// read aloud/typed by parents and students on a phone keypad.
const _accessCodeAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
final _accessCodeRandom = Random.secure();

/// Generates a school-issued access code that is unguessable (unlike the
/// previous scheme of a fixed prefix + trailing epoch-millis digits, which
/// was sequential and predictable) and free of characters that are easily
/// confused when read aloud or hand-copied.
String _generateAccessCode({required String prefix, int length = 8}) {
  final suffix = String.fromCharCodes(
    List.generate(
      length,
      (_) => _accessCodeAlphabet.codeUnitAt(
        _accessCodeRandom.nextInt(_accessCodeAlphabet.length),
      ),
    ),
  );
  return '$prefix$suffix';
}

/// Thrown when createStudentWithCapacityCheck rejects a create because the
/// school has reached its plan's maxStudents limit, so callers can show a
/// clear upgrade message instead of a generic Firestore/network error.
class StudentCapacityExceededException implements Exception {
  const StudentCapacityExceededException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// student.toMap() is written for direct Firestore writes and includes a
/// raw Timestamp for dateOfBirth, which cloud_functions callables cannot
/// serialize over the wire (mirrors the ISO-string convention
/// AuthRemoteDataSourceImpl already uses for createStaffAccount's
/// dateJoined). StudentModel.fromMap() already accepts either a Timestamp
/// or an ISO string, so the server side converts this back before writing.
Map<String, dynamic> _studentPayloadForCallable(StudentModel student) {
  final map = student.toMap();
  final dateOfBirth = map['dateOfBirth'];
  if (dateOfBirth is Timestamp) {
    map['dateOfBirth'] = dateOfBirth.toDate().toIso8601String();
  }
  return map;
}

abstract class StudentRemoteDataSource {
  // Student Management
  Future<StudentModel> getStudentById(String studentId);
  Future<List<StudentModel>> getAllStudents({String? schoolId});
  Future<List<StudentModel>> searchStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? parentPhone,
    String? classId,
  });
  Future<String> createStudent(StudentModel student, {String? recordedBy});
  Future<void> updateStudent(StudentModel student);
  Future<void> updateStudentStatus(String studentId, String status);
  Future<void> batchUpdateStudents(List<StudentModel> students);

  // Admission Workflow
  Future<void> createAdmissionApplication(
    AdmissionApplicationModel application,
  );
  Future<List<AdmissionApplicationModel>> getApplications(String schoolId);
  Future<AdmissionApplicationModel> getApplicationById(String applicationId);
  Future<void> updateApplicationStatus(
    String applicationId,
    String status, {
    String? reviewerId,
    String? comments,
  });
  Future<int> getNextSequenceNumber(String schoolId, String academicYearId);
  Future<String> finalizeAdmission(
    AdmissionApplicationModel application,
    StudentModel student, {
    String? recordedBy,
  });

  // Document Management
  Future<String> uploadDocument(String studentId, String type, dynamic file);
  Future<void> deleteDocument(String studentId, String type);

  // Existing Parent Access Code Methods (Keep as is)
  Future<List<StudentModel>> getStudentsByIds(List<String> ids);
  Future<ParentAccessCodeModel?> resolveAccessCode(String code);
  Future<List<ParentAccessCodeModel>> getAllAccessCodes({String? schoolId});
  Future<String> createAccessCode({
    required List<String> studentIds,
    required String schoolId,
    required String phoneNumber,
    String? parentName,
  });
  Future<String> regenerateAccessCode(String oldCode);
  Future<void> toggleAccessCodeStatus(
    String code,
    bool isActive, {
    String? reason,
  });
  Future<void> updateAccessCode(ParentAccessCodeModel code);
  Future<void> deleteAccessCode(String code);

  // Homework
  Future<List<Homework>> getHomeworkForStudent(
    String schoolId,
    String className,
  );

  // Student Portal Access Codes
  Future<String> provisionStudentAccessCode(String studentId);
  Future<void> resetStudentPin(String code);
  Future<void> setStudentAccessCodeStatus(
    String code,
    bool isActive, {
    String? reason,
  });
  Future<StudentAccessCodeModel?> getStudentAccessCode(String studentId);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseFunctions functions;

  StudentRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.functions,
  });

  @override
  Future<StudentModel> getStudentById(String studentId) async {
    final doc = await firestore.collection('students').doc(studentId).get();
    if (!doc.exists) throw Exception('Student not found');
    return StudentModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<StudentModel>> getAllStudents({String? schoolId}) async {
    Query<Map<String, dynamic>> query = firestore.collection('students');
    if (schoolId != null && schoolId.isNotEmpty) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<StudentModel>> searchStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? parentPhone,
    String? classId,
  }) async {
    Query q = firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId);

    if (admissionNumber != null && admissionNumber.isNotEmpty) {
      q = q.where('studentCode', isEqualTo: admissionNumber);
    }
    if (classId != null && classId.isNotEmpty) {
      q = q.where('classId', isEqualTo: classId);
    }

    final snapshot = await q.get();
    var students = snapshot.docs
        .map(
          (doc) =>
              StudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    if (parentPhone != null && parentPhone.isNotEmpty) {
      final codesSnapshot = await firestore
          .collection('parent_access_codes')
          .where('schoolId', isEqualTo: schoolId)
          .where('phoneNumber', isEqualTo: parentPhone)
          .get();

      final studentIds = codesSnapshot.docs
          .expand((doc) => List<String>.from(doc.data()['studentIds'] ?? []))
          .toSet();

      students = students.where((s) => studentIds.contains(s.id)).toList();
    }

    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      students = students
          .where(
            (s) =>
                s.name.toLowerCase().contains(lowerQuery) ||
                s.studentCode.toLowerCase().contains(lowerQuery) ||
                s.admissionNumber.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }

    return students;
  }

  @override
  Future<String> createStudent(
    StudentModel student, {
    String? recordedBy,
  }) async {
    try {
      final callable = functions.httpsCallable(
        'createStudentWithCapacityCheck',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'student': _studentPayloadForCallable(student),
        'recordedBy': recordedBy,
      });
      return result.data['studentId'] as String;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        throw StudentCapacityExceededException(
          e.message ?? 'This school has reached its student limit.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updateStudent(StudentModel student) async {
    await firestore
        .collection('students')
        .doc(student.id)
        .set(student.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateStudentStatus(String studentId, String status) async {
    final callable = functions.httpsCallable(
      'updateStudentStatusWithCapacityAdjustment',
    );
    await callable.call<Map<String, dynamic>>({
      'studentId': studentId,
      'status': status,
    });
  }

  @override
  Future<void> batchUpdateStudents(List<StudentModel> students) async {
    final batch = firestore.batch();
    for (var student in students) {
      batch.set(
        firestore.collection('students').doc(student.id),
        student.toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  @override
  Future<void> createAdmissionApplication(
    AdmissionApplicationModel application,
  ) async {
    await firestore
        .collection('admission_applications')
        .doc(application.id.isEmpty ? null : application.id)
        .set(application.toMap());
  }

  @override
  Future<List<AdmissionApplicationModel>> getApplications(
    String schoolId,
  ) async {
    final snapshot = await firestore
        .collection('admission_applications')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('appliedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AdmissionApplicationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<AdmissionApplicationModel> getApplicationById(
    String applicationId,
  ) async {
    final snapshot = await firestore
        .collection('admission_applications')
        .doc(applicationId)
        .get();
    if (!snapshot.exists) {
      throw StateError('Admission application not found.');
    }
    return AdmissionApplicationModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    String status, {
    String? reviewerId,
    String? comments,
  }) async {
    await firestore
        .collection('admission_applications')
        .doc(applicationId)
        .update({
          'status': status,
          'reviewerId': reviewerId,
          'reviewComments': comments,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<int> getNextSequenceNumber(
    String schoolId,
    String academicYearId,
  ) async {
    final docRef = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('counters')
        .doc('admission_$academicYearId');

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'count': 1});
        return 1;
      }
      final newCount = (snapshot.data()?['count'] as int? ?? 0) + 1;
      transaction.update(docRef, {'count': newCount});
      return newCount;
    });
  }

  @override
  Future<String> finalizeAdmission(
    AdmissionApplicationModel application,
    StudentModel student, {
    String? recordedBy,
  }) async {
    try {
      final callable = functions.httpsCallable(
        'createStudentWithCapacityCheck',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'student': _studentPayloadForCallable(student),
        'recordedBy': recordedBy ?? application.reviewerId,
        'application': {'id': application.id, 'schoolId': student.schoolId},
      });
      return result.data['studentId'] as String;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        throw StudentCapacityExceededException(
          e.message ?? 'This school has reached its student limit.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<String> uploadDocument(
    String studentId,
    String type,
    dynamic file,
  ) async {
    final ref = storage.ref().child(
      'schools/students/$studentId/documents/$type',
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteDocument(String studentId, String type) async {
    final ref = storage.ref().child(
      'schools/students/$studentId/documents/$type',
    );
    await ref.delete();
  }

  // --- Existing Parent Access Code Implementation (Relocated/Maintained) ---

  @override
  Future<List<StudentModel>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final docs = await Future.wait(
      ids.map((id) => firestore.collection('students').doc(id).get()),
    );
    return docs
        .where((doc) => doc.exists)
        .map((doc) => StudentModel.fromMap(doc.data()!, doc.id))
        .toList();
  }

  @override
  Future<ParentAccessCodeModel?> resolveAccessCode(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    final doc = await firestore
        .collection('parent_access_codes')
        .doc(normalizedCode)
        .get();
    if (!doc.exists) return null;
    return ParentAccessCodeModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<List<ParentAccessCodeModel>> getAllAccessCodes({
    String? schoolId,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection(
      'parent_access_codes',
    );
    if (schoolId != null && schoolId.isNotEmpty) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ParentAccessCodeModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<String> createAccessCode({
    required List<String> studentIds,
    required String schoolId,
    required String phoneNumber,
    String? parentName,
  }) async {
    final parentCode = _generateAccessCode(prefix: 'P');
    // The code is also the document ID so pre-login users can perform the
    // rule-safe direct get without permission to enumerate access codes.
    final docRef = firestore.collection('parent_access_codes').doc(parentCode);

    final model = ParentAccessCodeModel(
      id: docRef.id,
      parentCode: parentCode,
      schoolId: schoolId,
      studentIds: studentIds,
      studentNames: [],
      phoneNumber: phoneNumber,
      parentName: parentName,
    );
    await docRef.set(model.toFirestore());
    return parentCode;
  }

  @override
  Future<String> regenerateAccessCode(String oldCode) async {
    final normalizedOldCode = oldCode.trim().toUpperCase();
    final oldRef = firestore
        .collection('parent_access_codes')
        .doc(normalizedOldCode);
    final oldSnapshot = await oldRef.get();
    if (!oldSnapshot.exists) {
      throw Exception('No access code found: $oldCode');
    }
    final oldData = oldSnapshot.data()!;

    final newCode = _generateAccessCode(prefix: 'P');
    final newRef = firestore.collection('parent_access_codes').doc(newCode);

    final batch = firestore.batch();
    batch.set(newRef, {...oldData, 'parentCode': newCode});
    batch.delete(oldRef);
    await batch.commit();

    return newCode;
  }

  @override
  Future<void> toggleAccessCodeStatus(
    String code,
    bool isActive, {
    String? reason,
  }) async {
    final reference = firestore
        .collection('parent_access_codes')
        .doc(code.trim().toUpperCase());
    final snapshot = await reference.get();
    if (snapshot.exists) {
      await reference.update({
        'isActive': isActive,
        'deactivationReason': reason,
      });
    }
  }

  @override
  Future<void> updateAccessCode(ParentAccessCodeModel code) async {
    await firestore
        .collection('parent_access_codes')
        .doc(code.id)
        .update(code.toFirestore());
  }

  @override
  Future<void> deleteAccessCode(String code) async {
    final reference = firestore
        .collection('parent_access_codes')
        .doc(code.trim().toUpperCase());
    final snapshot = await reference.get();
    if (snapshot.exists) {
      await reference.delete();
    }
  }

  @override
  Future<List<Homework>> getHomeworkForStudent(
    String schoolId,
    String className,
  ) async {
    final snapshot = await firestore
        .collection('homework')
        .where('schoolId', isEqualTo: schoolId)
        .where('className', isEqualTo: className)
        .orderBy('dueDate', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Homework(
        id: doc.id,
        schoolId: data['schoolId'] ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        className: data['className'] ?? '',
        subject: data['subject'] ?? '',
        dueDate: (data['dueDate'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        teacherId: data['teacherId'] ?? '',
        attachments: (data['attachments'] as List?)
            ?.map((e) => e as String)
            .toList(),
      );
    }).toList();
  }

  // --- Student Portal Access Codes ---
  // Code entropy and PIN clearing must not trust the caller, so all of
  // these route through Cloud Functions rather than writing
  // student_access_codes directly. See functions/student_credentials.js.

  @override
  Future<String> provisionStudentAccessCode(String studentId) async {
    final callable = functions.httpsCallable('provisionStudentAccessCode');
    final result = await callable.call<Map<String, dynamic>>({
      'studentId': studentId,
    });
    return result.data['code'] as String;
  }

  @override
  Future<void> resetStudentPin(String code) async {
    final callable = functions.httpsCallable('resetStudentPin');
    await callable.call<Map<String, dynamic>>({'code': code});
  }

  @override
  Future<void> setStudentAccessCodeStatus(
    String code,
    bool isActive, {
    String? reason,
  }) async {
    final callable = functions.httpsCallable('setStudentAccessCodeStatus');
    await callable.call<Map<String, dynamic>>({
      'code': code,
      'isActive': isActive,
      'reason': reason,
    });
  }

  @override
  Future<StudentAccessCodeModel?> getStudentAccessCode(String studentId) async {
    final snapshot = await firestore
        .collection('student_access_codes')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return StudentAccessCodeModel.fromFirestore(doc.data(), doc.id);
  }
}
