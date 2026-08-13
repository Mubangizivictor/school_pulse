import 'package:equatable/equatable.dart';

/// One named slot in the school day - a break, lunch, assembly, or a
/// regular teaching period. Flexible so schools can define any mix.
class TimetableSlot extends Equatable {
  final String name;
  final String startTime;
  final String endTime;
  final String type;
  final int displayOrder;
  final bool isActive;

  const TimetableSlot({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.type = 'period',
    this.displayOrder = 0,
    this.isActive = true,
  });

  TimetableSlot copyWith({
    String? name,
    String? startTime,
    String? endTime,
    String? type,
    int? displayOrder,
    bool? isActive,
  }) {
    return TimetableSlot(
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    name,
    startTime,
    endTime,
    type,
    displayOrder,
    isActive,
  ];
}

/// The school's timetable shape - a singleton document, like
/// FeatureToggles. Nothing about periods/breaks/school hours is hardcoded.
class TimetableConfig extends Equatable {
  final List<String> teachingDays;
  final List<String> weekendDays;
  final int periodsPerDay;
  final String schoolStartTime;
  final String schoolEndTime;
  final List<TimetableSlot> slots;

  const TimetableConfig({
    this.teachingDays = const [],
    this.weekendDays = const [],
    this.periodsPerDay = 0,
    this.schoolStartTime = '',
    this.schoolEndTime = '',
    this.slots = const [],
  });

  TimetableConfig copyWith({
    List<String>? teachingDays,
    List<String>? weekendDays,
    int? periodsPerDay,
    String? schoolStartTime,
    String? schoolEndTime,
    List<TimetableSlot>? slots,
  }) {
    return TimetableConfig(
      teachingDays: teachingDays ?? this.teachingDays,
      weekendDays: weekendDays ?? this.weekendDays,
      periodsPerDay: periodsPerDay ?? this.periodsPerDay,
      schoolStartTime: schoolStartTime ?? this.schoolStartTime,
      schoolEndTime: schoolEndTime ?? this.schoolEndTime,
      slots: slots ?? this.slots,
    );
  }

  @override
  List<Object?> get props => [
    teachingDays,
    weekendDays,
    periodsPerDay,
    schoolStartTime,
    schoolEndTime,
    slots,
  ];
}
