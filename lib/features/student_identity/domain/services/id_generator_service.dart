import 'package:uuid/uuid.dart';

class IdGeneratorService {
  final _uuid = const Uuid();

  /// Generates a globally unique System ID
  /// Example: SP-STUDENT-a82jd92
  String generateUniqueSystemId() {
    final randomPart = _uuid.v4().split('-').first;
    return 'SP-STUDENT-$randomPart';
  }

  /// Generates a School Student ID (Admission Number)
  /// Example: MH-2026-000001
  /// [schoolPrefix] e.g. "MH" for Mary Hill
  /// [year] e.g. 2026
  /// [sequenceNumber] e.g. 1
  String generateSchoolStudentId({
    required String schoolPrefix,
    required int year,
    required int sequenceNumber,
  }) {
    final formattedSequence = sequenceNumber.toString().padLeft(6, '0');
    return '$schoolPrefix-$year-$formattedSequence';
  }
}
