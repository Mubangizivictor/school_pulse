import 'package:equatable/equatable.dart';

/// School-wide attendance policy defaults - a singleton document, like
/// TimetableConfig. Note this is forward-looking configuration: the
/// attendance-marking screens don't read or enforce these values yet.
class AttendanceDefaultsConfig extends Equatable {
  final String attendanceMode;
  final String markingWindow;
  final bool allowBackdatedAttendance;
  final bool autoPresentOnAdmission;

  const AttendanceDefaultsConfig({
    this.attendanceMode = 'Daily',
    this.markingWindow = 'Until End of School Day',
    this.allowBackdatedAttendance = false,
    this.autoPresentOnAdmission = false,
  });

  AttendanceDefaultsConfig copyWith({
    String? attendanceMode,
    String? markingWindow,
    bool? allowBackdatedAttendance,
    bool? autoPresentOnAdmission,
  }) {
    return AttendanceDefaultsConfig(
      attendanceMode: attendanceMode ?? this.attendanceMode,
      markingWindow: markingWindow ?? this.markingWindow,
      allowBackdatedAttendance:
          allowBackdatedAttendance ?? this.allowBackdatedAttendance,
      autoPresentOnAdmission:
          autoPresentOnAdmission ?? this.autoPresentOnAdmission,
    );
  }

  @override
  List<Object?> get props => [
    attendanceMode,
    markingWindow,
    allowBackdatedAttendance,
    autoPresentOnAdmission,
  ];
}
