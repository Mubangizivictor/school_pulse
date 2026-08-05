import 'package:equatable/equatable.dart';

/// A staff member's own booking schedule - one doc per staff member, keyed
/// by their user id. Working days use DateTime.weekday numbering (1=Mon..
/// 7=Sun) so day-of-week checks against a proposed slot don't need a
/// separate mapping table.
class StaffAvailability extends Equatable {
  final String staffId;
  final String schoolId;
  final Set<int> workingDays;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final int slotDurationMinutes;
  final int bufferMinutes;
  final int maxAppointmentsPerDay;
  final List<DateTime> unavailableDates;

  const StaffAvailability({
    required this.staffId,
    required this.schoolId,
    this.workingDays = const {1, 2, 3, 4, 5},
    this.startMinuteOfDay = 8 * 60,
    this.endMinuteOfDay = 16 * 60,
    this.slotDurationMinutes = 20,
    this.bufferMinutes = 0,
    this.maxAppointmentsPerDay = 12,
    this.unavailableDates = const [],
  });

  StaffAvailability copyWith({
    String? staffId,
    String? schoolId,
    Set<int>? workingDays,
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    int? slotDurationMinutes,
    int? bufferMinutes,
    int? maxAppointmentsPerDay,
    List<DateTime>? unavailableDates,
  }) {
    return StaffAvailability(
      staffId: staffId ?? this.staffId,
      schoolId: schoolId ?? this.schoolId,
      workingDays: workingDays ?? this.workingDays,
      startMinuteOfDay: startMinuteOfDay ?? this.startMinuteOfDay,
      endMinuteOfDay: endMinuteOfDay ?? this.endMinuteOfDay,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      bufferMinutes: bufferMinutes ?? this.bufferMinutes,
      maxAppointmentsPerDay:
          maxAppointmentsPerDay ?? this.maxAppointmentsPerDay,
      unavailableDates: unavailableDates ?? this.unavailableDates,
    );
  }

  bool isUnavailableOn(DateTime date) {
    return unavailableDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  @override
  List<Object?> get props => [
    staffId,
    schoolId,
    workingDays,
    startMinuteOfDay,
    endMinuteOfDay,
    slotDurationMinutes,
    bufferMinutes,
    maxAppointmentsPerDay,
    unavailableDates,
  ];
}
