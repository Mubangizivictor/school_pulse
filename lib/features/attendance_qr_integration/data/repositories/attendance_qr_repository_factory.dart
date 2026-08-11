import '../../domain/repositories/attendance_qr_repository.dart';
import 'attendance_qr_repository_stub.dart'
    if (dart.library.js_interop) 'attendance_qr_repository_web.dart'
    if (dart.library.io) 'attendance_qr_repository_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [firestore] on both.
AttendanceQrRepository createAttendanceQrRepository({
  required dynamic firestore,
  required dynamic isar,
}) => impl.create(firestore: firestore, isar: isar);
