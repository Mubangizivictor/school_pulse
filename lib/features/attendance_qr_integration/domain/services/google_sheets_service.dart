import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/qr_attendance_record.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleSheetsService {
  // Replace with your actual App Script URL or backend endpoint
  final String _endpoint =
      'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec';

  Future<Either<Failure, void>> exportAttendance({
    required String schoolId,
    required String schoolName,
    required List<QrAttendanceRecord> records,
  }) async {
    try {
      final data = records
          .map(
            (r) => {
              'studentUniqueId': r.studentUniqueId,
              'studentName': r.studentName,
              'className': r.className,
              'status': r.status.name,
              'timestamp': r.timestamp.toIso8601String(),
              'scannedBy': r.scannedBy,
              'module': r.module,
            },
          )
          .toList();

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schoolId': schoolId,
          'schoolName': schoolName,
          'action': 'export_attendance',
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            'Failed to export to Google Sheets: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> exportVisitors({
    required String schoolId,
    required String schoolName,
    required List<dynamic> visitors, // List<Visitor>
  }) async {
    try {
      final data = visitors
          .map(
            (v) => {
              'fullName': v.fullName,
              'phone': v.phone,
              'host': v.host,
              'purpose': v.purpose,
              'category': v.category.name,
              'arrivalTime': v.arrivalTime.toIso8601String(),
              'departureTime': v.departureTime?.toIso8601String(),
              'status': v.status.name,
              'company': v.company,
              'notes': v.notes,
            },
          )
          .toList();

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schoolId': schoolId,
          'schoolName': schoolName,
          'action': 'export_visitors',
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            'Failed to export to Google Sheets: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
