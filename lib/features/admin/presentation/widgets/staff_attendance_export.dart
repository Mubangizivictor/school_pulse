import 'staff_attendance_export_io.dart'
    if (dart.library.html) 'staff_attendance_export_web.dart';

/// Hands the finished CSV [content] to the user under [fileName].
///
/// - Web: triggers a browser download.
/// - Mobile/desktop: opens the platform share sheet with a temp file.
///
/// Returns a short human-readable outcome for a SnackBar (e.g. "Downloaded"
/// / "Shared"), or throws on failure.
Future<String> saveStaffAttendanceCsv({
  required String fileName,
  required String content,
}) => saveCsvImpl(fileName: fileName, content: content);
