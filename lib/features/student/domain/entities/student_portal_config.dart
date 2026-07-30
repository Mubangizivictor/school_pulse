class StudentPortalConfig {
  final bool enableStudentPortal;
  final bool allowStudentMobileLogin;
  final bool allowStudentWebLogin;
  final bool allowReportCardDownloads;
  final bool allowSchoolFeeVisibility;
  final bool allowHomeworkSubmission;
  final bool allowAssignmentUploads;
  final bool allowDigitalIdCard;
  final bool allowQRAttendance;
  final bool allowTimetableAccess;

  StudentPortalConfig({
    this.enableStudentPortal = false,
    this.allowStudentMobileLogin = false,
    this.allowStudentWebLogin = false,
    this.allowReportCardDownloads = false,
    this.allowSchoolFeeVisibility = false,
    this.allowHomeworkSubmission = false,
    this.allowAssignmentUploads = false,
    this.allowDigitalIdCard = false,
    this.allowQRAttendance = false,
    this.allowTimetableAccess = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'enableStudentPortal': enableStudentPortal,
      'allowStudentMobileLogin': allowStudentMobileLogin,
      'allowStudentWebLogin': allowStudentWebLogin,
      'allowReportCardDownloads': allowReportCardDownloads,
      'allowSchoolFeeVisibility': allowSchoolFeeVisibility,
      'allowHomeworkSubmission': allowHomeworkSubmission,
      'allowAssignmentUploads': allowAssignmentUploads,
      'allowDigitalIdCard': allowDigitalIdCard,
      'allowQRAttendance': allowQRAttendance,
      'allowTimetableAccess': allowTimetableAccess,
    };
  }

  factory StudentPortalConfig.fromMap(Map<String, dynamic> map) {
    return StudentPortalConfig(
      enableStudentPortal: map['enableStudentPortal'] ?? false,
      allowStudentMobileLogin: map['allowStudentMobileLogin'] ?? false,
      allowStudentWebLogin: map['allowStudentWebLogin'] ?? false,
      allowReportCardDownloads: map['allowReportCardDownloads'] ?? false,
      allowSchoolFeeVisibility: map['allowSchoolFeeVisibility'] ?? false,
      allowHomeworkSubmission: map['allowHomeworkSubmission'] ?? false,
      allowAssignmentUploads: map['allowAssignmentUploads'] ?? false,
      allowDigitalIdCard: map['allowDigitalIdCard'] ?? false,
      allowQRAttendance: map['allowQRAttendance'] ?? false,
      allowTimetableAccess: map['allowTimetableAccess'] ?? false,
    );
  }

  StudentPortalConfig copyWith({
    bool? enableStudentPortal,
    bool? allowStudentMobileLogin,
    bool? allowStudentWebLogin,
    bool? allowReportCardDownloads,
    bool? allowSchoolFeeVisibility,
    bool? allowHomeworkSubmission,
    bool? allowAssignmentUploads,
    bool? allowDigitalIdCard,
    bool? allowQRAttendance,
    bool? allowTimetableAccess,
  }) {
    return StudentPortalConfig(
      enableStudentPortal: enableStudentPortal ?? this.enableStudentPortal,
      allowStudentMobileLogin: allowStudentMobileLogin ?? this.allowStudentMobileLogin,
      allowStudentWebLogin: allowStudentWebLogin ?? this.allowStudentWebLogin,
      allowReportCardDownloads: allowReportCardDownloads ?? this.allowReportCardDownloads,
      allowSchoolFeeVisibility: allowSchoolFeeVisibility ?? this.allowSchoolFeeVisibility,
      allowHomeworkSubmission: allowHomeworkSubmission ?? this.allowHomeworkSubmission,
      allowAssignmentUploads: allowAssignmentUploads ?? this.allowAssignmentUploads,
      allowDigitalIdCard: allowDigitalIdCard ?? this.allowDigitalIdCard,
      allowQRAttendance: allowQRAttendance ?? this.allowQRAttendance,
      allowTimetableAccess: allowTimetableAccess ?? this.allowTimetableAccess,
    );
  }
}
