import 'package:equatable/equatable.dart';

enum GoalStatus { onTrack, atRisk, behind, achieved, abandoned }

extension GoalStatusWire on GoalStatus {
  String get wire => name;
  static GoalStatus parse(Object? value) => GoalStatus.values.firstWhere(
    (v) => v.name == value,
    orElse: () => GoalStatus.onTrack,
  );
}

class StrategicGoal extends Equatable {
  final String goalId, institutionId, title, description, responsibleDepartment;
  final double targetValue, currentValue;
  final String unit;
  final GoalStatus status;
  final DateTime deadline, createdAt;
  final String createdBy;

  const StrategicGoal({
    required this.goalId,
    required this.institutionId,
    required this.title,
    required this.description,
    required this.responsibleDepartment,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.createdBy,
  });

  double get progressPercentage =>
      targetValue == 0 ? 0 : ((currentValue / targetValue) * 100).clamp(0, 100);

  Map<String, dynamic> toMap() => {
    'institutionId': institutionId,
    'title': title,
    'description': description,
    'responsibleDepartment': responsibleDepartment,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'unit': unit,
    'status': status.wire,
    'deadline': deadline.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory StrategicGoal.fromMap(Map<String, dynamic> map) {
    DateTime date(Object? v) {
      if (v == null) return DateTime.now();
      try {
        final converted = (v as dynamic).toDate();
        if (converted is DateTime) return converted;
      } catch (_) {}
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return StrategicGoal(
      goalId: map['goalId'] as String? ?? '',
      institutionId: map['institutionId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      responsibleDepartment: map['responsibleDepartment'] as String? ?? '',
      targetValue: (map['targetValue'] as num? ?? 0).toDouble(),
      currentValue: (map['currentValue'] as num? ?? 0).toDouble(),
      unit: map['unit'] as String? ?? '',
      status: GoalStatusWire.parse(map['status']),
      deadline: date(map['deadline']),
      createdAt: date(map['createdAt']),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  StrategicGoal copyWith({
    double? currentValue,
    GoalStatus? status,
  }) => StrategicGoal(
    goalId: goalId,
    institutionId: institutionId,
    title: title,
    description: description,
    responsibleDepartment: responsibleDepartment,
    targetValue: targetValue,
    currentValue: currentValue ?? this.currentValue,
    unit: unit,
    status: status ?? this.status,
    deadline: deadline,
    createdAt: createdAt,
    createdBy: createdBy,
  );

  @override
  List<Object?> get props => [
    goalId,
    institutionId,
    title,
    responsibleDepartment,
    targetValue,
    currentValue,
    status,
    deadline,
  ];
}
