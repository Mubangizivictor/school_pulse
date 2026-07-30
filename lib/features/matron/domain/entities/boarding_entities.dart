import 'package:equatable/equatable.dart';

class Dormitory extends Equatable {
  final String id;
  final String name;
  final String gender; // 'Male' or 'Female'
  final int capacity;
  final int occupantCount;
  final String? roomLeaderId;
  final String? roomLeaderName;

  const Dormitory({
    required this.id,
    required this.name,
    required this.gender,
    required this.capacity,
    required this.occupantCount,
    this.roomLeaderId,
    this.roomLeaderName,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    gender,
    capacity,
    occupantCount,
    roomLeaderId,
    roomLeaderName,
  ];
}

class BoardingStudent extends Equatable {
  final String id;
  final String name;
  final String gender;
  final String? dormitoryId;
  final String? dormitoryName;
  final String? bedNumber;
  final String? status; // 'Present', 'Leave', 'Sick', etc.

  const BoardingStudent({
    required this.id,
    required this.name,
    required this.gender,
    this.dormitoryId,
    this.dormitoryName,
    this.bedNumber,
    this.status,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    gender,
    dormitoryId,
    dormitoryName,
    bedNumber,
    status,
  ];
}

class WelfareRecord extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String category; // 'Concern', 'Counseling', 'Check-up', etc.
  final String note;
  final DateTime date;
  final String recordedBy;
  final bool isPrivate;

  const WelfareRecord({
    required this.id,
    this.schoolId = '',
    required this.studentId,
    required this.studentName,
    required this.category,
    required this.note,
    required this.date,
    required this.recordedBy,
    this.isPrivate = false,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    studentName,
    category,
    note,
    date,
    recordedBy,
    isPrivate,
  ];
}

class DisciplineCase extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String incident;
  final String category;
  final String actionTaken;
  final DateTime date;
  final String status; // 'Pending', 'Resolved', 'Follow-up'
  final String recordedBy;

  const DisciplineCase({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.incident,
    required this.category,
    required this.actionTaken,
    required this.date,
    required this.status,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    incident,
    category,
    actionTaken,
    date,
    status,
    recordedBy,
  ];
}

class HygieneCheck extends Equatable {
  final String id;
  final String dormitoryId;
  final String dormitoryName;
  final DateTime date;
  final double score; // 0-10 or 0-100
  final String notes;
  final List<String> maintenanceRequired;
  final String recordedBy;

  const HygieneCheck({
    required this.id,
    required this.dormitoryId,
    required this.dormitoryName,
    required this.date,
    required this.score,
    required this.notes,
    required this.maintenanceRequired,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [
    id,
    dormitoryId,
    dormitoryName,
    date,
    score,
    notes,
    maintenanceRequired,
    recordedBy,
  ];
}
