import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class IdentityService {
  final FirebaseFirestore _firestore;

  IdentityService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Validates a school code during setup.
  /// 3-6 characters, Uppercase only, No spaces, No special symbols.
  bool isValidSchoolCode(String code) {
    final regex = RegExp(r'^[A-Z0-9]{3,6}$');
    return regex.hasMatch(code);
  }

  /// Checks if a school code is available globally.
  Future<bool> isSchoolCodeAvailable(String code) async {
    final snapshot = await _firestore
        .collection('schools')
        .where('schoolCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  /// Generates a Student Code.
  /// Format: [SCHOOL CODE][YEAR][SEQUENCE] e.g., SMAC260001
  Future<String> generateStudentCode({
    required String schoolCode,
    required String academicYear,
  }) async {
    final yearSuffix = academicYear.substring(academicYear.length - 2);
    final prefix = '${schoolCode.toUpperCase()}$yearSuffix';

    return _generateUniqueCode(
      collection: 'students',
      field: 'studentCode',
      prefix: prefix,
      length: 4,
      isNumeric: true,
    );
  }

  /// Generates a Parent Code.
  /// Format: [SCHOOL CODE][RANDOM] e.g., SMAC583920
  Future<String> generateParentCode({required String schoolCode}) async {
    return _generateUniqueCode(
      collection: 'parents',
      field: 'parentCode',
      prefix: schoolCode.toUpperCase(),
      length: 6,
      isNumeric: true,
    );
  }

  /// Generates a Staff Code.
  /// Format: [SCHOOL CODE][RANDOM] e.g., SMAC749201
  Future<String> generateStaffCode({required String schoolCode}) async {
    return _generateUniqueCode(
      collection: 'staff',
      field: 'staffCode',
      prefix: schoolCode.toUpperCase(),
      length: 6,
      isNumeric: true,
    );
  }

  /// Internal helper to ensure uniqueness across the platform.
  Future<String> _generateUniqueCode({
    required String collection,
    required String field,
    required String prefix,
    required int length,
    bool isNumeric = true,
  }) async {
    final random = Random.secure();
    String code;
    bool exists = true;

    do {
      String suffix;
      if (isNumeric) {
        suffix = List.generate(length, (_) => random.nextInt(10)).join();
      } else {
        const chars =
            'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoid confusing chars
        suffix = List.generate(
          length,
          (_) => chars[random.nextInt(chars.length)],
        ).join();
      }
      code = '$prefix$suffix';

      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: code)
          .limit(1)
          .get();
      exists = snapshot.docs.isNotEmpty;
    } while (exists);

    return code;
  }

  /// Generates a secure reference token for QR codes.
  /// This token does NOT contain any personal information.
  String generateSecureReference() {
    final random = Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
