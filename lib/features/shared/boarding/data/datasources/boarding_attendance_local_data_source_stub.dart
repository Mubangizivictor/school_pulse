import 'boarding_attendance_local_data_source.dart';
import 'boarding_attendance_local_data_source_web.dart';

/// Selected only if the build target is neither web nor mobile/desktop -
/// reuses the web (always-miss) implementation as the safest default.
BoardingAttendanceLocalDataSource create({dynamic isar}) =>
    const BoardingAttendanceLocalDataSourceWeb();
