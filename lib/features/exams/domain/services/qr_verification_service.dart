import 'dart:convert';
import 'package:crypto/crypto.dart';

class QrVerificationService {
  static const String _secretKey = "SCHOOL_PULSE_SECURE_REPORT_KEY";

  /// Generates a secure verification hash for a report card.
  /// This hash is stored in the QR code.
  static String generateVerificationCode({
    required String schoolId,
    required String studentId,
    required String term,
    required String year,
  }) {
    final rawString = "$schoolId|$studentId|$term|$year|$_secretKey";
    final bytes = utf8.encode(rawString);
    final digest = sha256.convert(bytes);
    return digest
        .toString()
        .substring(0, 12)
        .toUpperCase(); // Shortened for QR readability
  }

  /// Generates the URL or data string that goes into the QR code.
  static String generateQrData({
    required String schoolId,
    required String studentId,
    required String term,
    required String year,
  }) {
    final verificationCode = generateVerificationCode(
      schoolId: schoolId,
      studentId: studentId,
      term: term,
      year: year,
    );

    // This could be a deep link to the school's verification portal
    return "https://verify.schoolpulseapp.com/report?s=$schoolId&st=$studentId&t=$term&y=$year&v=$verificationCode";
  }
}
