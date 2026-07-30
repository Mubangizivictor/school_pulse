enum ScannerMode {
  attendance,
  library,
  security,
  transport,
  hostel,
  exams,
  verification,
  finance,
}

extension ScannerModeExtension on ScannerMode {
  String get label {
    switch (this) {
      case ScannerMode.attendance: return 'Attendance';
      case ScannerMode.library: return 'Library';
      case ScannerMode.security: return 'Security Gate';
      case ScannerMode.transport: return 'Transport';
      case ScannerMode.hostel: return 'Hostel';
      case ScannerMode.exams: return 'Exams';
      case ScannerMode.verification: return 'Student Verification';
      case ScannerMode.finance: return 'Finance Verification';
    }
  }
}
