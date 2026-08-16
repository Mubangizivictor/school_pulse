import 'package:equatable/equatable.dart';

/// One named slot in the school day - a break, lunch, assembly, or a
/// regular teaching period. Flexible so schools can define any mix.
class TimetableSlot extends Equatable {
  /// Stable id so a class timetable can refer to a configured slot even when
  /// the slot is renamed. Legacy slots do not have one and are supported.
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final String type;
  final int displayOrder;
  final bool isActive;
  final List<String> days;
  final String colorHex;
  final String notes;

  const TimetableSlot({
    this.id = '',
    required this.name,
    required this.startTime,
    required this.endTime,
    this.type = 'period',
    this.displayOrder = 0,
    this.isActive = true,
    this.days = const [],
    this.colorHex = '',
    this.notes = '',
  });

  TimetableSlot copyWith({
    String? id,
    String? name,
    String? startTime,
    String? endTime,
    String? type,
    int? displayOrder,
    bool? isActive,
    List<String>? days,
    String? colorHex,
    String? notes,
  }) {
    return TimetableSlot(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      days: days ?? this.days,
      colorHex: colorHex ?? this.colorHex,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    startTime,
    endTime,
    type,
    displayOrder,
    isActive,
    days,
    colorHex,
    notes,
  ];
}

/// An optional date-bounded alternative day structure. Names are deliberately
/// generic: a school may call it Ramadan, exams, rainy season, or anything
/// else; the product never assumes a "winter" timetable.
class TimetableSpecialSchedule extends Equatable {
  final String id;
  final String name;
  final DateTime effectiveStartDate;
  final DateTime effectiveEndDate;
  final int? defaultPeriodDurationMinutes;
  final List<TimetableSlot> slots;

  const TimetableSpecialSchedule({
    this.id = '',
    required this.name,
    required this.effectiveStartDate,
    required this.effectiveEndDate,
    this.defaultPeriodDurationMinutes,
    this.slots = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    effectiveStartDate,
    effectiveEndDate,
    defaultPeriodDurationMinutes,
    slots,
  ];
}

/// The school's timetable shape - a singleton document, like
/// FeatureToggles. Nothing about periods/breaks/school hours is hardcoded.
class TimetableConfig extends Equatable {
  final List<String> teachingDays;

  /// Retained only to read older documents. Non-teaching days are always
  /// derived from [teachingDays] in the configuration experience.
  final List<String> weekendDays;
  final int defaultPeriodDurationMinutes;
  final int periodsPerDay;
  final String schoolStartTime;
  final String schoolEndTime;
  final List<TimetableSlot> slots;
  final List<TimetableSpecialSchedule> specialSchedules;

  const TimetableConfig({
    this.teachingDays = const [],
    this.weekendDays = const [],
    this.defaultPeriodDurationMinutes = 0,
    this.periodsPerDay = 0,
    this.schoolStartTime = '',
    this.schoolEndTime = '',
    this.slots = const [],
    this.specialSchedules = const [],
  });

  TimetableConfig copyWith({
    List<String>? teachingDays,
    List<String>? weekendDays,
    int? defaultPeriodDurationMinutes,
    int? periodsPerDay,
    String? schoolStartTime,
    String? schoolEndTime,
    List<TimetableSlot>? slots,
    List<TimetableSpecialSchedule>? specialSchedules,
  }) {
    return TimetableConfig(
      teachingDays: teachingDays ?? this.teachingDays,
      weekendDays: weekendDays ?? this.weekendDays,
      defaultPeriodDurationMinutes:
          defaultPeriodDurationMinutes ?? this.defaultPeriodDurationMinutes,
      periodsPerDay: periodsPerDay ?? this.periodsPerDay,
      schoolStartTime: schoolStartTime ?? this.schoolStartTime,
      schoolEndTime: schoolEndTime ?? this.schoolEndTime,
      slots: slots ?? this.slots,
      specialSchedules: specialSchedules ?? this.specialSchedules,
    );
  }

  @override
  List<Object?> get props => [
    teachingDays,
    weekendDays,
    defaultPeriodDurationMinutes,
    periodsPerDay,
    schoolStartTime,
    schoolEndTime,
    slots,
    specialSchedules,
  ];
}
