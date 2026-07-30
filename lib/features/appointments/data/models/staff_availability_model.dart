import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/staff_availability.dart';

class StaffAvailabilityModel extends StaffAvailability {
  const StaffAvailabilityModel({
    required super.staffId,
    required super.schoolId,
    super.workingDays,
    super.startMinuteOfDay,
    super.endMinuteOfDay,
    super.slotDurationMinutes,
    super.bufferMinutes,
    super.maxAppointmentsPerDay,
    super.unavailableDates,
  });

  factory StaffAvailabilityModel.fromEntity(StaffAvailability a) {
    return StaffAvailabilityModel(
      staffId: a.staffId,
      schoolId: a.schoolId,
      workingDays: a.workingDays,
      startMinuteOfDay: a.startMinuteOfDay,
      endMinuteOfDay: a.endMinuteOfDay,
      slotDurationMinutes: a.slotDurationMinutes,
      bufferMinutes: a.bufferMinutes,
      maxAppointmentsPerDay: a.maxAppointmentsPerDay,
      unavailableDates: a.unavailableDates,
    );
  }

  factory StaffAvailabilityModel.fromMap(Map<String, dynamic> map, String staffId) {
    return StaffAvailabilityModel(
      staffId: staffId,
      schoolId: map['schoolId'] ?? '',
      workingDays: ((map['workingDays'] as List?) ?? const [1, 2, 3, 4, 5])
          .map((d) => d as int)
          .toSet(),
      startMinuteOfDay: map['startMinuteOfDay'] ?? 8 * 60,
      endMinuteOfDay: map['endMinuteOfDay'] ?? 16 * 60,
      slotDurationMinutes: map['slotDurationMinutes'] ?? 20,
      bufferMinutes: map['bufferMinutes'] ?? 0,
      maxAppointmentsPerDay: map['maxAppointmentsPerDay'] ?? 12,
      unavailableDates: ((map['unavailableDates'] as List?) ?? const [])
          .map((t) => (t as Timestamp).toDate())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'workingDays': workingDays.toList(),
      'startMinuteOfDay': startMinuteOfDay,
      'endMinuteOfDay': endMinuteOfDay,
      'slotDurationMinutes': slotDurationMinutes,
      'bufferMinutes': bufferMinutes,
      'maxAppointmentsPerDay': maxAppointmentsPerDay,
      'unavailableDates': unavailableDates.map((d) => Timestamp.fromDate(d)).toList(),
    };
  }
}
