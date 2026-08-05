/// The 9 categories from the Attendance mockup's dropdown. Each maps to one
/// of the `attendance.*.scan` permissions (see Permission class) so a
/// category-appropriate check gates every mark.
enum AttendanceCategory {
  students,
  staff,
  gate,
  meals,
  library,
  transport,
  visitors,
  hostel,
  custom,
}

extension AttendanceCategoryLabel on AttendanceCategory {
  String get label {
    switch (this) {
      case AttendanceCategory.students:
        return 'Students';
      case AttendanceCategory.staff:
        return 'Staff';
      case AttendanceCategory.gate:
        return 'Gate';
      case AttendanceCategory.meals:
        return 'Meals/Food';
      case AttendanceCategory.library:
        return 'Library';
      case AttendanceCategory.transport:
        return 'Transport';
      case AttendanceCategory.visitors:
        return 'Visitors';
      case AttendanceCategory.hostel:
        return 'Hostel';
      case AttendanceCategory.custom:
        return 'Custom';
    }
  }
}
