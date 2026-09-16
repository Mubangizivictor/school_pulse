import 'staff_attendance_queue_data_source.dart';
import 'staff_attendance_queue_data_source_web.dart'
    if (dart.library.io) 'staff_attendance_queue_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop - see StaffAttendanceQueueDataSourceWeb doc.
StaffAttendanceQueueDataSource createStaffAttendanceQueueDataSource({
  required dynamic isar,
}) => impl.create(isar: isar);
