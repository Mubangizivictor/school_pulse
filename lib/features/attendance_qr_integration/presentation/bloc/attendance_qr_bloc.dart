import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/qr_attendance_record.dart';
import '../../domain/repositories/attendance_qr_repository.dart';
import '../../../student_identity/domain/repositories/student_identity_repository.dart';
import 'attendance_qr_event.dart';
import 'attendance_qr_state.dart';

class AttendanceQrBloc extends Bloc<AttendanceQrEvent, AttendanceQrState> {
  final AttendanceQrRepository attendanceRepository;
  final StudentIdentityRepository identityRepository;

  AttendanceQrBloc({
    required this.attendanceRepository,
    required this.identityRepository,
  }) : super(AttendanceQrInitial()) {
    on<ScanStudentQrEvent>((event, emit) async {
      emit(AttendanceQrLoading());
      final result = await identityRepository.getStudentByUniqueId(event.uniqueSystemId);
      result.fold(
        (failure) => emit(AttendanceQrError(failure.message)),
        (student) {
          if (student == null) {
            emit(const AttendanceQrError('Student not found. Invalid QR Code.'));
          } else {
            emit(StudentScannedSuccess(student));
          }
        },
      );
    });

    on<MarkAttendanceEvent>((event, emit) async {
      emit(AttendanceQrLoading());
      final record = QrAttendanceRecord(
        id: '', // Will be set by local DB
        studentUniqueId: event.studentUniqueId,
        studentName: event.studentName,
        className: event.className,
        status: event.status,
        timestamp: DateTime.now(),
        scannedBy: event.scannedBy,
        schoolId: event.schoolId,
        module: event.module,
      );

      final result = await attendanceRepository.saveAttendance(record);
      result.fold(
        (failure) => emit(AttendanceQrError(failure.message)),
        (_) => emit(const AttendanceMarkedSuccess('Attendance recorded successfully.')),
      );
    });

    on<SyncAttendanceEvent>((event, emit) async {
      emit(AttendanceQrLoading());
      final result = await attendanceRepository.syncWithFirebase();
      result.fold(
        (failure) => emit(AttendanceQrError(failure.message)),
        (_) => emit(AttendanceSyncSuccess()),
      );
    });
  }
}
