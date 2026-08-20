import 'boarding_attendance_local_data_source.dart';
import 'boarding_attendance_local_data_source_stub.dart'
    if (dart.library.js_interop) 'boarding_attendance_local_data_source_web.dart'
    if (dart.library.io) 'boarding_attendance_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
BoardingAttendanceLocalDataSource createBoardingAttendanceLocalDataSource({
  required dynamic isar,
}) => impl.create(isar: isar);
