import 'attendance_local_data_source.dart';
import 'attendance_local_data_source_stub.dart'
    if (dart.library.js_interop) 'attendance_local_data_source_web.dart'
    if (dart.library.io) 'attendance_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
AttendanceLocalDataSource createAttendanceLocalDataSource({
  required dynamic isar,
}) => impl.create(isar: isar);
