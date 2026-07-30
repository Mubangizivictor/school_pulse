enum AppointmentStatus {
  pending,
  approved,
  rejected,
  rescheduleProposed,
  cancelled,
  completed,
  noShow,
  expired,
}

extension AppointmentStatusLabel on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Approved';
      case AppointmentStatus.rejected:
        return 'Rejected';
      case AppointmentStatus.rescheduleProposed:
        return 'Reschedule Proposed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.noShow:
        return 'No Show';
      case AppointmentStatus.expired:
        return 'Expired';
    }
  }
}
